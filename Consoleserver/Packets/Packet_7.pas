unit Packet_7;

interface

uses
  System.SysUtils,
  IdTCPServer,
  IdContext,
  IdGlobal;

type
  Packet7 = class(TObject) // Spawn Player
  public
    class procedure Read(AContext: TIdContext);
    class procedure Write(AContext: TIdContext); overload;
    class procedure Write(AContext: TIdContext; PID: Byte; UName: string;
      X, Y, Z: SmallInt; Yaw, Pitch: Byte); overload;
  end;

implementation

class procedure Packet7.Read(AContext: TIdContext);
begin
  with AContext.Connection do
  begin

  end;
end;

class procedure Packet7.Write(AContext: TIdContext);
begin

end;

class procedure Packet7.Write(AContext: TIdContext; PID: Byte; UName: string;
  X: SmallInt; Y: SmallInt; Z: SmallInt; Yaw: Byte; Pitch: Byte);
begin

  with AContext.Connection do
  begin
    IOHandler.Write(7);
    IOHandler.Write(PID);
    IOHandler.Write(UName);
    IOHandler.Write(X);
    IOHandler.Write(Y);
    IOHandler.Write(Z);
    IOHandler.Write(Yaw);
    IOHandler.Write(Pitch);
  end;
end;

end.
