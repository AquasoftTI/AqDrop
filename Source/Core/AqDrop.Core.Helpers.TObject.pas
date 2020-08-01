unit AqDrop.Core.Helpers.TObject;

{$I '..\Core\AqDrop.Core.Defines.Inc'}

interface

uses
  System.Rtti,
  System.SyncObjs,
  System.Generics.Collections,
{$IF CompilerVersion >= 27} // DXE6+
  System.JSON;
{$ELSE}
  Data.DBXJSON;
{$ENDIF}

type
  TAqFieldMapping = class
  strict private
    FFieldFrom: TRttiField;
    FFieldTo: TRttiField;
  public
    constructor Create(const pFieldFrom, pFieldTo: TRttiField);

    property FieldFrom: TRttiField read FFieldFrom;
    property FieldTo: TRttiField read FFieldTo;
  end;

  {TODO 3 -oTatu -cMelhoria: tirar class method de clone e colocar em classe especializada}
  TAqObjectMapping = class
  strict private
    FFieldMappings: TObjectList<TAqFieldMapping>;

    class var FLocker: TCriticalSection;
    class var FMappings: TObjectDictionary<string, TAqObjectMapping>;
    class var FFieldsToIgnore: TList<TRttiField>;

    class procedure AddDefaultFieldsToIgnoreList;
  private
    class procedure _Initialize;
    class procedure _Finalize;
  public
    constructor Create(const pFrom, pTo: TClass);
    destructor Destroy; override;

    procedure Execute(const pFrom, pTo: TObject);

    class procedure Clone(const pFrom, pTo: TObject);
  end;

  TAqObjectHelper = class helper for TObject
  public
    function CloneTo(const pObject: TObject): TObject; overload;
    function CloneTo<T: class, constructor>: T; overload;
  end;

implementation

uses
  System.SysUtils,
  Data.DBXJSONReflect,
  AqDrop.Core.Types,
  AqDrop.Core.Clonable.Attributes,
  AqDrop.Core.Clonable.Intf,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers.TValue,
  AqDrop.Core.Helpers.TRttiObject,
  AqDrop.Core.Helpers.Rtti,
  AqDrop.Core.Helpers.TRttiType;

{ TAqObjectHelper }

function TAqObjectHelper.CloneTo(const pObject: TObject): TObject;
begin
  TAqObjectMapping.Clone(Self, pObject);
  Result := pObject;
end;

function TAqObjectHelper.CloneTo<T>: T;
begin
  if Assigned(Self) then
  begin
    Result := T.Create;

    try
      Self.CloneTo(Result);
    except
      Result.Free;
      raise;
    end;
  end else begin
    Result := nil;
  end;
end;

{ TAqObjectMapping }

class procedure TAqObjectMapping.AddDefaultFieldsToIgnoreList;
  procedure AddFieldRefCountToIgnoreList;
  var
    lField: TRttiField;
  begin
    lField := TAqRtti.&Implementation.GetType(TInterfacedObject).GetField('FRefCount');

    if not Assigned(lField) then
    begin
      raise EAqInternal.Create('Field FRefCount not found to add to ignored field list to clone.');
    end;

    FFieldsToIgnore.Add(lField);
  end;
begin
  FFieldsToIgnore := TList<TRttiField>.Create;

  AddFieldRefCountToIgnoreList;
end;

class procedure TAqObjectMapping.Clone(const pFrom, pTo: TObject);
var
  lMappingName: string;
  lMapping: TAqObjectMapping;
begin
  lMappingName := pFrom.QualifiedClassName + '|' + pTo.QualifiedClassName;

  FLocker.Enter;

  try
    if not FMappings.TryGetValue(lMappingName, lMapping) then
    begin
      if not Assigned(FFieldsToIgnore) then
      begin
        AddDefaultFieldsToIgnoreList;
      end;

      lMapping := TAqObjectMapping.Create(pFrom.ClassType, pTo.ClassType);
      FMappings.Add(lMappingName, lMapping);
    end;
  finally
    FLocker.Leave;
  end;

  lMapping.Execute(pFrom, pTo);
end;

constructor TAqObjectMapping.Create(const pFrom, pTo: TClass);
var
  lFieldFrom: TRttiField;
  lFieldTo: TRttiField;
  lSameClass: Boolean;
  lFrom: TRttiType;
  lTo: TRttiType;
  lFieldToFound: Boolean;
begin
  FFieldMappings := TObjectList<TAqFieldMapping>.Create;

  lFrom := TAqRtti.&Implementation.GetType(pFrom);

  lSameClass := pFrom = pTo;

  lTo := nil;
  if not lSameClass then
  begin
    lTo := TAqRtti.&Implementation.GetType(pTo);
  end;

  for lFieldFrom in lFrom.GetFields do
  begin
    if (FFieldsToIgnore.IndexOf(lFieldFrom) < 0) and not lFieldFrom.HasAttribute<AqCloneOff> then
    begin
      if lSameClass then
      begin
        lFieldTo := lFieldFrom;
        lFieldToFound := True;
      end else begin
        lFieldTo := lTo.GetField(lFieldFrom.Name);
        lFieldToFound := Assigned(lFieldTo) and (FFieldsToIgnore.IndexOf(lFieldTo) < 0) and
          not lFieldTo.HasAttribute<AqCloneOff>;
      end;

      if lFieldToFound then
      begin
        FFieldMappings.Add(TAqFieldMapping.Create(lFieldFrom, lFieldTo));
      end;
    end;
  end;
end;

destructor TAqObjectMapping.Destroy;
begin
  FFieldMappings.Free;
end;

procedure TAqObjectMapping.Execute(const pFrom, pTo: TObject);
var
  lFieldMapping: TAqFieldMapping;
  lInterfaceFrom: IInterface;
  lInterfaceTo: IInterface;
  lClonableFrom: IAqClonable;
  lClonableTo: IAqClonable;
  lValueFrom: TValue;
begin
  for lFieldMapping in FFieldMappings do
  begin
    if lFieldMapping.FieldTo.FieldType.GetDataType = TAqDataType.adtClass then
    begin
      {TODO 3 -oTatu -cMelhoria: estudar a necessidade de verificar se as object implementa iaqclonable, exemplo: Fdeleteditens de um detalhe}

      if lFieldMapping.FieldTo.GetValue(pTo).AsObject = nil then
      begin
        lFieldMapping.FieldTo.SetValue(pTo, lFieldMapping.FieldFrom.GetValue(pFrom));
      end;
    end else if lFieldMapping.FieldTo.FieldType.GetDataType = TAqDataType.adtInterface then
    begin
      lValueFrom := lFieldMapping.FieldFrom.GetValue(pFrom);
      lInterfaceFrom := lValueFrom.AsInterface;
      lInterfaceTo := lFieldMapping.FieldTo.GetValue(pTo).AsInterface;

      if Assigned(lInterfaceFrom) then
      begin
        if not Assigned(lInterfaceTo) then
        begin
          lFieldMapping.FieldTo.SetValue(pTo, lValueFrom);
        end else if Supports(lInterfaceFrom, IAqClonable, lClonableFrom) and
          Supports(lInterfaceTo, IAqClonable, lClonableTo) then
        begin
          lClonableFrom.CloneTo(lClonableTo);
        end;
      end;
    end else begin
      lFieldMapping.FieldTo.SetValue(pTo,
        lFieldMapping.FieldFrom.GetValue(pFrom).ConvertTo(lFieldMapping.FieldTo.FieldType.Handle));
    end;
  end;
end;

class procedure TAqObjectMapping._Finalize;
begin
  FFieldsToIgnore.Free;
  FMappings.Free;
  FLocker.Free;
end;

class procedure TAqObjectMapping._Initialize;
begin
  FLocker := TCriticalSection.Create;
  FMappings := TObjectDictionary<string, TAqObjectMapping>.Create([doOwnsValues]);
end;

{ TAqFieldMapping }

constructor TAqFieldMapping.Create(const pFieldFrom, pFieldTo: TRttiField);
begin
  FFieldFrom := pFieldFrom;
  FFieldTo := pFieldTo;
end;

initialization
  TAqObjectMapping._Initialize;

finalization
  TAqObjectMapping._Finalize;

end.
