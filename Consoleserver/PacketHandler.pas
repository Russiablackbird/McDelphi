unit PacketHandler;

interface

uses
  System.SysUtils,
  IdTCPServer,
  IdContext,
  IdGlobal,
  PlayerHandler;

type
  PacketManager = class(TObject)
  public
    class procedure PacketInput(AContext: TIdContext);
  private
  end;

implementation

uses
  Packet_0,
  Packet_1,
  Packet_2,
  Packet_3,
  Packet_4,
  Packet_5,
  Packet_6,
  Packet_7,
  Packet_8,
  Packet_12,
  Packet_13,
  Packet_14;

class procedure PacketManager.PacketInput(AContext: TIdContext);
var
  CommandID: Byte;
  Player: PlayerStruct;
begin
  CommandID := AContext.Connection.IOHandler.ReadByte;

  if CommandID = 0 then
  begin
    Packet0.Read(AContext); // Player identification
  end
  else
  begin

    for Player in PlayersStack.Values do
    begin

      if Player.Con = AContext then
      begin
        case CommandID of
          1:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          2:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          3:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          4:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          5:
            begin
              Packet5.Read(AContext); // Set block
            end;
          6:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          7:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          8:
            begin
              Packet8.Read(AContext); // Position and orientation
            end;
          9:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          10:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          11:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          12:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          13:
            begin
              Packet13.Read(AContext); // чтение сообщения от клиента
            end;
          14:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
          15:
            begin
              AContext.Connection.IOHandler.InputBuffer.Clear;
              AContext.Connection.Disconnect;
            end;
        else
          begin
            AContext.Connection.IOHandler.InputBuffer.Clear;
            AContext.Connection.Disconnect;
          end;
        end;
      end;

    end;

  end;

end;

end.
