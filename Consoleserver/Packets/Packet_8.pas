unit Packet_8;

interface

uses
  System.SysUtils,
  IdTCPServer,
  IdContext,
  IdGlobal,
  PlayerHandler;

type
  Packet8 = class(TObject) // Position and Orientation
  public
    class procedure Read(AContext: TIdContext);
    class procedure Write(AContext: TIdContext); overload;
    class procedure Write(AContext: TIdContext; PID: Byte; X, Y, Z: SmallInt;
      Yaw, Pitch: Byte); overload;
  end;

implementation

class procedure Packet8.Read(AContext: TIdContext);
var
  Player: PlayerStruct;
  Unused: Byte;
begin

  with AContext.Connection do
  begin
    Unused := IOHandler.ReadByte;
    Player := PlayersStack.Items[AContext];
    Player.X := IOHandler.ReadInt16;
    Player.Y := IOHandler.ReadInt16;
    Player.Z := IOHandler.ReadInt16;
    Player.Yaw := IOHandler.ReadByte;
    Player.Pitch := IOHandler.ReadByte;
    PlayersStack.AddOrSetValue(AContext, Player);
    Packet8.Write(AContext);
  end;
end;

class procedure Packet8.Write(AContext: TIdContext);
var
  X, Y, Z: SmallInt;
  PID, Yaw, Pitch: Byte;
  Player: PlayerStruct;
begin

  for Player in PlayersStack.Values do
  begin
    if Player.Con <> AContext then
    begin
      PID := Player.PID;
      X := Player.X;
      Y := Player.Y;
      Z := Player.Z;
      Yaw := Player.Yaw;
      Pitch := Player.Pitch;
      Packet8.Write(AContext, PID, X, Y, Z, Yaw, Pitch);
    end;

  end;
end;

class procedure Packet8.Write(AContext: TIdContext; PID: Byte; X: SmallInt;
  Y: SmallInt; Z: SmallInt; Yaw: Byte; Pitch: Byte);
begin

  with AContext.Connection do
  begin
    CheckForGracefulDisconnect(True);
    IOHandler.Write(8);
    IOHandler.Write(PID);
    IOHandler.Write(X);
    IOHandler.Write(Y);
    IOHandler.Write(Z);
    IOHandler.Write(Yaw);
    IOHandler.Write(Pitch);
  end;

end;

end.
