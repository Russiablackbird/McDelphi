unit Packet_3;

interface

uses
  System.SysUtils,
  System.Classes,
  IdTCPServer,
  IdContext,
  IdGlobal,
  World,
  ZLibExGZ;

type
  Packet3 = class(TObject) // Level Data Chunk
  public
    class procedure Read(AContext: TIdContext);
    class procedure Write(AContext: TIdContext); overload;
  private
    class procedure Write(AContext: TIdContext; ChunkSize: SmallInt;
      Data: TIdBytes; Percent: Byte); overload;
  end;

implementation

class procedure Packet3.Read(AContext: TIdContext); // client->server
begin

end;

class procedure Packet3.Write(AContext: TIdContext);
var
  Percent: Byte;
  Data: TIdBytes;
  GZ: TMemoryStream;
  Point: Integer;
begin
  GZ := TMemoryStream.Create;
  Point := 0;
  GZ := WorldMgr.GetGZipMap;
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

{$REGION 'MyRegion'}
  // with AContext.Connection do
  // begin

  // Packet4.Write(AContext);

  // Player := PlayersStack.Items[AContext];

  // if FW = true then
  // begin
  // Packet8.Write(AContext, 255, Player.X, Player.Y, Player.Z, Player.Yaw,
  // Player.Pitch);
  // end
  // else
  // begin
  // Packet7.Write(AContext, 255, Player.UserName, Player.X, Player.Y,
  // Player.Z, Player.Yaw, Player.Pitch);
  // end;

  // TempPlayer := PlayersStack.Items[AContext];
  //
  // for Player in PlayersStack.Values do
  // begin
  //
  // if Player.PID <> TempPlayer.PID then
  // begin
  // Packet7.Write(Player.Con, TempPlayer.PID, TempPlayer.UserName,
  // TempPlayer.X, TempPlayer.Y, TempPlayer.Z, TempPlayer.Yaw,
  // TempPlayer.Pitch);
  //
  // Packet7.Write(AContext, Player.PID, Player.UserName, Player.X, Player.Y,
  // Player.Z, Player.Yaw, Player.Pitch);
  //
  // Msg := '&2+ &6' + TempPlayer.UserName.Replace(' ', '') +
  // ' &6joined the game';
  // Msg := Msg + stringofchar(' ', 64 - length(Msg));
  //
  // Packet13.Write(Player.Con, Msg);
  // end;
  //
  // end;

  // end;

{$ENDREGION}
end;

class procedure Packet3.Write(AContext: TIdContext; ChunkSize: SmallInt;
  Data: TIdBytes; Percent: Byte);
begin
  with AContext.Connection do
  begin
    IOHandler.Write(3); // Packet ID
    IOHandler.Write(ChunkSize);
    IOHandler.Write(Data);
    IOHandler.Write(Percent);
  end;
end;

end.
