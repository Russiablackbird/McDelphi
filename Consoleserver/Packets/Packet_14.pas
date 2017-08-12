unit Packet_14;

interface

uses
  System.SysUtils,
  IdTCPServer,
  IdContext,
  IdGlobal;

type
  Packet14 = class(TObject) // disconnect
  public
    class procedure Read(AContext: TIdContext);
    class procedure Write(AContext: TIdContext; Reasons: string);
  end;

implementation

class procedure Packet14.Read(AContext: TIdContext); // client->server
begin

end;

class procedure Packet14.Write(AContext: TIdContext; Reasons: string);

begin
  with AContext.Connection do
  begin
    IOHandler.Write(14);
    Reasons := Reasons + stringofchar(' ', 64 - Length(Reasons));
    IOHandler.Write(Reasons);
  end;
end;

end.
