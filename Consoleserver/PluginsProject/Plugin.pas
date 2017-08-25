unit Plugin;

interface
Uses IdContext;




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








implementation

end.
