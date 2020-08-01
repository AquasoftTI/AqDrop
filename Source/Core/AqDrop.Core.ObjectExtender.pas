unit AqDrop.Core.ObjectExtender;

interface

uses
  System.SysUtils,
  System.Rtti,
  AqDrop.Core.Collections.Intf;

type
  TAqObjectExtender = class
  strict private
    FExtendedObjects: IAqDictionary<TObject, IAqDictionary<string, TValue>>;

    procedure TryToReleaseExtension(const pValue: TValue);
    procedure ReleaseExtensions(pExtensions: IAqDictionary<string, TValue>);

    class var FDefaultInstance: TAqObjectExtender;
  private
    class procedure InitializeDefaultInstance;
    class procedure ReleaseDefaultInstance;
  public
    constructor Create;
    destructor Destroy; override;

    function Extend<T>(const pObject: TObject; const pIdentifier: string; const pGetter: TFunc<T>): T;
    function TryGetExtension<T>(const pObject: TObject; const pIdentifier: string; out pExtension: T): Boolean;
    function GetExtension<T>(const pObject: TObject; const pIdentifier: string): T;
    procedure FreeObject(const pObject: TObject);

    class property DefaultInstance: TAqObjectExtender read FDefaultInstance;
  end;

implementation

uses
  AqDrop.Core.Generics.Releaser,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Collections;

{ TAqObjectExtender }

constructor TAqObjectExtender.Create;
begin
  FExtendedObjects := TAqDictionary<TObject, IAqDictionary<string, TValue>>.Create(TAqLockerType.lktMultiReaderExclusiveWriter);
end;

destructor TAqObjectExtender.Destroy;
var
  lObjectExtensions: IAqDictionary<string, TValue>;
begin
  for lObjectExtensions in FExtendedObjects.Values do
  begin
    ReleaseExtensions(lObjectExtensions);
  end;

  inherited;
end;

function TAqObjectExtender.Extend<T>(const pObject: TObject; const pIdentifier: string; const pGetter: TFunc<T>): T;
var
  lExtensions: IAqDictionary<string, TValue>;
  lValue: TValue;
begin
  lExtensions := FExtendedObjects.GetOrCreate(pObject,
    function: IAqDictionary<string, TValue>
    begin
      Result := TAqDictionary<string, TValue>.Create;
    end);
  if lExtensions.TryGetValue(pIdentifier, lValue) then
  begin
    Result := lValue.AsType<T>;
  end else
  begin
    Result := pGetter();
    lExtensions.Add(pIdentifier, TValue.From<T>(Result));
  end;
end;

procedure TAqObjectExtender.FreeObject(const pObject: TObject);
var
  lExtensions: IAqDictionary<string, TValue>;
begin
  if FExtendedObjects.LockAndTryGetValue(pObject, lExtensions) then
  begin
    ReleaseExtensions(lExtensions);
    FExtendedObjects.LockAndRemove(pObject);
  end;
end;

function TAqObjectExtender.GetExtension<T>(const pObject: TObject; const pIdentifier: string): T;
begin
  if not TryGetExtension(pObject, pIdentifier, Result) then
  begin
    raise EAqInternal.Create('Extension ' + pIdentifier + ' not found in ' + pObject.ClassName + '.');
  end;
end;

class procedure TAqObjectExtender.InitializeDefaultInstance;
begin
  if not Assigned(FDefaultInstance) then
  begin
    FDefaultInstance := Self.Create;
  end;
end;

class procedure TAqObjectExtender.ReleaseDefaultInstance;
begin
  FreeAndNil(FDefaultInstance);
end;

procedure TAqObjectExtender.ReleaseExtensions(pExtensions: IAqDictionary<string, TValue>);
var
  lExtension: TValue;
begin
  for lExtension in pExtensions.Values do
  begin
    TryToReleaseExtension(lExtension);
  end;
end;

function TAqObjectExtender.TryGetExtension<T>(const pObject: TObject; const pIdentifier: string; out pExtension: T): Boolean;
var
  lExtensions: IAqDictionary<string, TValue>;
  lValue: TValue;
begin
  Result := FExtendedObjects.LockAndTryGetValue(pObject, lExtensions) and lExtensions.TryGetValue(pIdentifier, lValue);

  if Result then
  begin
    pExtension := lValue.AsType<T>;
  end;
end;

procedure TAqObjectExtender.TryToReleaseExtension(const pValue: TValue);
begin
  if pValue.TypeInfo^.Kind = tkClass then
  begin
    TAqGenericReleaser.TryToRelease(pValue.TypeInfo, pValue.AsObject);
  end;
end;

initialization
  TAqObjectExtender.InitializeDefaultInstance;

finalization
  TAqObjectExtender.ReleaseDefaultInstance;

end.
