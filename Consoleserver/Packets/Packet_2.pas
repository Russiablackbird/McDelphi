unit Packet_2;

interface

uses

  IdContext;

type
  Packet2 = class(TObject) // Level Initialize
  public
    class procedure Write(AContext: TIdContext);
  end;

implementation

class procedure Packet2.Write(AContext: TIdContext);
begin
  with AContext.Connection do
  begin
    IOHandler.Write(2); // Packet ID
  end;
end;

end.
