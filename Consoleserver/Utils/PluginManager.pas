unit PluginManager;

interface

Uses System.SysUtils, WinApi.Windows, System.Classes,
  System.Generics.Collections,PlayerHandler, IdGlobal, IdContext;

type
  PluginStruct = record
    Handle: NativeUInt;
    Name: string;
    Description: string;
    Version: string;
    PlugName: Pointer;
    PlugDescription: Pointer;
    PlugVersion: Pointer;
    OnConnect: Pointer;
    OnMessage: Pointer;
    OnPosition: Pointer;
    OnSetBlock: Pointer;

  end;

type
  PluginMgr = class(TObject)
  private
  var
    Init:function(Stack:TDictionary<TIdContext,PlayerStruct>):Boolean; stdcall;


    Name: function(): String; stdcall;
    Description: function(): String; stdcall;
    Version: function(): String; stdcall;
    OnConnect: function(): Boolean; stdcall;
    OnMessage: function(Msg: string; AContext: TIdContext): Boolean; stdcall;
    OnPosition: function(AContext:TIdContext;X,Y,Z:SmallInt; Mode,BId: Byte): Boolean; stdcall;
    OnSetBlock: function(): Boolean; stdcall;


  protected

  public

    function Mess(Msg: string; AContext: TIdContext): Boolean;
    function Pos(AContext:TIdContext;X,Y,Z:SmallInt;Mode,BId:Byte):Boolean;
    constructor Create;

  end;

var
  DllList: TStringList;
  PluginStack: TDictionary<NativeUInt, PluginStruct>;

implementation

constructor PluginMgr.Create;
var
  SR: TSearchRec;
  I: Integer;
  Plugin_Struct: PluginStruct;
begin
  DllList := TStringList.Create;
  PluginStack := TDictionary<NativeUInt, PluginStruct>.Create;
  if FindFirst('Plugins\*.dll', faAnyFile, SR) = 0 then
  begin
    repeat
      DllList.Add(SR.Name);
    until FindNext(SR) <> 0;
    System.SysUtils.FindClose(SR);
  end;
  for I := 0 to DllList.Count - 1 do
  begin
    Plugin_Struct.Handle := LoadLibrary(PWideChar('Plugins\' + DllList[I]));
    if Plugin_Struct.Handle <> 0 then
    begin
      @Name := Nil;
      @Description := Nil;
      @Version := Nil;
      @OnConnect := Nil;
      @OnMessage := Nil;
      @OnPosition := Nil;
      @OnSetBlock := nil;

      Plugin_Struct.PlugName := GetProcAddress(Plugin_Struct.Handle, 'PName');
      Plugin_Struct.PlugDescription := GetProcAddress(Plugin_Struct.Handle,
        'PDescription');
      Plugin_Struct.PlugVersion := GetProcAddress(Plugin_Struct.Handle,
        'PVersion');
      Plugin_Struct.OnConnect := GetProcAddress(Plugin_Struct.Handle,
        'OnConnect');
      Plugin_Struct.OnMessage := GetProcAddress(Plugin_Struct.Handle,
        'OnMessage');
      Plugin_Struct.OnPosition := GetProcAddress(Plugin_Struct.Handle,
        'OnPosition');
      Plugin_Struct.OnSetBlock := GetProcAddress(Plugin_Struct.Handle,
        'OnSetBlock');

      @Name := Plugin_Struct.PlugName;
      @Description := Plugin_Struct.PlugDescription;
      @Version := Plugin_Struct.PlugVersion;
      @OnConnect := Plugin_Struct.OnConnect;
      @OnMessage := Plugin_Struct.OnMessage;
      @OnPosition := Plugin_Struct.OnPosition;
      @OnSetBlock := Plugin_Struct.OnSetBlock;
      @Init:=GetProcAddress(Plugin_Struct.Handle,'Init');
      Plugin_Struct.Name := Name;
      Plugin_Struct.Description := Description;
      Plugin_Struct.Version := Version;

      Init(PlayersStack);

      PluginStack.AddOrSetValue(Plugin_Struct.Handle, Plugin_Struct);
    end;
  end;
end;

Function PluginMgr.Mess;
var
  Plugin_Struct: PluginStruct;
  Trigger: Boolean;
begin
  Trigger := False;
  for Plugin_Struct in PluginStack.Values do
  begin
    @OnMessage := Plugin_Struct.OnMessage;
    if OnMessage(Msg,AContext) = true then
    begin
      Trigger := true;
    end;
  end;
  Result := Trigger;
end;


function PluginMgr.Pos;
var
  Plugin_Struct: PluginStruct;
  Trigger: Boolean;
begin
  Trigger := False;
  for Plugin_Struct in PluginStack.Values do
  begin
  @OnPosition:=Plugin_Struct.OnPosition;
    if OnPosition(AContext,x,y,z,Mode,BId) = true then
    begin
      Trigger := true;
    end;
  end;
  Result := Trigger;
end;


end.
