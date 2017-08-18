unit Structure;

interface

Uses System.SysUtils,
  System.Classes,
  System.Generics.Defaults,
  System.Generics.Collections,
  IdContext;

type
  PlayerStruct = record
    Con: TIdContext;
    UserName: String;
    VeryfyKey: String;
    IP: String;
    Port: Word;
    X: SmallInt; // SHORT
    Y: SmallInt; // SHORT
    Z: SmallInt; // SHORT
    Yaw: Byte;
    Pitch: Byte;
    Op: Byte;
    PID: Byte; // Only Byte;
    Spawned: Boolean;
  end;



var

PlayersStack: TDictionary<TIdContext, PlayerStruct>;

implementation

end.
