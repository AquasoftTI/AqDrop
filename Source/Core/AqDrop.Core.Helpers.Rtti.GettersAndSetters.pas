unit AqDrop.Core.Helpers.Rtti.GettersAndSetters;

interface

uses
  System.Rtti,
  System.SysUtils,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Helpers.Rtti.GettersAndSetters.Intf;

type
  TAqRttiValueGetter = class(TAqARCObject, IAqRttiValueGetter)
  public
    function GetValue(const pInstance: Pointer): TValue; virtual; abstract;
  end;

  TAqRttiFieldValueGetter = class(TAqRttiValueGetter)
  strict private
    FField: TRttiField;
  public
    constructor Create(const pField: TRttiField);

    function GetValue(const pInstance: Pointer): TValue; override;
  end;

  TAqRttiPropertyValueGetter = class(TAqRttiValueGetter)
  strict private
    FProperty: TRttiProperty;
  public
    constructor Create(const pProperty: TRttiProperty);

    function GetValue(const pInstance: Pointer): TValue; override;
  end;

  TAqRttiRegisteredsValueGetter = class
  strict private
    FRegisteredGetters: IAqDictionary<string, IAqRttiValueGetter>;

    class var FDefaultInstance: TAqRttiRegisteredsValueGetter;
    class function GetDefaultInstance: TAqRttiRegisteredsValueGetter; static;
  private
    class procedure InitializeDefaultInstance;
    class procedure ReleaseDefaultInstance;
  public
    constructor Create;

    function GetValue(const pID: string; const pInstance: Pointer;
      const pCreateNewGetterFunction: TFunc<IAqRttiValueGetter>): TValue;

    class property DefaultInstance: TAqRttiRegisteredsValueGetter read GetDefaultInstance;
  end;

  TAqRttiValueSetter = class(TAqARCObject, IAqRttiValueSetter)
  public
    procedure SetValue(const pInstance: Pointer; const pValue: TValue); virtual; abstract;
  end;

  TAqRttiFieldValueSetter = class(TAqRttiValueSetter)
  strict private
    FField: TRttiField;
  public
    constructor Create(const pField: TRttiField);

    procedure SetValue(const pInstance: Pointer; const pValue: TValue); override;
  end;

  TAqRttiPropertyValueSetter = class(TAqRttiValueSetter)
  strict private
    FProperty: TRttiProperty;
  public
    constructor Create(const pProperty: TRttiProperty);

    procedure SetValue(const pInstance: Pointer; const pValue: TValue); override;
  end;


implementation

uses
  AqDrop.Core.Exceptions,
  AqDrop.Core.Collections;

{ TAqRttiRegisteredsValueGetter }

constructor TAqRttiRegisteredsValueGetter.Create;
begin
  FRegisteredGetters := TAqDictionary<string, IAqRttiValueGetter>.Create(TAqLockerType.lktMultiReadeExclusiveWriter);
end;

class function TAqRttiRegisteredsValueGetter.GetDefaultInstance: TAqRttiRegisteredsValueGetter;
begin
  InitializeDefaultInstance;

  Result := FDefaultInstance;
end;

function TAqRttiRegisteredsValueGetter.GetValue(const pID: string; const pInstance: Pointer;
  const pCreateNewGetterFunction: TFunc<IAqRttiValueGetter>): TValue;
var
  lGetter: IAqRttiValueGetter;
begin
  FRegisteredGetters.BeginWrite;

  try
    if not FRegisteredGetters.TryGetValue(pID, lGetter) then
    begin
      lGetter := pCreateNewGetterFunction;
      FRegisteredGetters.Add(pID, lGetter);
    end;
  finally
    FRegisteredGetters.EndWrite;
  end;

  Result := lGetter.GetValue(pInstance);
end;

class procedure TAqRttiRegisteredsValueGetter.InitializeDefaultInstance;
begin
  if not Assigned(FDefaultInstance) then
  begin
    FDefaultInstance := TAqRttiRegisteredsValueGetter.Create;
  end;
end;

class procedure TAqRttiRegisteredsValueGetter.ReleaseDefaultInstance;
begin
  FreeAndNil(FDefaultInstance);
end;

{ TAqRttiFieldValueGetter }

constructor TAqRttiFieldValueGetter.Create(const pField: TRttiField);
begin
  FField := pField;
end;

function TAqRttiFieldValueGetter.GetValue(const pInstance: Pointer): TValue;
begin
  Result := FField.GetValue(pInstance);
end;

{ TAqRttiPropertyValueGetter }

constructor TAqRttiPropertyValueGetter.Create(const pProperty: TRttiProperty);
begin
  FProperty := pProperty;
end;

function TAqRttiPropertyValueGetter.GetValue(const pInstance: Pointer): TValue;
begin
  Result := FProperty.GetValue(pInstance);
end;

{ TAqRttiFieldValueSetter }

constructor TAqRttiFieldValueSetter.Create(const pField: TRttiField);
begin
  FField := pField;
end;

procedure TAqRttiFieldValueSetter.SetValue(const pInstance: Pointer; const pValue: TValue);
begin
  FField.SetValue(pInstance, pValue);
end;

{ TAqRttiPropertyValueSetter }

constructor TAqRttiPropertyValueSetter.Create(const pProperty: TRttiProperty);
begin
  FProperty := pProperty;
end;

procedure TAqRttiPropertyValueSetter.SetValue(const pInstance: Pointer; const pValue: TValue);
begin
  if not FProperty.IsWritable then
  begin
    raise EAqInternal.CreateFmt('Property %s is not writable.', [FProperty.Name]);
  end;

  FProperty.SetValue(pInstance, pValue);
end;

initialization
  TAqRttiRegisteredsValueGetter.InitializeDefaultInstance;

finalization
  TAqRttiRegisteredsValueGetter.ReleaseDefaultInstance;

end.
