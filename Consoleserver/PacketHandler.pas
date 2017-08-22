unit PacketHandler;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  System.Threading,
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
  Server,
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

threadvar CommandID: Byte;

var
  Task: ITask;

class procedure PacketManager.PacketInput(AContext: TIdContext);
var
  Player: PlayerStruct;

begin
  CommandID := AContext.Connection.IOHandler.ReadByte;

  if CommandID = 0 then
  begin

    try
      ÑonnectCS.Enter;
      Packet0.Read(AContext); // Player identification
    finally
      ÑonnectCS.Leave;
    end;

  end
  else
  begin
    with AContext.Connection do
    begin

      // for Player in PlayersStack.Values do
      // begin
      // if Player.Con = AContext then
      // begin
      case CommandID of
        5:
          begin
            Packet5.Read(AContext); // Set block
          end;
        8:
          begin
            try
              SetPositionCS.Enter;
              Packet8.Read(AContext); // Position and orientation
            finally
              SetPositionCS.Leave;
            end;
          end;
        13:
          begin
            try
              OnMessageCS.Enter;
              Packet13.Read(AContext); // read message
            finally
              OnMessageCS.Leave;
            end;

          end;
      else
        begin
          try
            CS1.Enter;
            AContext.Connection.Disconnect;
          finally
            CS1.Leave;
          end;

        end;
      end;
      Packet1.Write(AContext);
      // end;
      // end;
    end;
  end;
end;

end.
