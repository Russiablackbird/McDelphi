unit Extensions;

interface

uses
  System.SysUtils, System.Classes, Converter;

type
  Vector3 = record
    X, Y, Z: SmallInt;
  end;

type
  Ext = class(TObject)
  public
    class function ReadVector3(ST: TMemoryStream): Vector3;
    class function Index(X, Y, Z, length, width: SmallInt): Integer;
  end;

implementation

class function Ext.ReadVector3(ST: TMemoryStream): Vector3;
var
  vector: Vector3;
  X, Y, Z: array [0 .. 1] of Byte;
begin
  ST.Read(X, 2);
  vector.X := BitConverter.ToInt16R(X);
  ST.Read(Y, 2);
  vector.Y := BitConverter.ToInt16R(Y);
  ST.Read(Z, 2);
  vector.Z := BitConverter.ToInt16R(Z);
  Result := vector;
end;

class function Ext.Index(X, Y, Z, length, width: SmallInt): Integer;
begin
  Result := X + Z * width + Y * width * length;
end;

end.
