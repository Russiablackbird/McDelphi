unit PacketHandler;

interface

uses
  System.SysUtils,
  IdTCPServer,
  IdContext,
  IdGlobal;

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
begin
  CommandID := AContext.Connection.IOHandler.ReadByte;
  case CommandID of
    0:
      begin
        Packet0.Read(AContext); // Player identification
      end;
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
      Packet13.Read(AContext); // чтение сообщения от клиента
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

end.
