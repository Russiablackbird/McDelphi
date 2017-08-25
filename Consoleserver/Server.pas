unit Server;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  IdTCPServer,
  IdContext,
  IdGlobal,
  PacketHandler,
  PlayerHandler;

type
  Srv = class(TObject)
  public
    TCPServer: TIdTCPServer;

    constructor OnCreate(Port, MaxClient, TimeOut: Word);
    destructor OnClose();
    procedure ServerExecute(AContext: TIdContext);
    procedure ServerConnect(AContext: TIdContext);
    procedure ServerDisconnect(AContext: TIdContext);
    procedure ServerException(AContext: TIdContext; AException: Exception);
  private

  end;

var

  ConnectCS: TCriticalSection;
  SetBlockCS: TCriticalSection;
  SetPositionCS: TCriticalSection;
  OnMessageCS: TCriticalSection;
  DisconnectCS: TCriticalSection;

  DictionaryCS: TCriticalSection;
  UUIDCS: TCriticalSection;

implementation

procedure Srv.ServerException(AContext: TIdContext; AException: Exception);
begin

end;

procedure Srv.ServerExecute(AContext: TIdContext);
begin
  PacketHandler.PacketManager.PacketInput(AContext);
end;

procedure Srv.ServerConnect(AContext: TIdContext);
begin

end;

procedure Srv.ServerDisconnect(AContext: TIdContext);
begin

  try
    DisconnectCS.Enter;
    if PlayersStack.ContainsKey(AContext) = True then
    begin
      PlayerManager.Disconnect(AContext);
    end;
  finally
    begin
      DisconnectCS.Leave;
    end;
  end;

end;

constructor Srv.OnCreate(Port, MaxClient, TimeOut: Word);
begin
  TCPServer := TIdTCPServer.Create(nil);
  TCPServer.Bindings.Clear;
  TCPServer.DefaultPort := Port;
  TCPServer.Bindings.Add.Port := Port;
  TCPServer.Bindings.Add.IP := '127.0.0.1';
  TCPServer.ListenQueue := 0;
  TCPServer.MaxConnections := MaxClient - 1;
  TCPServer.TerminateWaitTime := 10000;
  TCPServer.OnConnect := ServerConnect;
  TCPServer.OnExecute := ServerExecute;
  TCPServer.OnDisconnect := ServerDisconnect;
  TCPServer.OnException := ServerException;
  TCPServer.Active := True;

  ConnectCS := TCriticalSection.Create;
  DisconnectCS := TCriticalSection.Create;
  SetBlockCS := TCriticalSection.Create;
  SetPositionCS := TCriticalSection.Create;
  OnMessageCS := TCriticalSection.Create;

  DictionaryCS := TCriticalSection.Create;
  UUIDCS := TCriticalSection.Create;

end;

destructor Srv.OnClose;
begin

  ConnectCS.Free;
  SetBlockCS.Free;
  SetPositionCS.Free;
  OnMessageCS.Free;

  TCPServer.Active := False;
end;

end.
