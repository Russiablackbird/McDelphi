unit World;

interface

uses
  System.SysUtils, System.Classes, System.Math, IdGlobal, ZLibExGZ, Extensions,
  Noise;

type
  GlobalWorld = record
    SpawnPos: Vector3;
    MapSize: Vector3;
  end;

type
  WorldMgr = class(TObject)
  public
    class procedure Init;
    class procedure Load;
    class function GetGZipMap: TIdBytes;
    class procedure Save;
    class procedure Generate;
    class function GetTile(x, y, z, grass: Integer): Byte;
  end;

var
  GLWorld: GlobalWorld;
  ZipMap, UnZipMap, SaveMap: TMemoryStream;
  MapArray, CompressMap: TIdBytes;
  MapSize, CompMapSize: Integer;
  seed: _Noise;

implementation

class procedure WorldMgr.Init;
begin
  if FileExists('maps/world.btm') then
  begin
    WorldMgr.Load;
  end
  else
  begin
    WorldMgr.Generate;
  end;

end;

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
  x, y, z: SmallInt;
begin
  Map := TMemoryStream.Create;
  Map.Position := 0;
  x := GLWorld.MapSize.x;
  y := GLWorld.MapSize.y;
  z := GLWorld.MapSize.z;
  data[0] := (((MapSize) and (x * y * z)) shr 24);
  data[1] := (((MapSize) and (x * y * z)) shr 16);
  data[2] := (((MapSize) and (x * y * z)) shr 8);
  data[3] := (((MapSize) and (x * y * z)) shr 0);
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
  SaveMap.WriteData(Swap(GLWorld.MapSize.x));
  SaveMap.WriteData(Swap(GLWorld.MapSize.y));
  SaveMap.WriteData(Swap(GLWorld.MapSize.z));
  SaveMap.WriteData(Swap(GLWorld.SpawnPos.x));
  SaveMap.WriteData(Swap(GLWorld.SpawnPos.x));
  SaveMap.WriteData(Swap(GLWorld.SpawnPos.x));
  SaveMap.WriteData(GLWorld.MapSize.x * GLWorld.MapSize.y * GLWorld.MapSize.z);
  SaveMap.WriteData(MapArray, Length(MapArray));
  SaveMap.Position := 0;
  CompressStream.Position := 0;
  GZCompressStream(SaveMap, CompressStream);
  CompressStream.SaveToFile('maps/out/world.btm');
  SaveMap.Clear;
  SaveMap.Position := 0;
  CompressStream.Free;
  Writeln('Save done');
end;

class procedure WorldMgr.Generate;
var
  seed: _Noise;
  x, y, z: Integer;
  grass: Word;
begin
  x := 0;
  y := 0;
  z := 0;

  GLWorld.MapSize.x := 100; // 256
  GLWorld.MapSize.y := 100;
  GLWorld.MapSize.z := 100;
  MapSize := GLWorld.MapSize.x * GLWorld.MapSize.y * GLWorld.MapSize.z;
  ZipMap := TMemoryStream.Create;
  seed := Noise._Noise.Create;
  seed.Noise(RandomRange(200, MaxInt), GLWorld.MapSize.x, GLWorld.MapSize.z);
  SetLength(MapArray, GLWorld.MapSize.x * GLWorld.MapSize.y *
    GLWorld.MapSize.z);

{$REGION 'MAP'}

  while (x < GLWorld.MapSize.x) do
  begin
    z := 0;
    while (z < GLWorld.MapSize.z) do
    begin
      grass := Trunc(seed.GNoise(x, 0, z, 3, 1, 0.01) * 30) + 64;
      y := 0;
      while (y < GLWorld.MapSize.y) do
      begin
        MapArray[Ext.Index(x, y, z, 100, 100)] := GetTile(x, y, z, grass);
        Inc(y);
      end;
      Inc(z);
    end;

    Inc(x);
  end;
{$ENDREGION}
  Writeln('Generation finish');
end;

class function WorldMgr.GetTile(x: Integer; y: Integer; z: Integer;
  grass: Integer): Byte;
var
  ret: Byte;
  OreNoise, OreLevel, OreNum: Double;
begin
  ret := 0;

  if (y > grass) then
  begin
    Result := ret;
    Exit;
  end;

  if (y = 0) then
  begin
    Result := 7;
    Exit;
  end;

  if (y <= grass) then
  begin

    if (seed.GNoise(x, y, z) > 0.23 + (IfThen(y > 32, (y - 32) * 0.01, 0))) then
    begin
      ret := 0;
    end
    else
    begin
      OreNoise := seed.GNoise(x, y, z, 5, 1, 0.07, 0.7);
      OreLevel := -0.5 - ((IfThen(y > 32, (y - 32) * 0.01, 0)));
      OreNum := (OreNoise - OreLevel) * -10;

      if ((OreNum >= 3) or (OreNum >= 2) or (OreNum >= 1) or (OreNum >= 0)) then
      begin
        ret := 15;
      end
      else
      begin

        if (seed.GNoise(x, y, z, 6, 1, 0.07, 0.7) < 0.005 -
          (IfThen(y > 32, (y - 32) * 0.01, 0))) then
        begin
          ret := 1;
        end

        else

        begin

          if (y = grass) then
          begin
            ret := 2;
          end
          else
          begin
            ret := 3;
          end;

        end;

      end;

    end;

  end;
  Result := ret;
end;

end.
