unit Packet_14;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  IdTCPServer,
  IdContext,
  IdGlobal;

type
  Packet14 = class(TObject) // disconnect
  public
    class procedure Write(AContext: TIdContext; Reasons: string);
  end;

implementation

uses
  Server;

class procedure Packet14.Write(AContext: TIdContext; Reasons: string);

begin
  with AContext.Connection do
  begin
    IOHandler.Write(14);
    Reasons := Reasons + stringofchar(' ', 64 - Length(Reasons));
    Delete(Reasons, 65, MaxInt);
    IOHandler.Write(Reasons);
    Disconnect;
  end;
end;

end.
