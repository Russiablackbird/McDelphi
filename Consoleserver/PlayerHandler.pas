unit PlayerHandler;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  IdContext,
  Rapid.Generics,
  IdHashMessageDigest,
  Config,
  World;

type
  PlayerStruct = record
    Con: TIdContext;
    UserName: String;
    VeryfyKey: String;
    X: SmallInt;
    Y: SmallInt;
    Z: SmallInt;
    Yaw: Byte;
    Pitch: Byte;
    Op: Byte;
    PID: Byte;
    Spawned: Boolean;
  end;

type
  PlayerManager = class
  public
    class procedure Init();
    class procedure Connect(AContext: TIdContext; SelfPlayer: PlayerStruct);
    class procedure Disconnect(AContext: TIdContext);
    class procedure PlayerIdent(Vers: Byte; UserName: String; VerKey: String;
      AContext: TIdContext);
  end;

type
  TDictonaryHelper = class helper for TDictionary<TIdContext, PlayerStruct>
    procedure Lock;
    procedure Unlock;
  end;

type
  TStackHelper = class helper for TStack<Byte>
    procedure Lock;
    procedure Unlock;
  end;

var
  PlayersStack: TDictionary<TIdContext, PlayerStruct>;
  UUID: TStack<Byte>;

implementation

Uses
  Server,
  Packet_0,
  Packet_1, // Ping
  Packet_2, // Level Initialize
  Packet_3, // Level Data Chunk
  Packet_4, // Level Finalize
  Packet_5, // Set Block
  Packet_6, // Set Block
  Packet_7, // Spawn Player
  Packet_8, // Position and Orientation
  Packet_12, // Despawn Player
  Packet_13, // Message
  Packet_14; // Kicked

procedure TDictonaryHelper.Lock;
begin
  DictionaryCS.Enter;
end;

procedure TDictonaryHelper.Unlock;
begin
  DictionaryCS.Leave;
end;

procedure TStackHelper.Lock;
begin
  UUIDCS.Enter;
end;

procedure TStackHelper.Unlock;
begin
  UUIDCS.Leave;
end;

class procedure PlayerManager.Connect(AContext: TIdContext;
  SelfPlayer: PlayerStruct);
var
  Msg: string;
  Player: PlayerStruct;
begin
  Packet0.Write(AContext, 7, Cgf.ServerName, Cgf.ServerMOTD, 0); // 100 is op
  Packet2.Write(AContext);
  Packet3.Write(AContext);

  with AContext.Connection do
  begin
    Packet4.Write(AContext);

    PlayersStack.Add(AContext, SelfPlayer);

{$REGION 'Self Spawn'}
    Packet7.Write(AContext, 255, SelfPlayer.UserName, SelfPlayer.X,
      SelfPlayer.Y, SelfPlayer.Z, SelfPlayer.Yaw, SelfPlayer.Pitch);
{$ENDREGION}
{$REGION 'Message Joined'}
    Msg := '&2+ &6' + SelfPlayer.UserName.Replace(' ', '') +
      ' &6joined the game';
    Msg := Msg + stringofchar(' ', 64 - length(Msg));
{$ENDREGION}
    for Player in PlayersStack.Values do
    begin
      if Player.PID <> SelfPlayer.PID then
      begin
        Packet7.Write(Player.Con, SelfPlayer.PID, SelfPlayer.UserName,
          SelfPlayer.X, SelfPlayer.Y, SelfPlayer.Z, SelfPlayer.Yaw,
          SelfPlayer.Pitch);
        Packet7.Write(AContext, Player.PID, Player.UserName, Player.X, Player.Y,
          Player.Z, Player.Yaw, Player.Pitch);
        Packet13.Write(Player.Con, Msg);
      end;
    end;

  end;
  Writeln('Connect: ' + PlayersStack.Items[AContext].UserName);
end;

class procedure PlayerManager.Disconnect(AContext: TIdContext);
var
  PlayerName, Msg: string;
  PID: Byte;
  Player: PlayerStruct;
begin
  try
    PlayersStack.Lock;
    PlayerName := PlayersStack.Items[AContext].UserName.Replace(' ', '');
    PID := PlayersStack.Items[AContext].PID;
    Writeln('Disconnect: ' + PlayerName);

    PlayersStack.Remove(AContext);
    Msg := '&4- &6' + PlayerName.Replace(' ', '') + ' &6left the game';
    Msg := Msg + stringofchar(' ', 64 - length(Msg));

    for Player in PlayersStack.Values do
    begin
      Packet13.Write(Player.Con, Msg);
      Packet12.Write(Player.Con, PID);
    end;

  finally

    begin
      UUID.Lock;
      UUID.Push(PID);
      UUID.Unlock;
      PlayersStack.Unlock;
    end;

  end;
end;

class procedure PlayerManager.PlayerIdent(Vers: Byte; UserName: String;
  VerKey: String; AContext: TIdContext);
var
  MD5Mgr: TIdHashMessageDigest;
  MD5: string;
  Player: PlayerStruct;
begin
  MD5Mgr := TIdHashMessageDigest5.Create;
  try
    Player.UserName := UserName;
    Player.VeryfyKey := VerKey;
    Player.Con := AContext;
    UUID.Lock;
    Player.PID := UUID.Pop;
    UUID.Unlock;
    Player.X := 3000;
    Player.Y := 3000;
    Player.Z := 3000;
    MD5 := MD5Mgr.HashStringAsHex(Cgf.ServerSalt + UserName.Replace(' ', ''));
    if LowerCase(MD5) = Player.VeryfyKey.Replace(' ', '') then
    begin
      PlayerManager.Connect(AContext, Player);
    end
    else
    begin
      PlayerManager.Connect(AContext, Player);
      // Packet14.Write(AContext, 'Bad connect session');
    end;

  finally
    begin
      MD5Mgr.Free;
    end;

  end;

end;

class procedure PlayerManager.Init;
var
  I: Byte;
begin
  PlayersStack := TDictionary<TIdContext, PlayerStruct>.Create;
  UUID := TStack<Byte>.Create;
  for I := 0 to 110 do
  begin

    UUID.Push(I);

  end;

end;

end.
