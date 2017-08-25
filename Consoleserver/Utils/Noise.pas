unit Noise;

interface

uses
  System.SysUtils, System.Math;

type
  _Noise = class(TObject)
  public
    procedure Noise(s, x, z: Integer);
    function GNoise(x, y, z: Integer; o: Integer = 2; a: Double = 1;
      f: Double = 0.04; p: Double = 0.7): Double;
    function NoiseGeneration(x, y, z: Integer): Double;
    function Interpolate(x, y, v: Double): Double; overload;
    function Interpolate(a: Double): Double; overload;
    function Smooth(x, y, z: Double; fir: Boolean; ox, oy, oz: Integer;
      b1, b2, b3, b4, b5, b6, b7, b8: Double): Double;
  end;

var
  Seed: Integer;
  mx, mz: Integer;

implementation

procedure _Noise.Noise(s: Integer; x: Integer; z: Integer);
begin
  Seed := s;
  mx := x;
  mz := z;
end;

function _Noise.GNoise(x: Integer; y: Integer; z: Integer; o: Integer;
  a: Double; f: Double; p: Double): Double;
var
  total: Double;
  ox, oy, oz: Integer;
  b1, b2, b3, b4, b5, b6, b7, b8: Double;
  fir: Boolean;
  I: Integer;
begin
  total := 0.0;

  ox := x;
  oy := y;
  oz := z;

  b1 := 0;
  b2 := 0;
  b3 := 0;
  b4 := 0;
  b5 := 0;
  b6 := 0;
  b7 := 0;
  b8 := 0;

  fir := False;

  I := 0;
  while (I < o) do
  begin

    total := total + Smooth(x * f, y * f, z * f, fir, ox, oy, oz, b1, b2, b3,
      b4, b5, b6, b7, b8) * a;
    f := f * 2;
    a := a * p;
    fir := True;
    Inc(I);
  end;

  if (total < -2.4) then
  begin
    total := -2.4;
  end
  else if (total > 2.4) then
  begin
    total := 2.4;
  end;
  Result := (total / 2.4);

end;

function _Noise.NoiseGeneration(x: Integer; y: Integer; z: Integer): Double;
var
  n: Integer;
begin
  n := (y * mz + z) * mx + x;
  Result := (1.0 - ((n * (n * n * 15731 + 789221) + Seed) and 2147483647) /
    1073741824.0);
end;

function _Noise.Interpolate(x: Double; y: Double; v: Double): Double;
begin
  Result := x * (1 - v) + y * v;
end;

function _Noise.Interpolate(a: Double): Double;
begin
  Result := (1 - Cos(a * Pi)) * 0.5;
end;

function _Noise.Smooth(x: Double; y: Double; z: Double; fir: Boolean;
  ox: Integer; oy: Integer; oz: Integer; b1: Double; b2: Double; b3: Double;
  b4: Double; b5: Double; b6: Double; b7: Double; b8: Double): Double;
var
  n1, n2, n3, n4, n5, n6, n7, n8, i1, i2, i3, i4, i5, i6, v: Double;
  ix, iy, iz: Integer;
  px, py, pz: Integer;
begin
  ix := Trunc(x);
  iy := Trunc(y);
  iz := Trunc(z);
  if ((ix = ox) and (iy = oy) and (iz = oz) and fir) then
  begin
    n1 := b1;
    n2 := b2;
    n3 := b3;
    n4 := b4;
    n5 := b5;
    n6 := b6;
    n7 := b7;
    n8 := b8;
  end

  else

  begin
    px := ix + IfThen((x < 0), -1, 1);
    py := iy + IfThen((y < 0), -1, 1);
    pz := iz + IfThen((z < 0), -1, 1);

    n1 := NoiseGeneration(ix, iy, iz);
    n2 := NoiseGeneration(px, iy, iz);

    n3 := NoiseGeneration(ix, py, iz);
    n4 := NoiseGeneration(px, py, iz);

    n5 := NoiseGeneration(ix, iy, pz);
    n6 := NoiseGeneration(px, iy, pz);
    n7 := NoiseGeneration(ix, py, pz);
    n8 := NoiseGeneration(px, py, pz);

   // b1 := n1;
   // b2 := n2;
    //b3 := n3;
   // b4 := n4;
   // b5 := n5;
   // b6 := n6;
  //  b7 := n7;
  //  b8 := n8;

  end;

  v := Interpolate(x - ix);
  i1 := Interpolate(n1, n2, v);
  i2 := Interpolate(n3, n4, v);
  i4 := Interpolate(n5, n6, v);
  i5 := Interpolate(n7, n8, v);
  v := Interpolate(y - iy);
  i3 := Interpolate(i1, i2, v);
  i6 := Interpolate(i4, i5, v);
  v := Interpolate(z - iz);

  // ox := ix;
  // oy := iy;
  // oz := iz;

  Result := Interpolate(i3, i6, v);
end;

end.
