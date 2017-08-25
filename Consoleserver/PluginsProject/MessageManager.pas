unit MessageManager;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections,
  System.RegularExpressions,
  IdContext,
  IdGlobal,
  Structure;

type
  Manager = class(TObject)
  Public
    Function CommandHandler(Msg: String; AContext: TIdContext): Boolean;
  Private
    Procedure HelpMsg(AContext: TIdContext);
    Procedure Teleport(Msg: string; AContext: TIdContext);
  end;

Const
  CMD_HELP = '/help';
  CMD_TP = '/tp';
  Cmd: Array [0 .. 1] of String = (CMD_HELP, CMD_TP);

implementation

function Manager.CommandHandler(Msg: string; AContext: TIdContext): Boolean;
var
  m: TMatch;
  res: Boolean;
begin
  res := True;
  m := TRegEx.Match(Msg, '[^\s]+');

  case AnsiIndexStr(LowerCase(m.Value), Cmd) of
    0:
      begin
        Self.HelpMsg(AContext);
      end;

    1:
      begin
        m := m.NextMatch;
        if m.Value = '' then
        begin
          res := False;
        end
        else
        begin
          // Writeln(m.Value);
          Self.Teleport(m.Value, AContext);
        end;

      end;

  else
    begin
      res := False;
    end;
  end;

  Result := res;
end;

procedure Manager.HelpMsg(AContext: TIdContext);
var
  i: Integer;
  Msg: string;
  CmdList: TStringList;
begin
  try
    CmdList := TStringList.Create;
{$REGION 'Command list'}
    Msg := '&3Commands by the plugin TestPlugin';
    Msg := Msg + stringofchar(' ', 64 - Length(Msg));
    CmdList.Add(Msg);
    Msg := '';

    Msg := '&a/help';
    Msg := Msg + stringofchar(' ', 64 - Length(Msg));
    CmdList.Add(Msg);
    Msg := '';

    Msg := '&a/tp';
    Msg := Msg + stringofchar(' ', 64 - Length(Msg));
    CmdList.Add(Msg);
    Msg := '';

{$ENDREGION}
    for i := 0 to CmdList.Count - 1 do
    begin
      with AContext.Connection do
      begin
        CheckForGracefulDisconnect(True);
        IOHandler.Write(13);
        IOHandler.Write(0);
        IOHandler.Write(CmdList[i]);
      end;
    end;

  finally
    CmdList.Free;
  end;
end;

procedure Manager.Teleport(Msg: string; AContext: TIdContext);
var
  Player: PlayerStruct;
  gg: string;
  X: TIdBytes;
  Y: TIdBytes;
  Z: TIdBytes;

begin

  if LowerCase(Msg) <> '/tp' then
  begin

    for Player in PlayersStack.Values do
    begin
      if Msg = Player.UserName.Replace(' ', '') then
      begin
        SetLength(X, 2);
        SetLength(Y, 2);
        SetLength(Z, 2);


         X[1] := Player.X shr 0;
         X[0] := Player.X shr 8;

         Y[1] := Player.Y shr 0;
         Y[0] := Player.Y shr 8;

         Z[1] := Player.Z shr 0;
         Z[0] := Player.Z shr 8;

        try

          with AContext.Connection do
          begin
            IOHandler.Write(8);
            IOHandler.Write(255);
            IOHandler.Write(X);
            IOHandler.Write(Y);
            IOHandler.Write(Z);
            IOHandler.Write(Player.YAW);
            IOHandler.Write(Player.PITCH);
          end;

        except
          on E: Exception do
            gg := E.Message;

        end;

      end;
    end;

  end;

end;

end.
