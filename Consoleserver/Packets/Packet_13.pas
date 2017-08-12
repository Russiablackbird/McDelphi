unit Packet_13;

interface

uses
  System.SysUtils,
  IdTCPServer,
  IdContext,
  IdGlobal,
  PlayerHandler;

type
  Packet13 = class(TObject) // Message
  public
    class procedure Read(AContext: TIdContext);
    class procedure Write(AContext: TIdContext; Msg: String);
  end;

implementation

class procedure Packet13.Read(AContext: TIdContext);
var
  Msg, Msg1, Msg2: string;
  Player: PlayerStruct;
  NickName: string;
begin
  with AContext.Connection do
  begin

    IOHandler.ReadByte;
    Msg := IOHandler.ReadString(64, nil);
    NickName := PlayersStack.Items[AContext].UserName.Replace(' ', '');
    NickName := '&2[' + NickName + ']: &7';
    Msg1 := Copy(Msg, 0, 64 - length(NickName));
    Msg2 := Copy(Msg, length(Msg1), 64);
    Msg1 := Concat(NickName, Msg1);
    Msg2 := Concat('&7', Msg2);
    Msg2 := Msg2 + stringofchar(' ', 64 - length(Msg2));

    for Player in PlayersStack.Values do
    begin
      if Player.Con <> AContext then
      begin
        Packet13.Write(Player.Con, Msg1);
        Packet13.Write(Player.Con, Msg2);
      end;
    end;

    Packet13.Write(AContext, Msg1);
    Packet13.Write(AContext, Msg2);
  end;
end;

class procedure Packet13.Write(AContext: TIdContext; Msg: string);
begin
  with AContext.Connection do
  begin
    IOHandler.Write(13);
    IOHandler.Write(0);
    IOHandler.Write(Msg);
  end;
end;

end.
