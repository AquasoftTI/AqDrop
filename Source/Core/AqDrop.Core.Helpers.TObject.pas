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

  TAqObjectMapping = class
  strict private
    FFrom: TRttiType;
    FTo: TRttiType;

    FFieldMappings: TObjectList<TAqFieldMapping>;

    class var FLocker: TCriticalSection;
    class var FMappings: TObjectDictionary<string, TAqObjectMapping>;
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
    procedure CloneTo(const pObject: TObject); overload;
    function CloneTo<T: class, constructor>: T; overload;

    function ConvertToJSON(const pDestroySource: Boolean = False): TJSONValue;
  end;

implementation

uses
  Data.DBXJSONReflect;

{ TAqObjectHelper }

procedure TAqObjectHelper.CloneTo(const pObject: TObject);
begin
  TAqObjectMapping.Clone(Self, pObject);
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

function TAqObjectHelper.ConvertToJSON(const pDestroySource: Boolean): TJSONValue;
var
  lMarshal: TJSONMarshal;
begin
  if not Assigned(Self) then
  begin
    Result := TJSONNull.Create;
  end else begin
    try
      lMarshal := TJSONMarshal.Create;

      try
        Result := lMarshal.Marshal(Self);
      finally
        lMarshal.Free;
      end;
    finally
{$IFNDEF AQMOBILE}
      if pDestroySource then
      begin
        Free;
      end;
{$ENDIF}
    end;
  end;
end;

{ TAqObjectMapping }

class procedure TAqObjectMapping.Clone(const pFrom, pTo: TObject);
var
  lMappingName: string;
  lMapping: TAqObjectMapping;
begin
  lMappingName := pFrom.QualifiedClassName + ' X ' + pTo.QualifiedClassName;

  FLocker.Enter;

  try
    if not FMappings.TryGetValue(lMappingName, lMapping) then
    begin
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
  lContext: TRttiContext;
  lFieldFrom: TRttiField;
  lFieldTo: TRttiField;
begin
  FFieldMappings := TObjectList<TAqFieldMapping>.Create;

  lContext := TRttiContext.Create;

  try
    FFrom := lContext.GetType(pFrom);
    FTo := lContext.GetType(pTo);

    for lFieldFrom in FFrom.GetFields do
    begin
      lFieldTo := FTo.GetField(lFieldFrom.Name);

      if Assigned(lFieldTo) then
      begin
        FFieldMappings.Add(TAqFieldMapping.Create(lFieldFrom, lFieldTo));
      end;
    end;
  finally
    lContext.Free;
  end;
end;

destructor TAqObjectMapping.Destroy;
begin
  FFieldMappings.Free;
end;

procedure TAqObjectMapping.Execute(const pFrom, pTo: TObject);
var
  lFieldMapping: TAqFieldMapping;
begin
  for lFieldMapping in FFieldMappings do
  begin
    lFieldMapping.FieldTo.SetValue(Pointer(pTo), lFieldMapping.FieldFrom.GetValue(pFrom));
  end;
end;

class procedure TAqObjectMapping._Finalize;
begin
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
