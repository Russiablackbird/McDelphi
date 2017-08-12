unit PlayerHandler;

interface

uses
  System.SysUtils, IdContext,
  System.Generics.Defaults,
  System.Generics.Collections,
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
  UUID: TQueue<ShortInt>;

implementation

uses
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
  Packet_14; //

class procedure PlayerManager.Connect(AContext: TIdContext;
  SelfPlayer: PlayerStruct);
var
  Player: PlayerStruct;
  Msg: string;
begin
  Packet0.Write(AContext, 7, Cgf.ServerName, Cgf.ServerMOTD, 64);
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
  Writeln('Подключился: ' + PlayersStack.Items[AContext].UserName);
end;

class procedure PlayerManager.Disconnect(AContext: TIdContext);
var
  Player: PlayerStruct;
  PlayerName, Msg: string;
  PID: Byte;
begin
  PlayerName := PlayersStack.Items[AContext].UserName.Replace(' ', '');
  PID := PlayersStack.Items[AContext].PID;
  Writeln('Отключился: ' + PlayerName);
  UUID.Enqueue(PlayersStack.Items[AContext].PID);
  PlayersStack.Remove(AContext);

{$REGION 'Message Disconnect'}
  Msg := '&4- &6' + PlayerName.Replace(' ', '') + ' &6leave the game';
  Msg := Msg + stringofchar(' ', 64 - length(Msg));
  for Player in PlayersStack.Values do
  begin
    Packet13.Write(Player.Con, Msg);
  end;
{$ENDREGION}
{$REGION 'Player despawn'}
  for Player in PlayersStack.Values do
  begin
    Packet12.Write(Player.Con, PID);
  end;
{$ENDREGION}
end;

class procedure PlayerManager.PlayerIdent(Vers: Byte; UserName: String;
  VerKey: String; AContext: TIdContext);
var
  Player: PlayerStruct;
begin
  Player.UserName := UserName;
  Player.VeryfyKey := VerKey;
  Player.Con := AContext;
  Player.PID := UUID.Dequeue;
  Player.X := 3000;
  Player.Y := 3000;
  Player.Z := 3000;
  PlayerManager.Connect(AContext, Player);
end;

class procedure PlayerManager.Init;
var
  i: ShortInt;
begin
  PlayersStack := TDictionary<TIdContext, PlayerStruct>.Create;
  UUID := TQueue<ShortInt>.Create();
  for i := 0 to 120 do
  begin
    UUID.Enqueue(i);
  end;

end;

end.
