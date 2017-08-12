unit ConsoleMsg;

interface

uses
  SysUtils;
Procedure PrintWarning(Msg: String);
Procedure PrintError(Msg: String);
Procedure PrintInfo(Msg: String);
Procedure PrintMessage(Msg: String);

implementation

Procedure PrintWarning(Msg: String);
Begin
  Writeln(DateTimeToStr(Now) + ' Warning: ' + Msg);
End;

Procedure PrintError(Msg: String);
Begin
  Writeln(DateTimeToStr(Now) + ' Error: ' + Msg);
End;

Procedure PrintInfo(Msg: String);
Begin
  Writeln(DateTimeToStr(Now) + ' Info: ' + Msg);
End;

Procedure PrintMessage(Msg: String);
Begin
  Writeln(DateTimeToStr(Now) + ' Message: ' + Msg);
End;

end.
