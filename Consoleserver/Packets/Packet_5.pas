unit Packet_5;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  IdTCPServer,
  IdContext,
  IdGlobal,
  PlayerHandler,
  Extensions,
  World;

type
  Packet5 = class(TObject) // Set Block
  public
    class procedure Read(AContext: TIdContext);
    class procedure Write(AContext: TIdContext; X, Y, Z: SmallInt; BId: Byte);
  end;

implementation

uses
  Server;

class procedure Packet5.Read(AContext: TIdContext);
var
  X, Y, Z: SmallInt;
  Mode, BId: Byte;
  Player: PlayerStruct;
begin

  with AContext.Connection do
  begin
    X := IOHandler.ReadInt16;
    Y := IOHandler.ReadInt16;
    Z := IOHandler.ReadInt16;
    Mode := IOHandler.ReadByte;
    BId := IOHandler.ReadByte;

    if Mode = 0 then
    begin
      // CS.Enter;
      MapArray[Ext.Index(X, Y, Z, GLWorld.MapSize.X, GLWorld.MapSize.Z)] := 0;
      Packet5.Write(AContext, X, Y, Z, 0);
      // CS.Leave;
    end
    else
    begin
      // CS.Enter;
      MapArray[Ext.Index(X, Y, Z, GLWorld.MapSize.X, GLWorld.MapSize.Z)] := BId;
      Packet5.Write(AContext, X, Y, Z, BId);
      // CS.Leave;
    end;

    // CS.Enter;
    for Player in PlayersStack.Values do
    begin
      if Player.Con <> AContext then
      begin
        if Mode = 0 then
        begin
          Packet5.Write(Player.Con, X, Y, Z, 0);
        end
        else
        begin
          Packet5.Write(Player.Con, X, Y, Z, BId);
        end;
      end;

    end;
    // CS.Leave;

  end;

end;

class procedure Packet5.Write(AContext: TIdContext; X, Y, Z: SmallInt;
  BId: Byte);
begin
  with AContext.Connection do
  begin
    CheckForGracefulDisconnect(True);
    IOHandler.Write(6);
    IOHandler.Write(X);
    IOHandler.Write(Y);
    IOHandler.Write(Z);
    IOHandler.Write(BId);
  end;
end;

end.
