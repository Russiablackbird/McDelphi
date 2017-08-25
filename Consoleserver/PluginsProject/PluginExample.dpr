library PluginExample;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections,
  IdContext,
  Structure in 'Structure.pas',
  MessageManager in 'MessageManager.pas';

{$R *.res}

const
  Plugin_Name = 'TestPlugin';
  Plugin_Description = 'This is test plugin';
  Plugin_Version = '0.1';

var
  _MessageManager: Manager;

function PName(): string; stdcall;
begin
  Result := Plugin_Name;
end;

function PDescription(): string; stdcall;
begin
  Result := Plugin_Description;
end;

function PVersion(): string; stdcall;
begin
  Result := Plugin_Version;
end;

function Init(Stack: TDictionary<TIdContext, PlayerStruct>): Boolean; stdcall;

begin
  PlayersStack := Stack;
  Result := True;
end;

/// ///////////////////////////////////
function OnConnect(): Boolean; stdcall;
begin
  Result := False;
end;

function OnMessage(Msg: String; AContext: TIdContext): Boolean; stdcall;

begin
  Result := _MessageManager.CommandHandler(Msg, AContext);
end;

function OnPosition(AContext: TIdContext; X, Y, Z: SmallInt; Mode, BId: Byte)
  : Boolean; stdcall;
begin
  Result := False;
end;

function OnSetBlock(): Boolean; stdcall;
begin
  Result := False;
end;
/// //////////////////////////////////

exports PName, PDescription, PVersion, OnConnect, OnMessage, OnPosition,
  OnSetBlock, Init;

begin

end.
