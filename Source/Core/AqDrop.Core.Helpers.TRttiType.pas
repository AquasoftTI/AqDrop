unit AqDrop.Core.Helpers.TRttiType;

interface

uses
  System.TypInfo,
  System.Rtti,
  AqDrop.Core.Types,
  AqDrop.Core.Collections.Intf;

type
  TAqRttiTypeHelper = class helper for TRttiType
  private
    function VerifyIfIsGeneric: Boolean;
  public
    function GetDataType: TAqDataType;

    function HasAttributeInTheHierarchy<T: TCustomAttribute>: Boolean;

    function GetGenericName: string;
    function GetGenericTypeNames: TArray<string>;

    function GetParameterlessConstructor(out pConstructor: TRttiMethod): Boolean;
    function GetFieldByOffset(const pOffset: NativeInt; out pRttiField: TRttiField): Boolean;

    property IsGeneric: Boolean read VerifyIfIsGeneric;
  end;

  TAqRttiTypeHelperCache = class
  public type
    TFieldByOffsetIndexKey = record
      &Class: PTypeInfo;
      Offset: NativeInt;
    end;
  strict private
    FFieldsByOffset: IAqDictionary<TFieldByOffsetIndexKey, TRttiField>;

    constructor Create;

    class var FInstance: TAqRttiTypeHelperCache;
    class function GetInstance: TAqRttiTypeHelperCache; static;
  private
    class procedure InitializeInstance;
    class procedure ReleaseInstance;
  public
    function GetFieldByOffset(const pKey: TFieldByOffsetIndexKey; out pRttiField: TRttiField): Boolean;
    procedure AddFieldbyOffset(const pKey: TFieldByOffsetIndexKey; const pRttiField: TRttiField);

    class property Instance: TAqRttiTypeHelperCache read GetInstance;
  end;

implementation

uses
  System.SysUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Collections,
  AqDrop.Core.Helpers.TArray,
  AqDrop.Core.Helpers,
  AqDrop.Core.Helpers.TRttiObject,
  AqDrop.Core.Helpers.TRttiTypeName;

{ TAqRttiTypeHelper }

function TAqRttiTypeHelper.GetDataType: TAqDataType;
begin
  Result := TAqDataType.FromTypeInfo(Self.Handle);
end;

function TAqRttiTypeHelper.GetFieldByOffset(const pOffset: NativeInt; out pRttiField: TRttiField): Boolean;
var
  lFields: TArray<TRttiField>;
  lIndex: Int32;
  lCacheKey: TAqRttiTypeHelperCache.TFieldByOffsetIndexKey;
begin
  lCacheKey.&Class := Self.Handle;
  lCacheKey.Offset := pOffset;

  Result := TAqRttiTypeHelperCache.Instance.GetFieldByOffset(lCacheKey, pRttiField);

  if not Result then
  begin
    lFields := GetFields;

    Result := TAqArray<TRttiField>.Find(lFields,
      function(pItem: TRttiField): Boolean
      begin
        Result := (pItem.Offset = pOffset);
      end, lIndex);

    if Result then
    begin
      pRttiField := lFields[lIndex];
      TAqRttiTypeHelperCache.Instance.AddFieldByOffset(lCacheKey, pRttiField);
    end;
  end;
end;

function TAqRttiTypeHelper.GetGenericName: string;
begin
  Result := TAqRttiTypeName.GetGenericName(QualifiedName);
end;

function TAqRttiTypeHelper.GetGenericTypeNames: TArray<string>;
begin
  Result := TAqRttiTypeName.GetGenericTypeNames(QualifiedName);
end;

function TAqRttiTypeHelper.GetParameterlessConstructor(out pConstructor: TRttiMethod): Boolean;
var
  lDataType: TAqDataType;
  lMethods: TArray<TRttiMethod>;
  lIndex: Int32;
begin
  lDataType := GetDataType;
  if lDataType <> TAqDataType.adtClass then
  begin
    raise EAqInternal.CreateFmt('Invalid data type while trying to get the class constructor (%s).',
      [lDataType.ToString]);
  end;

  lMethods := GetMethods;
  Result := TAqArray<TRttiMethod>.Find(lMethods,
    function(pItem: TRttiMethod): Boolean
    begin
      Result := pItem.IsConstructor and (Length(pItem.GetParameters) = 0);
    end, lIndex);

  if Result then
  begin
    pConstructor := lMethods[lIndex];
  end;
end;

function TAqRttiTypeHelper.HasAttributeInTheHierarchy<T>: Boolean;
var
  lType: TRttiType;
begin
  Result := False;
  lType := Self;

  while not Result and Assigned(lType) do
  begin
    Result := lType.HasAttribute<T>;

    if not Result then
    begin
      lType := lType.BaseType;
    end;
  end;
end;

function TAqRttiTypeHelper.VerifyIfIsGeneric: Boolean;
begin
  Result := TAqRttiTypeName.VerifyIfIsGeneric(QualifiedName);
end;

{ TAqRttiTypeHelperCache }

procedure TAqRttiTypeHelperCache.AddFieldbyOffset(const pKey: TFieldByOffsetIndexKey; const pRttiField: TRttiField);
begin
  FFieldsByOffset.BeginWrite;

  try
    if not FFieldsByOffset.ContainsKey(pKey) then
    begin
      FFieldsByOffset.Add(pKey, pRttiField);
    end;
  finally
    FFieldsByOffset.EndWrite;
  end;
end;

constructor TAqRttiTypeHelperCache.Create;
begin
  FFieldsByOffset := TAqDictionary<TFieldByOffsetIndexKey, TRttiField>.Create(TAqLockerType.lktMultiReaderExclusiveWriter);
end;

function TAqRttiTypeHelperCache.GetFieldByOffset(const pKey: TFieldByOffsetIndexKey;
  out pRttiField: TRttiField): Boolean;
begin
  FFieldsByOffset.BeginRead;

  try
    Result := FFieldsByOffset.TryGetValue(pKey, pRttiField);
  finally
    FFieldsByOffset.EndRead;
  end;
end;

class function TAqRttiTypeHelperCache.GetInstance: TAqRttiTypeHelperCache;
begin
  InitializeInstance;

  Result := FInstance;
end;

class procedure TAqRttiTypeHelperCache.InitializeInstance;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TAqRttiTypeHelperCache.Create;
  end;
end;

class procedure TAqRttiTypeHelperCache.ReleaseInstance;
begin
  FreeAndNil(FInstance);
end;

initialization
  TAqRttiTypeHelperCache.InitializeInstance;

finalization
  TAqRttiTypeHelperCache.ReleaseInstance;

end.
