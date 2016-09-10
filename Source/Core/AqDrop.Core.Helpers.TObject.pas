unit AqDrop.Core.Helpers.TObject;

interface

uses
  System.Rtti,
  AqDrop.Core.Collections;

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
    FFieldMappings: TAqList<TAqFieldMapping>;

    class var FMappings: TAqDictionary<string, TAqObjectMapping>;
  public
    class constructor Create;
    class destructor Destroy;

    constructor Create(const pFrom, pTo: TClass);
    destructor Destroy; override;

    procedure Execute(const pFrom, pTo: TObject);

    class procedure Clone(const pFrom, pTo: TObject);
  end;

  TAqObjectHelper = class helper for TObject
  public
    procedure CloneTo(const pObject: TObject); overload;
    function CloneTo<T: class, constructor>: T; overload;
  end;

implementation

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

{ TAqObjectMapping }

class procedure TAqObjectMapping.Clone(const pFrom, pTo: TObject);
var
  lMappingName: string;
  lMapping: TAqObjectMapping;
begin
  lMappingName := pFrom.QualifiedClassName + ' X ' + pTo.QualifiedClassName;

  FMappings.Lock;

  try
    if not FMappings.TryGetValue(lMappingName, lMapping) then
    begin
      lMapping := TAqObjectMapping.Create(pFrom.ClassType, pTo.ClassType);
      FMappings.Add(lMappingName, lMapping);
    end;
  finally
    FMappings.Release;
  end;

  lMapping.Execute(pFrom, pTo);
end;

class constructor TAqObjectMapping.Create;
begin
  FMappings := TAqDictionary<string, TAqObjectMapping>.Create([TAqDictionaryContent.adcValue], True);
end;

class destructor TAqObjectMapping.Destroy;
begin
  FMappings.Free;
end;

constructor TAqObjectMapping.Create(const pFrom, pTo: TClass);
var
  lContext: TRttiContext;
  lFieldFrom: TRttiField;
  lFieldTo: TRttiField;
begin
  FFieldMappings := TAqList<TAqFieldMapping>.Create(True);

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

{ TAqFieldMapping }

constructor TAqFieldMapping.Create(const pFieldFrom, pFieldTo: TRttiField);
begin
  FFieldFrom := pFieldFrom;
  FFieldTo := pFieldTo;
end;

end.
