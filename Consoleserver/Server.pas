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
  PluginManager,
  Packet_12,
  Packet_13,
  Packet_14;

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
  Plugin_Mgr:PluginMgr;
implementation

procedure Srv.ServerException(AContext: TIdContext; AException: Exception);
begin
  Writeln('Error: ' + AException.Message);
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
  if PlayersStack.ContainsKey(AContext) = True then
  begin
    PlayerManager.Disconnect(AContext);
  end;
end;

constructor Srv.OnCreate(Port, MaxClient, TimeOut: Word);
begin
  inherited Create;
  TCPServer := TIdTCPServer.Create(nil);
  TCPServer.Bindings.Clear;
  TCPServer.DefaultPort := Port;
  TCPServer.Bindings.Add.Port := Port;
  TCPServer.Bindings.Add.IP := '127.0.0.1';
  TCPServer.ListenQueue := 1;
  TCPServer.MaxConnections := MaxClient;
  TCPServer.TerminateWaitTime := TimeOut;
  TCPServer.OnConnect := ServerConnect;
  TCPServer.OnExecute := ServerExecute;
  TCPServer.OnDisconnect := ServerDisconnect;
  TCPServer.OnException := ServerException;
  TCPServer.Active := True;
  Plugin_Mgr:=PluginMgr.Create;
  CS := TCriticalSection.Create;
  CS1 := TCriticalSection.Create;

end;

destructor Srv.OnClose;
begin
  CS.Free;
  CS1.Free;
  Plugin_Mgr.Free;
  TCPServer.Active := False;
end;

end.
