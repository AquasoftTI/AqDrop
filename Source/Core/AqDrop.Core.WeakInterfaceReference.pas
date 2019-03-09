unit AqDrop.Core.WeakInterfaceReference;

interface

uses
  AqDrop.Core.InterfacedObject;

type
  IAqWeakReference<I: IInterface> = interface
    ['{D568C8D0-05F1-44A2-86FF-F248A57F7510}']

    function GetValue: I;
    property Value: I read GetValue;
  end {$IF CompilerVersion >= 31} deprecated 'Use weak attribute instead.' {$ENDIF};

{$IF CompilerVersion <= 30}
  TAqWeakReference<I: IInterface> = class(TAqARCObject, IAqWeakReference<I>)
  strict private
    FReference: Pointer;

    function GetValue: I;
  public
    constructor Create(pValue: I);

    property Value: I read GetValue;
  end;
{$ENDIF}

implementation

{$IF CompilerVersion <= 30}
uses
  AqDrop.Core.Exceptions,
  System.SysUtils,
  System.TypInfo;

{ TAqWeakReference<I> }

constructor TAqWeakReference<I>.Create(pValue: I);
begin
  FReference := PPointer(@pValue)^;
end;

function TAqWeakReference<I>.GetValue: I;
begin
  if not Supports(IInterface(FReference), GetTypeData(TypeInfo(I))^.GUID, Result) then
  begin
    raise EAqInternal.Create('Invalid interface support.');
  end;
end;
{$ENDIF}

end.
