unit Packet_1;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  IdTCPServer,
  IdContext,
  IdGlobal;

type
  Packet1 = class(TObject) // ping
  public
    class procedure Write(AContext: TIdContext);
  end;

implementation

uses
  Server;

class procedure Packet1.Write(AContext: TIdContext);
begin
  CS.Enter;
  with AContext.Connection do
  begin
    CheckForGracefulDisconnect(True);
    IOHandler.Write(1); // Packet ID;
  end;
  CS.Leave;
end;

end.
