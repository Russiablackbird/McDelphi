unit Packet_14;

interface

uses
  IdContext;

type
  Packet14 = class(TObject) // disconnect
  public
    class procedure Write(AContext: TIdContext; Reasons: string);
  end;

implementation

class procedure Packet14.Write(AContext: TIdContext; Reasons: string);
var
  Msg: string;
begin
  with AContext.Connection do
  begin
    IOHandler.Write(14);
    Msg := Reasons;
    Msg := Msg + stringofchar(' ', 64 - Length(Msg));
    Delete(Reasons, 65, MaxInt);
    IOHandler.Write(Reasons);
  end;
end;

end.
