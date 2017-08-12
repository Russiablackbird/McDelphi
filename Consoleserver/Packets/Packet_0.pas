unit Packet_0;

interface

uses
  System.SysUtils,
  IdTCPServer,
  IdContext,
  IdGlobal,
  PlayerHandler,
  System.Generics.Defaults,
  System.Generics.Collections;

type
  Packet0 = class(TObject)
  public
    class procedure Read(AContext: TIdContext);
    class procedure Write(AContext: TIdContext; Vers: Byte;
      SName, SMOTD: String; UserType: Byte);

  end;

implementation

class procedure Packet0.Read(AContext: TIdContext); // client->server
var
  Vers: Byte;
  UserName: String;
  VerKey: String;
begin
  With AContext.Connection do
  begin
    While not IOHandler.InputBuffer.Size >= 130 do // 130 ровно
    begin

    end;
    Vers := IOHandler.ReadByte;
    UserName := IOHandler.ReadString(64, nil);
    VerKey := IOHandler.ReadString(64, nil);
    IOHandler.ReadByte;
    PlayerManager.PlayerIdent(Vers, UserName, VerKey, AContext);
  end;
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
