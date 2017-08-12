unit Converter;

interface

uses
  System.SysUtils, classes;

type
  BitConverter = class(TObject)
  public
    class function ToInt16(Arr: array of byte): SmallInt;
    class function ToInt16R(Arr: array of byte): SmallInt;
  end;

implementation

class function BitConverter.ToInt16(Arr: array of byte): SmallInt;
begin
  Result := PSmallInt(@Arr)^;
end;

class function BitConverter.ToInt16R(Arr: array of byte): SmallInt;

begin
  Result := Swap(PSmallInt(@Arr)^);
end;
















// class function Ext.ReadVector3(ST: TMemoryStream): Vector3;
// var
// vector: Vector3;
// X, Y, Z: array [0 .. 1] of Byte;
// begin
// ST.Read(X[1], 1);
// ST.Read(X[0], 1);
//
// ST.Read(Y[1], 1);
// ST.Read(Y[0], 1);
//
// ST.Read(Z[1], 1);
// ST.Read(Z[0], 1);
//
// vector.X := SmallInt(X);
// vector.Y := SmallInt(Y);
// vector.Z := SmallInt(Z);
// Result := vector;
//
// end;

end.
