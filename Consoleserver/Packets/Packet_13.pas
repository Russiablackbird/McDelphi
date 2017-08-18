unit Packet_13;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  IdTCPServer,
  IdContext,
  IdGlobal,
  PlayerHandler,
  System.RegularExpressions,
  PluginManager;

type
  Packet13 = class(TObject) // Message
  public
    class procedure Read(AContext: TIdContext);
    class procedure Write(AContext: TIdContext; Msg: String);
  end;

implementation

Uses
  Server;

class procedure Packet13.Read(AContext: TIdContext);
var
  Msg, Msg1, Msg2: string;
  Player: PlayerStruct;
  NickName: string;
  m: TMatch;

begin
  // CS.Enter;

   Plugin_Mgr.Mess(Msg,AContext);


  with AContext.Connection do
  begin
    IOHandler.ReadByte;
    Msg := IOHandler.ReadString(64, nil);
    NickName := PlayersStack.Items[AContext].UserName.Replace(' ', '');
    NickName := '&2[' + NickName + ']: &7';

    m := TRegEx.Match(Msg, '[^\s]+');

    while m.Success do
    begin
      Msg1 := Msg1 + ' ' + m.Value;
      m := m.NextMatch;
    end;

    Msg1 := Concat(NickName, Msg1);

    if Length(Msg1) > 64 then
    begin
      Msg2 := Copy(Msg1, 65, Length(Msg1) - 63);
      Msg1 := Msg1.Replace('%', '&');
      Msg2 := Concat('> ', '&7', Msg2);
      Msg2 := Msg2 + stringofchar(' ', 64 - Length(Msg2));
      Msg2 := Msg2.Replace('%', '&');
      Delete(Msg1, 65, MaxInt);
      Delete(Msg2, 65, MaxInt);

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

    end

    else

    begin
      Msg1 := Msg1 + stringofchar(' ', 64 - Length(Msg1));
      Msg1 := Msg1.Replace('%', '&');
      Delete(Msg1, 65, MaxInt);

      for Player in PlayersStack.Values do
      begin
        if Player.Con <> AContext then
        begin
          Packet13.Write(Player.Con, Msg1);
        end;
      end;
      Packet13.Write(AContext, Msg1);
    end;
  end;

  // CS.Leave;
end;

class procedure Packet13.Write(AContext: TIdContext; Msg: string);
begin
  with AContext.Connection do
  begin
    CheckForGracefulDisconnect(True);
    IOHandler.Write(13);
    IOHandler.Write(0);
    IOHandler.Write(Msg);
  end;
end;

end.
