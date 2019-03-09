unit AqDrop.Core.Generics.Arguments;

interface

uses
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Generics.Arguments.Intf;

type
  TAqArguments<TArg1, TArg2> = class(TAqARCObject, IAqArguments<TArg1, TArg2>)
  strict private
    FArg1: TArg1;
    FArg2: TArg2;

    function GetArg1: TArg1;
    function GetArg2: TArg2;
  public
    constructor Create(const pArg1: TArg1; const pArg2: TArg2);
  end;

implementation

{ TAqArguments<TArg1, TArg2> }

constructor TAqArguments<TArg1, TArg2>.Create(const pArg1: TArg1; const pArg2: TArg2);
begin
  FArg1 := pArg1;
  FArg2 := pArg2;
end;

function TAqArguments<TArg1, TArg2>.GetArg1: TArg1;
begin
  Result := FArg1;
end;

function TAqArguments<TArg1, TArg2>.GetArg2: TArg2;
begin
  Result := FArg2;
end;

end.
