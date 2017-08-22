unit PlayerHandler;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  IdContext,
  System.Generics.Defaults,
  System.Generics.Collections,
  IdHashMessageDigest,
  IdGlobal,
  Config;

type
  PlayerStruct = record
    Con: TIdContext;
    UserName: String;
    VeryfyKey: String;
    IP: String;
    Port: Word;
    X: SmallInt; // SHORT
    Y: SmallInt; // SHORT
    Z: SmallInt; // SHORT
    Yaw: Byte;
    Pitch: Byte;
    Op: Byte;
    PID: Byte; // Only Byte;
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

var
  PlayersStack: TDictionary<TIdContext, PlayerStruct>;
  List: TThreadList<String>;
  UUID: TStack<ShortInt>;

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
    PlayersStack.AddOrSetValue(AContext, SelfPlayer);

{$REGION 'Self Spawn'}
    Packet7.Write(AContext, 255, SelfPlayer.UserName, SelfPlayer.X,
      SelfPlayer.Y, SelfPlayer.Z, SelfPlayer.Yaw, SelfPlayer.Pitch);
{$ENDREGION}
{$REGION 'Message Joined'}
    Msg := '&2+ &6' + SelfPlayer.UserName.Replace(' ', '') +
      ' &6joined the game';
    Msg := Msg + stringofchar(' ', 64 - length(Msg));
{$ENDREGION}
    System.TMonitor.Enter(PlayersStack);
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
   System.TMonitor.Exit(PlayersStack);
  end;
  Writeln('Подключился: ' + PlayersStack.Items[AContext].UserName);

end;

class procedure PlayerManager.Disconnect(AContext: TIdContext);
var
  PlayerName, Msg: string;
  PID: Byte;
  Player: PlayerStruct;
begin
  System.TMonitor.Enter(PlayersStack);

  PlayerName := PlayersStack.Items[AContext].UserName.Replace(' ', '');
  PID := PlayersStack.Items[AContext].PID;
  Writeln('Отключился: ' + PlayerName);
  UUID.Push(PlayersStack.Items[AContext].PID);
  PlayersStack.Remove(AContext);

  System.TMonitor.Exit(PlayersStack);
{$REGION 'Message Disconnect'}
  Msg := '&4- &6' + PlayerName.Replace(' ', '') + ' &6left the game';
  Msg := Msg + stringofchar(' ', 64 - length(Msg));

 System.TMonitor.Enter(PlayersStack);
  for Player in PlayersStack.Values do
  begin
    Packet13.Write(Player.Con, Msg);
  end;
 System.TMonitor.Exit(PlayersStack);

{$ENDREGION}
{$REGION 'Player despawn'}

  System.TMonitor.Enter(PlayersStack);
  for Player in PlayersStack.Values do
  begin
    Packet12.Write(Player.Con, PID);
  end;
  System.TMonitor.Exit(PlayersStack);

{$ENDREGION}
end;

class procedure PlayerManager.PlayerIdent(Vers: Byte; UserName: String;
  VerKey: String; AContext: TIdContext);
var
  MD5Mgr: TIdHashMessageDigest;
  MD5: string;
  Player: PlayerStruct;
begin
  try
    Player.UserName := UserName;
    Player.VeryfyKey := VerKey;
    Player.Con := AContext;
    Player.PID := UUID.Pop;
    Player.X := 3000;
    Player.Y := 3000;
    Player.Z := 3000;
    MD5Mgr := TIdHashMessageDigest5.Create;
    MD5 := MD5Mgr.HashStringAsHex(Cgf.ServerSalt + UserName.Replace(' ', ''));

    if LowerCase(MD5) = Player.VeryfyKey.Replace(' ', '') then
    begin
      MD5Mgr.Free;
      PlayerManager.Connect(AContext, Player);
    end
    else
    begin
      MD5Mgr.Free;
      PlayerManager.Connect(AContext, Player);
      // Packet14.Write(AContext, 'Bad connect session');
    end;

  except
    on E: Exception do
    begin
      MD5Mgr.Free;
    end;

  end;
end;

class procedure PlayerManager.Init;
var
  i: ShortInt;
begin
  List := TThreadList<String>.Create;
  List.Add('fff');
  List.Add('ff');

  PlayersStack := TDictionary<TIdContext, PlayerStruct>.Create;
  UUID := TStack<ShortInt>.Create();
  for i := 0 to 120 do
  begin
    UUID.Push(i);
  end;

end;

end.
