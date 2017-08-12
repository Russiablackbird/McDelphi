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
    class function GetGZipMap: TMemoryStream;
    class procedure Save();
  end;

var
  GLWorld: GlobalWorld;
  ZipMap, UnZipMap, SaveMap: TMemoryStream;
  MapArray: TIdBytes;

implementation

class procedure WorldMgr.Load;
var
  len: Integer;
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
  UnZipMap.ReadData(len, 4);
  ZipMap.Clear;
  SetLength(MapArray, UnZipMap.Size);
  UnZipMap.Position := 0;
  UnZipMap.ReadData(MapArray, UnZipMap.Size); // считать из потока
{$ENDREGION}
end;

class function WorldMgr.GetGZipMap: TMemoryStream;
var
  MS: TMemoryStream;
  data: array [0 .. 3] of Byte;
  STLength: LongInt;
  X, Y, Z: SmallInt;
begin
  MS := TMemoryStream.Create;
  MS.Position := 0;
  UnZipMap.Position := 16;
  STLength := UnZipMap.Size - UnZipMap.Position;
  X := GLWorld.MapSize.X;
  Y := GLWorld.MapSize.Y;
  Z := GLWorld.MapSize.Z;
  data[0] := (((STLength) and (X * Y * Z)) shr 24);
  data[1] := (((STLength) and (X * Y * Z)) shr 16);
  data[2] := (((STLength) and (X * Y * Z)) shr 8);
  data[3] := (((STLength) and (0)));
  MS.WriteData(data); // записать в поток
  MS.WriteData((Copy(MapArray, 16, STLength)), STLength);
  ZipMap.Clear;
  ZipMap.Position := 0;
  MS.Position := 0;
  GZCompressStream(MS, ZipMap);
  Result := ZipMap;
  MS.Clear;
  MS.Free;
end;

class procedure WorldMgr.Save;
var
CompressStream:TMemoryStream ;
FName:string;
begin
  CompressStream:=TMemoryStream.Create;
  SaveMap.WriteData(Swap(GLWorld.MapSize.X));
  SaveMap.WriteData(Swap(GLWorld.MapSize.Y));
  SaveMap.WriteData(Swap(GLWorld.MapSize.Z));
  SaveMap.WriteData(Swap(GLWorld.SpawnPos.X));
  SaveMap.WriteData(Swap(GLWorld.SpawnPos.X));
  SaveMap.WriteData(Swap(GLWorld.SpawnPos.X));
  SaveMap.WriteData(GLWorld.MapSize.X * GLWorld.MapSize.Y * GLWorld.MapSize.Z);
  SaveMap.WriteData((Copy(MapArray, 16, UnZipMap.Size - 16)),
    UnZipMap.Size - 16);
  SaveMap.Position:=0;
  CompressStream.Position:=0;
  GZCompressStream(SaveMap,CompressStream);
   FName:=DateTimeToStr(Now).Replace('.','_').Replace(' ','_');
  CompressStream.SaveToFile('maps/out/'+FName+'.btm');
  SaveMap.Clear;
  SaveMap.Position:=0;
  CompressStream.Free;
  Writeln('Save done');
end;

end.
