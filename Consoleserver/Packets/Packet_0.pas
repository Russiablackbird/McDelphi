unit Packet_0;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  IdTCPServer,
  IdContext,
  IdGlobal,
  PlayerHandler,
  Packet_14;

type
  Packet0 = class(TObject)
  public
    class procedure Read(AContext: TIdContext);
    class procedure Write(AContext: TIdContext; Vers: Byte;
      SName, SMOTD: String; UserType: Byte);

  end;

implementation

uses
  Server;

class procedure Packet0.Read(AContext: TIdContext); // client->server
var
  Vers: Byte;
  UserName: String;
  VerKey: String;
begin
  With AContext.Connection do
  begin
    Vers := IOHandler.ReadByte;
    UserName := IOHandler.ReadString(64, nil);
    VerKey := IOHandler.ReadString(64, nil);
    IOHandler.ReadByte;
  end;
  PlayerManager.PlayerIdent(Vers, UserName, VerKey, AContext);
end;

class procedure Packet0.Write(AContext: TIdContext; Vers: Byte;
  SName, SMOTD: String; UserType: Byte);
begin
  with AContext.Connection do
  begin
    IOHandler.Write(0); // Packet ID
    IOHandler.Write(Vers);
    IOHandler.Write(SName);
    IOHandler.Write(SMOTD);
    IOHandler.Write(UserType);
  end;
end;

end.
