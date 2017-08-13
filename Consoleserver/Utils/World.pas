unit World;

interface

uses
  System.SysUtils, System.Classes, IdGlobal, ZLibExGZ, Extensions;

type
  GlobalWorld = record
    SpawnPos: Vector3;
    MapSize: Vector3;
  end;

type
  WorldMgr = class(TObject)
  public
    class procedure Load;
    class function GetGZipMap: TIdBytes;
    class procedure Save();
  end;

var
  GLWorld: GlobalWorld;
  ZipMap, UnZipMap, SaveMap: TMemoryStream;
  MapArray, CompressMap: TIdBytes;
  MapSize, CompMapSize: Integer;

implementation

class procedure WorldMgr.Load;
begin
  ZipMap := TMemoryStream.Create;
  UnZipMap := TMemoryStream.Create;
  SaveMap := TMemoryStream.Create;
{$REGION 'Unpack'}
  ZipMap.LoadFromFile('maps/world.btm');
  ZipMap.Position := 0;
  UnZipMap.Position := 0;
  GZDecompressStream(ZipMap, UnZipMap);
  UnZipMap.Position := 0;
  GLWorld.MapSize := Ext.ReadVector3(UnZipMap);
  GLWorld.SpawnPos := Ext.ReadVector3(UnZipMap);
  UnZipMap.ReadData(MapSize, 4);
  ZipMap.Clear;
  SetLength(MapArray, MapSize);
  UnZipMap.Position := 16;
  UnZipMap.ReadData(MapArray, MapSize); // считать из потока
  UnZipMap.Free;
{$ENDREGION}
end;

class function WorldMgr.GetGZipMap: TIdBytes;
var
  Map: TMemoryStream;
  data: array [0 .. 3] of Byte;
  X, Y, Z: SmallInt;
begin
  Map := TMemoryStream.Create;
  Map.Position := 0;
  X := GLWorld.MapSize.X;
  Y := GLWorld.MapSize.Y;
  Z := GLWorld.MapSize.Z;
  data[0] := (((MapSize) and (X * Y * Z)) shr 24);
  data[1] := (((MapSize) and (X * Y * Z)) shr 16);
  data[2] := (((MapSize) and (X * Y * Z)) shr 8);
  data[3] := (((MapSize) and (0)));

  Map.WriteData(data); // записать в поток
  Map.WriteData(MapArray, MapSize);
  Map.Position := 0;

  GZCompressStream(Map, ZipMap);
  SetLength(CompressMap, ZipMap.Size);
  ZipMap.Position := 0;
  ZipMap.ReadData(CompressMap, ZipMap.Size);
  ZipMap.Clear;
  Result := CompressMap;
  Map.Free;
end;

class procedure WorldMgr.Save;
var
  CompressStream: TMemoryStream;
begin
  CompressStream := TMemoryStream.Create;
  SaveMap.WriteData(Swap(GLWorld.MapSize.X));
  SaveMap.WriteData(Swap(GLWorld.MapSize.Y));
  SaveMap.WriteData(Swap(GLWorld.MapSize.Z));
  SaveMap.WriteData(Swap(GLWorld.SpawnPos.X));
  SaveMap.WriteData(Swap(GLWorld.SpawnPos.X));
  SaveMap.WriteData(Swap(GLWorld.SpawnPos.X));
  SaveMap.WriteData(GLWorld.MapSize.X * GLWorld.MapSize.Y * GLWorld.MapSize.Z);
  SaveMap.WriteData((Copy(MapArray, 16, UnZipMap.Size - 16)),
    UnZipMap.Size - 16);
  SaveMap.Position := 0;
  CompressStream.Position := 0;
  GZCompressStream(SaveMap, CompressStream);
  CompressStream.SaveToFile('maps/out/world.btm');
  SaveMap.Clear;
  SaveMap.Position := 0;
  CompressStream.Free;
  Writeln('Save done');
end;

end.
