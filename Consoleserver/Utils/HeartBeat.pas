unit HeartBeat;

interface

uses SysUtils, Classes, Config, ConsoleMsg, IdSSLOpenSSL,
  IdIOHandler, IdComponent, IdHTTP, PlayerHandler;

Procedure Create();

Type
  HeartBeatThread = class(TThread)
    IdSSLIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

Procedure Create();
var
  MyThread: HeartBeatThread;
begin
  MyThread := HeartBeatThread.Create(False);
  MyThread.Priority := tpNormal;
end;

procedure HeartBeatThread.Execute;
var
  HeartBeatHTTP: TIdHTTP;
  Argv: String;
begin
  HeartBeatHTTP := TIdHTTP.Create;
  IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  HeartBeatHTTP.IOHandler := IdSSLIOHandlerSocket;
  HeartBeatHTTP.HandleRedirects := True;
  while True do
  begin
    Argv := ('port=7777&') + ('max=' + IntToStr(Cgf.Max_Players) + '&') +
      ('name=' + Cgf.ServerName + '&') + ('public=True&') + ('version=7&') +
      ('salt=' + Cgf.ServerSalt + '&') + ('users=') +
      IntToStr(PlayersStack.Count + 5);
    // PrintInfo(HeartBeatHTTP.Get
    // ('https://www.classicube.net/heartbeat.jsp?' + Argv));
    HeartBeatHTTP.Get('https://www.classicube.net/heartbeat.jsp?' + Argv);
    Sleep(15000);
  end;
end;

end.
