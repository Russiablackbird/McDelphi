program ConsoleServer;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Server in 'Server.pas',
  PlayerHandler in 'PlayerHandler.pas',
  PacketHandler in 'PacketHandler.pas',
  HeartBeat in 'Utils\HeartBeat.pas',
  Config in 'Utils\Config.pas',
  ConsoleMsg in 'Utils\ConsoleMsg.pas',
  ZLibEx in 'Utils\zlib\ZLibEx.pas',
  ZLibExApi in 'Utils\zlib\ZLibExApi.pas',
  ZLibExGZ in 'Utils\zlib\ZLibExGZ.pas',
  World in 'Utils\World.pas',
  Extensions in 'Utils\Extensions.pas',
  Converter in 'Utils\Converter.pas',
  Packet_0 in 'Packets\Packet_0.pas',
  Packet_1 in 'Packets\Packet_1.pas',
  Packet_2 in 'Packets\Packet_2.pas',
  Packet_3 in 'Packets\Packet_3.pas',
  Packet_4 in 'Packets\Packet_4.pas',
  Packet_5 in 'Packets\Packet_5.pas',
  Packet_6 in 'Packets\Packet_6.pas',
  Packet_7 in 'Packets\Packet_7.pas',
  Packet_8 in 'Packets\Packet_8.pas',
  Packet_12 in 'Packets\Packet_12.pas',
  Packet_13 in 'Packets\Packet_13.pas',
  Packet_14 in 'Packets\Packet_14.pas',
  Noise in 'Utils\Noise.pas',
  PluginManager in 'Utils\PluginManager.pas',
  Rapid.Generics in 'Utils\Rapid.Generics.pas';

var
  ServerTrigger: Boolean = True;
  comm: string;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    PlayerManager.init;
    LoadCgf;
    WorldMgr.init;
    Server.Srv.OnCreate(Config.Cgf.ServerPort, Config.Cgf.Max_Players, 5000);
    HeartBeat.Create;
    PrintInfo('Сервер запущен');
    While ServerTrigger do
    begin
      Readln(comm);
      if comm = 'save' then
      begin
        WorldMgr.Save;
      end;
      sleep(1);

    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
