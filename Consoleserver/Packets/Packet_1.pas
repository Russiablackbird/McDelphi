unit Packet_1;

interface

uses

  IdContext;

type
  Packet1 = class(TObject) // ping
  public
    class procedure Write(AContext: TIdContext);
  end;

implementation

class procedure Packet1.Write(AContext: TIdContext);
begin
  with AContext.Connection do
  begin
    IOHandler.Write(1); // Packet ID;
  end;
end;

end.
