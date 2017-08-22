unit Server;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  IdTCPServer,
  IdContext,
  IdGlobal,
  PacketHandler,
  PlayerHandler,
  PluginManager;

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
  CS: TCriticalSection;
  CS1: TCriticalSection;
  ÑonnectCS: TCriticalSection;
  SetBlockCS: TCriticalSection;
  SetPositionCS: TCriticalSection;
  OnMessageCS: TCriticalSection;

  _PluginMgr: PluginMgr;

implementation

procedure Srv.ServerException(AContext: TIdContext; AException: Exception);
begin
  Writeln('Error: ' + AException.Message);
  CS1.Leave;
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
    CS.Enter;
    if PlayersStack.ContainsKey(AContext) = True then
    begin
      PlayerManager.Disconnect(AContext);
    end;
  finally
    CS.Leave;
  end;

end;

constructor Srv.OnCreate(Port, MaxClient, TimeOut: Word);
begin
  inherited Create;

  _PluginMgr := PluginMgr.Create;

  TCPServer := TIdTCPServer.Create(nil);
  TCPServer.Bindings.Clear;
  TCPServer.DefaultPort := Port;
  TCPServer.Bindings.Add.Port := Port;
  TCPServer.Bindings.Add.IP := '127.0.0.1';
  TCPServer.ListenQueue := 1;
  TCPServer.MaxConnections := MaxClient;
  TCPServer.TerminateWaitTime := 10000;
  TCPServer.OnConnect := ServerConnect;
  TCPServer.OnExecute := ServerExecute;
  TCPServer.OnDisconnect := ServerDisconnect;
  TCPServer.OnException := ServerException;
  TCPServer.Active := True;

  CS := TCriticalSection.Create;
  CS1 := TCriticalSection.Create;
  ÑonnectCS := TCriticalSection.Create;
  SetBlockCS := TCriticalSection.Create;
  SetPositionCS := TCriticalSection.Create;
  OnMessageCS := TCriticalSection.Create;
end;

destructor Srv.OnClose;
begin
  // CS.Free;
  // CS1.Free;
  ÑonnectCS.Free;
  SetBlockCS.Free;
  SetPositionCS.Free;
  OnMessageCS.Free;
  TCPServer.Active := False;
end;

end.
