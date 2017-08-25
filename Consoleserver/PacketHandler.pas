unit PacketHandler;

interface

uses
  System.SyncObjs,
  IdContext,
  PlayerHandler,
  Config;

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
  Packet_5,
  Packet_8,
  Packet_13;

class procedure PacketManager.PacketInput(AContext: TIdContext);
var

  CommandID: Byte;
begin
  CommandID := AContext.Connection.IOHandler.ReadByte;

  if CommandID = 0 then
  begin
    if PlayersStack.Count = Cgf.Max_Players then
    begin
      AContext.Connection.Disconnect;
    end
    else
    begin
      try
        ConnectCS.Enter;
        PlayersStack.lock;
        Packet0.Read(AContext); // Player identification
      finally
        PlayersStack.Unlock;
        ConnectCS.Leave;
      end;
    end;

  end
  else
  begin
    with AContext.Connection do
    begin
      case CommandID of
        5:
          begin
            try
              SetBlockCS.Enter;
              PlayersStack.lock;
              Packet5.Read(AContext); // Set block
            finally
              PlayersStack.Unlock;
              SetBlockCS.Leave;
            end;
          end;
        8:
          begin
            try
              SetPositionCS.Enter;
              PlayersStack.lock;
              Packet8.Read(AContext); // Position and orientation
            finally
              PlayersStack.Unlock;
              SetPositionCS.Leave;
            end;
          end;
        13:
          begin
            try
              OnMessageCS.Enter;
              PlayersStack.lock;
              Packet13.Read(AContext); // read message
            finally
              PlayersStack.Unlock;
              OnMessageCS.Leave;
            end;

          end;
      else
        begin
          AContext.Connection.Disconnect;
        end;
      end;
    end;
  end;
end;

end.
