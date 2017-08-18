unit Packet_3;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  System.Classes,
  IdTCPServer,
  IdContext,
  IdGlobal,
  World,
  ZLibExGZ;

type
  Packet3 = class(TObject) // Level Data Chunk
  public
    class procedure Write(AContext: TIdContext); overload;
  private
    class procedure Write(AContext: TIdContext; ChunkSize: SmallInt;
      Data: TIdBytes; Percent: Byte); overload;
  end;

implementation

uses
  Server;

class procedure Packet3.Write(AContext: TIdContext);
var
  Percent: Byte;
  Data: TIdBytes;
  GZ: TMemoryStream;
  Point: Integer;

begin
  GZ := TMemoryStream.Create;
  Point := 0;
  GZ.Position := 0;
  GZ.WriteData(WorldMgr.GetGZipMap, Length(CompressMap));
  GZ.Position := 0;

  while (GZ.Size > Point) do
  begin
    if (Point + 1024 < GZ.Size) then
    begin

      SetLength(Data, 1024);
      GZ.ReadData(Data, 1024);
      Percent := round(Point / GZ.Size * 100);
      Packet3.Write(AContext, 1024, Data, Percent);
    end
    else
    begin
      SetLength(Data, 1024);
      GZ.ReadData(Data, GZ.Size - Point);
      Packet3.Write(AContext, 1024, Data, 100);
      Point := Point + 1024;
    end;
    Point := Point + 1024;
  end;
  GZ.Clear;
  GZ.Free;
  SetLength(CompressMap, 0);
end;

class procedure Packet3.Write(AContext: TIdContext; ChunkSize: SmallInt;
  Data: TIdBytes; Percent: Byte);
begin
  with AContext.Connection do
  begin
    CheckForGracefulDisconnect(True);
    IOHandler.Write(3); // Packet ID
    IOHandler.Write(ChunkSize);
    IOHandler.Write(Data);
    IOHandler.Write(Percent);
  end;
end;

end.
