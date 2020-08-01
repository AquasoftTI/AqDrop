unit AqDrop.DB.ORM.Reader;

interface

{$I '..\Core\AqDrop.Core.Defines.Inc'}

uses
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.SyncObjs,
  AqDrop.Core.Types,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Helpers.Rtti.GettersAndSetters.Intf,
  AqDrop.DB.Types,
  AqDrop.DB.ORM.Attributes;

type
  TAqDBORMTable = class;

  TAqDBORMColumn = class
  strict private const
    NULLABLE_IF_ZERO_TYPES = adtIntTypes + [adtCurrency, adtDouble, adtSingle, adtDatetime, adtDate, adtTime];
    NULLABLE_IF_EMPTY_TYPES = adtStringTypes + adtCharTypes + [adtGUID];
  strict private
    [weak]
    FTable: TAqDBORMTable;
    FAttribute: AqColumn;
    FValueGetter: IAqRttiValueGetter;

    function VerifyIfIsHasAttribute: Boolean; inline;
    function GetAlias: string;
    function GetStatusIsAliasDefined: Boolean; inline;
    function GetTargetName: string;
  strict protected
    function GetName: string; virtual;
    function GetMetadataName: string; virtual; abstract;

    procedure SetValue(const pInstance: TObject; const pValue: TValue); virtual; abstract;
    function GetTypeInfo: PTypeInfo; virtual; abstract;
    function GetType: TAqDataType; virtual; abstract;

    function DoGetValueGetter: IAqRttiValueGetter; virtual; abstract;
    function GetRttiMember: TRttiMember; virtual; abstract;
  public
    constructor Create(const pTable: TAqDBORMTable; const pAttribute: AqColumn);

    function GetValue(const pInstance: TObject): TValue; virtual; abstract;

    function TestIfValueIsNull(const pValue: TValue): Boolean;

    procedure SetObjectValue(const pInstance: TObject; pValue: TValue); overload;
    procedure SetObjectValue(const pInstance: TObject; pValue: IAqDBReadValue); overload;
    procedure SetDBValue(const pInstance: TObject; pValue: IAqDBValue);

    function GetValueGetter: IAqRttiValueGetter;

    function GetStatusIsNullableIfZero: Boolean;
    function GetStatusisNullIablefEmpty: Boolean;
    function GetStatusIsNullable: Boolean;

    property Table: TAqDBORMTable read FTable;
    property HasAttribute: Boolean read VerifyIfIsHasAttribute;
    property Attribute: AqColumn read FAttribute;
    property Name: string read GetName;
    property MetadataName: string read GetMetadataName;
    property IsAliasDefined: Boolean read GetStatusIsAliasDefined;
    property Alias: string read GetAlias;
    property TargetName: string read GetTargetName;
    property &Type: TAqDataType read GetType;
    property IsNullableIfZero: Boolean read GetStatusIsNullableIfZero;
    property IsNullableIfEmpty: Boolean read GetStatusisNullIablefEmpty;
    property IsNullable: Boolean read GetStatusIsNullable;
    property RttiMember: TRttiMember read GetRttiMember;
  end;

  TAqDBORMColumnField = class(TAqDBORMColumn)
  strict private
    FField: TRttiField;
  strict protected
    function GetMetadataName: string; override;

    procedure SetValue(const pInstance: TObject; const pValue: TValue); override;
    function GetType: TAqDataType; override;
    function GetTypeInfo: PTypeInfo; override;

    function DoGetValueGetter: IAqRttiValueGetter; override;
    function GetRttiMember: TRttiMember; override;
  public
    constructor Create(const pTable: TAqDBORMTable; const pField: TRttiField; const pAttribute: AqColumn);

    function GetValue(const pInstance: TObject): TValue; override;

    property Field: TRttiField read FField;
  end;

  TAqDBORMColumnProperty = class(TAqDBORMColumn)
  strict private
    FProperty: TRttiProperty;
  strict protected
    function GetMetadataName: string; override;

    procedure SetValue(const pInstance: TObject; const pValue: TValue); override;
    function GetType: TAqDataType; override;
    function GetTypeInfo: PTypeInfo; override;

    function DoGetValueGetter: IAqRttiValueGetter; override;
    function GetRttiMember: TRttiMember; override;
  public
    constructor Create(const pTable: TAqDBORMTable; const pProperty: TRttiProperty; const pAttribute: AqColumn);

    function GetValue(const pInstance: TObject): TValue; override;

    property &Property: TRttiProperty read FProperty;
  end;

  TAqDBORMTable = class
  strict private
    FType: TRttiType;
    FColumns: IAqList<TAqDBORMColumn>;
    FColumnsByMember: IAqDictionary<TRttiMember, TAqDBORMColumn>;

    procedure AddColumn(const pRttiMember: TRttiMember; const pColumn: TAqDBORMColumn); overload;
    function GetColumns: IAqReadableList<TAqDBORMColumn>;
  private
    procedure SetType(const pType: TRttiType);
  strict protected
    function GetName: string; virtual; abstract;
    function ExtractTableName(const pType: TRttiType): string;

    property &Type: TRttiType read FType;
  public
    constructor Create(const pType: TRttiType);

    procedure AddColumn(const pRttiMember: TRttiMember; const pAttribute: AqColumn); overload;
    procedure AddColumn(const pField: TRttiField; const pAttribute: AqColumn); overload;
    procedure AddColumn(const pProperty: TRttiProperty; const pAttribute: AqColumn); overload;

    function GetColumn(const pName: string; out pColumn: TAqDBORMColumn): Boolean;
    function GetColumnByRttiMember(const pRttiMember: TRttiMember; out pColumn: TAqDBORMColumn): Boolean;

    function HasAutoIncrementColumn(out pColumn: TAqDBORMColumn): Boolean;

    property Name: string read GetName;
    property Columns: IAqReadableList<TAqDBORMColumn> read GetColumns;
  end;

  TAqDBORMTable<T: AqTable> = class(TAqDBORMTable)
  strict private
    FAttribute: T;
  private
    procedure SetAttribute(const pAttribute: T; const pType: TRttiType);
  strict protected
    function GetName: string; override;
  public
    constructor Create(const pAttribute: T; const pType: TRttiType);

    property Attribute: T read FAttribute;
  end;

  TAqDBORM = class;

  IAqDBORMDetail = interface
    ['{53CF7EC4-08C0-4795-8ED7-16536592037C}']

    function GetORM: TAqDBORM;
    function VerifyIfLazyLoadingIsAvailable: Boolean;
    function VerifyIfDetailsAreLoaded(const pMaster: TObject): Boolean;
    function VerifyIfDeletedItensAreManaged: Boolean;

    function GetItems(const pMaster: TObject): IAqReadableList<TObject>;
    function AddItem(const pMaster: TObject): TObject;
    function GetDeletedItens(const pMaster: TObject): IAqReadableList<TObject>;

    procedure Unload(const pMaster: TObject);

    property ORM: TAqDBORM read GetORM;
    property LazyLoadingAvailable: Boolean read VerifyIfLazyLoadingIsAvailable;
    property ManagedDeletedItens: Boolean read VerifyIfDeletedItensAreManaged;
  end;

  TAqDBORM = class
  strict private type
    TFindThroughTablesFunction<T> = reference to function(const pTable: TAqDBORMTable; out pSubject: T): Boolean;
  strict private
    FORMClass: TClass;
    FMainTable: TAqDBORMTable<AqTable>;
    FSpecializations: IAqList<TAqDBORMTable<AqSpecialization>>;
    FDetails: IAqList<IAqDBORMDetail>;

    function GetInitialized: Boolean;
    function GetActiveTable: TAqDBORMTable<AqTable>;
    function GetPrimaryKeys: IAqReadableList<TAqDBORMColumn>;
    function GetUniqueKey: TAqDBORMColumn;
    function GetDetailKeys: IAqReadableList<TAqDBORMColumn>;
    function GetHasSpecializations: Boolean;
    function GetSpecializations: IAqReadableList<TAqDBORMTable<AqSpecialization>>;
    function FindThroughTables(const pFindFunction: TFunc<TAqDBORMTable, Boolean>): Boolean; overload;
    function FindThroughTables<T>(const pFindFunction: TFindThroughTablesFunction<T>;
      out pSubject: T): Boolean; overload;

    function VerifyIfHasDetail: Boolean;
    function GetDetails: IAqList<IAqDBORMDetail>;
    function GetReadableDetails: IAqReadableList<IAqDBORMDetail>;

    class var FTableSeparator: string;
  private
    class procedure InitializeDefaultValues;
  public
    constructor Create(const pClass: TClass);
    destructor Destroy; override;

    procedure AddTable(const pTableInfo: AqTable; const pType: TRttiType);

    procedure AddDetail(const pDetail: IAqDBORMDetail);

    function GetTable(const pName: string; out pTable: TAqDBORMTable): Boolean;
    function GetColumn(const pName: string; out pColumn: TAqDBORMColumn): Boolean; overload;
    function GetColumn(const pTableName, pColumnName: string; out pColumn: TAqDBORMColumn): Boolean; overload;
    function GetColumns: IAqResultList<TAqDBORMColumn>;

    function GetColumnByRttiMember(const pRttiMember: TRttiMember; out pColumn: TAqDBORMColumn): Boolean;

    function GetSpecializationUnderTable(const pTableName: string;
      out pSpecialization: TAqDBORMTable<AqSpecialization>): Boolean;

    property ORMClass: TClass read FORMClass;

    property Initialized: Boolean read GetInitialized;
    property MainTable: TAqDBORMTable<AqTable> read FMainTable;

    property PrimaryKeys: IAqReadableList<TAqDBORMColumn> read GetPrimaryKeys;
    property UniqueKey: TAqDBORMColumn read GetUniqueKey;
    property DetailKeys: IAqReadableList<TAqDBORMColumn> read GetDetailKeys;

    property HasSpecializations: Boolean read GetHasSpecializations;
    property Specializations: IAqReadableList<TAqDBORMTable<AqSpecialization>> read GetSpecializations;

    property HasDetails: Boolean read VerifyIfHasDetail;
    property Details: IAqReadableList<IAqDBORMDetail> read GetReadableDetails;

    property ActiveTable: TAqDBORMTable<AqTable> read GetActiveTable;

    // se for necessária mais uma configuração, é melhor isolá-las em uma sub-classe.
    class property TableSeparator: string read FTableSeparator;
  end;

  TAqDBORMBaseDetailInterpreter = class
  public
    function Interpret(const pRttiMember: TRttiMember; out pORMDetail: IAqDBORMDetail): Boolean; virtual; abstract;
  end;

  TAqDBORMReader = class
  strict private
    FORMs: IAqDictionary<PTypeInfo, TAqDBORM>;
    FDetailsInterpreters: IAqList<TAqDBORMBaseDetailInterpreter>;

    function IsDataTypeMappable(const pDataType: TAqDataType): Boolean;
    function CreateNewORM(const pClass: TClass): TAqDBORM;

    class var FInstance: TAqDBORMReader;
    class function GetInstance: TAqDBORMReader; static;
  private
    class procedure InitializeInstance;
    class procedure ReleaseInstance;
  public
    constructor Create;
    destructor Destroy; override;

    function GetORM(const pClass: TClass; const pUsePool: Boolean = True): TAqDBORM;

    procedure AddDetailInterpreter(const pDetailInterpreter: TAqDBORMBaseDetailInterpreter);

    class property Instance: TAqDBORMReader read GetInstance;
  end;

implementation

uses
  System.StrUtils,
  System.Generics.Collections,
  AqDrop.Core.Exceptions,
  AqDrop.Core.RequirementTests,
  AqDrop.Core.Helpers,
  AqDrop.Core.Helpers.Rtti,
  AqDrop.Core.Helpers.Rtti.GettersAndSetters,
  AqDrop.Core.Helpers.TRttiMember,
  AqDrop.Core.Helpers.TRttiType,
  AqDrop.Core.Helpers.TRttiObject,
  AqDrop.Core.Collections;

type
  TAqDBORMListDetail = class(TAqARCObject, IAqDBORMDetail)
  strict private
    FItemClass: TClass;
    FItemConstructor: TRttiMethod;
    FORM: TAqDBORM;
    FMasterMember: TRttiMember;

    function GetORM: TAqDBORM; inline;
    function GetMemberValueAsObjectList(const pMaster: TObject): TList<TObject>;
    function VerifyIfLazyLoadingIsAvailable: Boolean;
    function VerifyIfDetailsAreLoaded(const pMaster: TObject): Boolean;
    function GetItems(const pMaster: TObject): IAqReadableList<TObject>;
    function AddItem(const pMaster: TObject): TObject;
    function VerifyIfDeletedItensAreManaged: Boolean;
    function GetDeletedItens(const pMaster: TObject): IAqReadableList<TObject>;

    procedure Unload(const pMaster: TObject);
  public
    constructor Create(const pMasterMember: TRttiMember; const pItemClass: TClass;
      const pItemConstructor: TRttiMethod = nil);
  end;

  TAqDBORMListDetailInterpreter = class(TAqDBORMBaseDetailInterpreter)
  public
    function Interpret(const pRttiMember: TRttiMember; out pORMDetail: IAqDBORMDetail): Boolean; override;
  end;

{ TAqDBORMReader }

procedure TAqDBORMReader.AddDetailInterpreter(const pDetailInterpreter: TAqDBORMBaseDetailInterpreter);
begin
  FORMs.BeginWrite;

  try
    FDetailsInterpreters.Add(pDetailInterpreter);
  finally
    FORMs.EndWrite;
  end;
end;

constructor TAqDBORMReader.Create;
begin
  FORMs := TAqDictionary<PTypeInfo, TAqDBORM>.Create([TAqKeyValueOwnership.kvoValue], TAqLockerType.lktMultiReaderExclusiveWriter);
  FDetailsInterpreters := TAqList<TAqDBORMBaseDetailInterpreter>.Create(True);
  AddDetailInterpreter(TAqDBORMListDetailInterpreter.Create);
end;

function TAqDBORMReader.CreateNewORM(const pClass: TClass): TAqDBORM;
var
  lActiveTable: TAqDBORMTable<AqTable>;

  procedure TryToMapAsDetail(const pMember: TRttiMember);
  var
    lI: Int32;
    lDetail: IAqDBORMDetail;
  begin
    lI := FDetailsInterpreters.Count;

    while lI > 0 do
    begin
      Dec(lI);
      if FDetailsInterpreters[lI].Interpret(pMember, lDetail) then
      begin
        if lDetail.ORM.DetailKeys.Count <> Result.PrimaryKeys.Count then
        begin
          raise EAqInternal.CreateFmt('Invalid keys count when linking %s and %s.',
            [Result.ORMClass.QualifiedClassName, lDetail.ORM.ORMClass.QualifiedClassName]);
        end;

        Result.AddDetail(lDetail);
        lI := 0;
      end;
    end;
  end;

  procedure TryToMapMember(const pRttiMember: TRttiMember; const pAutoMap: Boolean);
  var
    lMemberDataType: TAqDataType;
    lHasMapping: Boolean;
    lColumn: AqColumn;
  begin
    if not pRttiMember.HasAttribute<AqORMOff> then
    begin
      lMemberDataType := pRttiMember.MemberType.GetDataType;
      if IsDataTypeMappable(lMemberDataType) then
      begin
        lHasMapping := pRttiMember.GetAttribute<AqColumn>(lColumn);
        if not lHasMapping then
        begin
          lColumn := nil;
        end;

        if lHasMapping or (Result.Initialized and pAutoMap) then
        begin
          lActiveTable.AddColumn(pRttiMember, lColumn);
        end;
      end else if (lMemberDataType = TAqDataType.adtClass) then
      begin
        if pAutoMap or pRttiMember.HasAttribute<AqDetail> then
        begin
          TryToMapAsDetail(pRttiMember);
        end;
      end;
    end;
  end;

  procedure ReadClass(pClasse: TClass);
  var
    lClassType: TRttiType;
    lTable: AqTable;
    lField: TRttiField;
    lProperty: TRttiProperty;
  begin
    if pClasse <> nil then
    begin
      ReadClass(pClasse.ClassParent);

      lClassType := TAqRtti.&Implementation.GetType(pClasse);
      if not lClassType.HasAttribute<AqORMOff> then
      begin
        if lClassType.GetAttribute<AqTable>(lTable) then
        begin
          Result.AddTable(lTable, lClassType);
        end;

        lActiveTable := Result.ActiveTable;

        for lField in lClassType.GetDeclaredFields do
        begin
          TryToMapMember(lField,
            Result.Initialized and (tmpAutoMapFields in lActiveTable.Attribute.MappingProperties));
        end;

        for lProperty in lClassType.GetDeclaredProperties do
        begin
          TryToMapMember(lProperty,
            Result.Initialized and (tmpAutoMapProperties in lActiveTable.Attribute.MappingProperties));
        end;
      end;
    end;
  end;
begin
  Result := TAqDBORM.Create(pClass);

  try
    ReadClass(pClass);
  except
    Result.Free;
    raise;
  end;
end;

destructor TAqDBORMReader.Destroy;
begin

  inherited;
end;

class function TAqDBORMReader.GetInstance: TAqDBORMReader;
begin
  InitializeInstance;

  Result := FInstance;
end;

function TAqDBORMReader.GetORM(const pClass: TClass; const pUsePool: Boolean): TAqDBORM;
begin
  if pUsePool then
  begin
    FORMs.BeginWrite;

    try
      if not FORMs.TryGetValue(pClass.ClassInfo, Result) then
      begin
        Result := CreateNewORM(pClass);

        try
          FORMs.Add(pClass.ClassInfo, Result);
        except
          Result.Free;
          raise;
        end;
      end;
    finally
      FORMs.EndWrite;
    end;
  end else begin
    Result := CreateNewORM(pClass);
  end;
end;

class procedure TAqDBORMReader.ReleaseInstance;
begin
  FreeAndNil(FInstance);
end;

class procedure TAqDBORMReader.InitializeInstance;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TAqDBORMReader.Create;
  end;
end;

function TAqDBORMReader.IsDataTypeMappable(const pDataType: TAqDataType): Boolean;
begin
  Result := pDataType in [
    TAqDataType.adtBoolean,
    TAqDataType.adtEnumerated,
    TAqDataType.adtUInt8,
    TAqDataType.adtInt8,
    TAqDataType.adtUInt16,
    TAqDataType.adtInt16,
    TAqDataType.adtUInt32,
    TAqDataType.adtInt32,
    TAqDataType.adtUInt64,
    TAqDataType.adtInt64,
    TAqDataType.adtCurrency,
    TAqDataType.adtDouble,
    TAqDataType.adtSingle,
    TAqDataType.adtDatetime,
    TAqDataType.adtDate,
    TAqDataType.adtTime,
    TAqDataType.adtAnsiChar,
    TAqDataType.adtChar,
    TAqDataType.adtAnsiString,
    TAqDataType.adtString,
    TAqDataType.adtWideString,
    TAqDataType.adtSet,
    TAqDataType.adtGUID];
end;

{ TAqDBORM }

procedure TAqDBORM.AddDetail(const pDetail: IAqDBORMDetail);
begin
  GetDetails.Add(pDetail);
end;

procedure TAqDBORM.AddTable(const pTableInfo: AqTable; const pType: TRttiType);
begin
  if not Assigned(FMainTable.Attribute) then
  begin
    FMainTable.SetAttribute(pTableInfo, pType);
  end else begin
    if not (pTableInfo is AqSpecialization) then
    begin
      raise EAqInternal.Create('This ORM already has a main table. All other tables must be specializations.');
    end;

    if not Assigned(FSpecializations) then
    begin
      FSpecializations := TAqList<TAqDBORMTable<AqSpecialization>>.Create(True);
    end;

    FSpecializations.Add(TAqDBORMTable<AqSpecialization>.Create(AqSpecialization(pTableInfo), pType));
  end;
end;

constructor TAqDBORM.Create(const pClass: TClass);
begin
  inherited Create;

  FORMClass := pClass;
  FMainTable := TAqDBORMTable<AqTable>.Create(nil, nil);
end;

destructor TAqDBORM.Destroy;
begin
  FMainTable.Free;

  inherited;
end;

function TAqDBORM.FindThroughTables(const pFindFunction: TFunc<TAqDBORMTable, Boolean>): Boolean;
var
  lIterator: IAqIterator<TAqDBORMTable<AqSpecialization>>;
begin
  Result := pFindFunction(FMainTable);

  if not Result and HasSpecializations then
  begin
    lIterator := Specializations.GetIterator;

    while not Result and lIterator.MoveToNext do
    begin
      Result := pFindFunction(lIterator.CurrentItem);
    end;
  end;
end;

function TAqDBORM.FindThroughTables<T>(const pFindFunction: TFindThroughTablesFunction<T>; out pSubject: T): Boolean;
var
  lSubject: T;
begin
  Result := FindThroughTables(
    function(pTable: TAqDBORMTable): Boolean
    begin
      Result := pFindFunction(pTable, lSubject);
    end);

  if Result then
  begin
    pSubject := lSubject;
  end;
end;

function TAqDBORM.GetColumn(const pName: string; out pColumn: TAqDBORMColumn): Boolean;
var
  lTableName: string;
  lColumnName: string;
begin
  if pName.SplitInTwo(FTableSeparator, lTableName, lColumnName) then
  begin
    Result := GetColumn(lTableName, lColumnName, pColumn);
  end else begin
    Result := FindThroughTables<TAqDBORMColumn>(
      function(const pTable: TAqDBORMTable; out pSubject: TAqDBORMColumn): Boolean
      begin
        Result := pTable.GetColumn(pName, pSubject);
      end, pColumn);
  end;
end;

function TAqDBORM.GetDetailKeys: IAqReadableList<TAqDBORMColumn>;
var
  lColumn: TAqDBORMColumn;
  lDetailkeys: IAqList<TAqDBORMColumn>;
begin
  lDetailkeys := TAqList<TAqDBORMColumn>.Create;
  for lColumn in FMainTable.Columns do
  begin
    if Assigned(lColumn.Attribute) and (lColumn.Attribute.DetailKey) then
    begin
      lDetailkeys.Add(lColumn);
    end;
  end;
  Result := lDetailkeys;
end;

function TAqDBORM.GetDetails: IAqList<IAqDBORMDetail>;
begin
  if not Assigned(FDetails) then
  begin
    FDetails := TAqList<IAqDBORMDetail>.Create;
  end;

  Result := FDetails;
end;

function TAqDBORM.GetSpecializations: IAqReadableList<TAqDBORMTable<AqSpecialization>>;
begin
  Result := FSpecializations.GetReadOnlyList;
end;

function TAqDBORM.GetSpecializationUnderTable(const pTableName: string;
  out pSpecialization: TAqDBORMTable<AqSpecialization>): Boolean;
var
  lFound: Boolean;
begin
  lFound := False;

  Result := HasSpecializations and FindThroughTables<TAqDBORMTable<AqSpecialization>>(
    function(const pTable: TAqDBORMTable; out pSubject: TAqDBORMTable<AqSpecialization>): Boolean
    begin
      Result := lFound;
      if Result then
      begin
        pSubject := pTable as TAqDBORMTable<AqSpecialization>;
      end else begin
        lFound := string.SameText(pTableName, pTable.Name);
      end;
    end, pSpecialization);
end;

function TAqDBORM.GetTable(const pName: string; out pTable: TAqDBORMTable): Boolean;
begin
  Result := FindThroughTables<TAqDBORMTable>(
    function(const pTable: TAqDBORMTable; out pSubject: TAqDBORMTable): Boolean
    begin
      Result := string.SameText(pTable.Name, pName);
      if Result then
      begin
        pSubject := pTable;
      end;
    end, pTable);
end;

function TAqDBORM.GetUniqueKey: TAqDBORMColumn;
var
  lPKs: IAqReadableList<TAqDBORMColumn>;
begin
  lPKs := GetPrimaryKeys;

  if (lPKs.Count <> 1) or not (lPKs.First.&Type in adtIntTypes) then
  begin
    raise EAqInternal.CreateFmt('The class %s doesn''t observe the Unique Key rule.', [FORMClass.QualifiedClassName]);
  end;

  Result := lPKs.First;
end;

class procedure TAqDBORM.InitializeDefaultValues;
begin
  FTableSeparator := '.';
end;

function TAqDBORM.VerifyIfHasDetail: Boolean;
begin
  Result := Assigned(FDetails);
end;

function TAqDBORM.GetInitialized: Boolean;
begin
  Result := Assigned(FMainTable.Attribute);
end;

function TAqDBORM.GetPrimaryKeys: IAqReadableList<TAqDBORMColumn>;
var
  lColumn: TAqDBORMColumn;
  lPrimaryKeys: IAqList<TAqDBORMColumn>;
begin
{TODO 2 -oTatu -cMelhoria: criar a opção do usuário do drop escolher qual a tabela que quer consumir as pks, atualmente tá só na tabela principal (no caso de uma especialização, teremos mais tabelas)}
  lPrimaryKeys := TAqList<TAqDBORMCOlumn>.Create;

  for lColumn in FMainTable.Columns do
  begin
    if Assigned(lColumn.Attribute) and (lColumn.Attribute.PrimaryKey) then
    begin
      lPrimaryKeys.Add(lColumn);
    end;
  end;

  Result := lPrimaryKeys;
end;

function TAqDBORM.GetReadableDetails: IAqReadableList<IAqDBORMDetail>;
begin
  Result := FDetails.GetReadOnlyList;
end;

function TAqDBORM.GetHasSpecializations: Boolean;
begin
  Result := Assigned(FSpecializations);
end;

function TAqDBORM.GetActiveTable: TAqDBORMTable<AqTable>;
begin
  if Assigned(FSpecializations) then
  begin
    Result := TAqDBORMTable<AqTable>(FSpecializations.Last);
  end else begin
    Result := FMainTable;
  end;
end;

function TAqDBORM.GetColumn(const pTableName, pColumnName: string; out pColumn: TAqDBORMColumn): Boolean;
begin
  Result := FindThroughTables<TAqDBORMColumn>(
    function(const pTable: TAqDBORMTable; out pSubject: TAqDBORMColumn): Boolean
    begin
      Result := string.SameText(pTableName, pTable.Name) and pTable.GetColumn(pColumnName, pSubject);
    end, pColumn);
end;

function TAqDBORM.GetColumnByRttiMember(const pRttiMember: TRttiMember; out pColumn: TAqDBORMColumn): Boolean;
begin
  Result := FindThroughTables<TAqDBORMColumn>(
    function(const pTable: TAqDBORMTable; out pSubject: TAqDBORMColumn): Boolean
    begin
      Result := pTable.GetColumnByRttiMember(pRttiMember, pSubject);
    end, pColumn);
end;

function TAqDBORM.GetColumns: IAqResultList<TAqDBORMColumn>;
var
  lResultList: TAqResultList<TAqDBORMColumn>;
begin
  lResultList := TAqResultList<TAqDBORMColumn>.Create;

  try
    FindThroughTables(
      function(pTable: TAqDBORMTable): Boolean
      var
        lColumn: TAqDBORMColumn;
      begin
        for lColumn in pTable.Columns do
        begin
          lResultList.Add(lColumn);
        end;

        Result := False;
      end);
  except
    lResultList.Free;
    raise;
  end;

  Result := lResultList;
end;

{ TAqDBORMColumn }

constructor TAqDBORMColumn.Create(const pTable: TAqDBORMTable; const pAttribute: AqColumn);
begin
  FTable := pTable;
  FAttribute := pAttribute;
end;

function TAqDBORMColumn.GetAlias: string;
begin
  if IsAliasDefined then
  begin
    Result := FAttribute.Alias;
  end else begin
    Result := '';
  end;
end;

function TAqDBORMColumn.GetName: string;
begin
  if Assigned(Attribute) and Attribute.IsNameDefined then
  begin
    Result := Attribute.Name;
  end else begin
    Result := GetMetadataName;
  end;
end;

function TAqDBORMColumn.GetStatusIsAliasDefined: Boolean;
begin
  Result := HasAttribute and FAttribute.IsAliasDefined;
end;

function TAqDBORMColumn.GetStatusIsNullable: Boolean;
begin
  Result := IsNullableIfZero or IsNullableIfEmpty;
end;

function TAqDBORMColumn.GetStatusIsNullableIfZero: Boolean;
begin
  Result := HasAttribute and (caNullIfZero in Attribute.Attributes) and (&Type in NULLABLE_IF_ZERO_TYPES);
end;

function TAqDBORMColumn.GetStatusisNullIablefEmpty: Boolean;
begin
  Result := HasAttribute and (caNullIfEmpty in Attribute.Attributes) and (&Type in NULLABLE_IF_EMPTY_TYPES);
end;

function TAqDBORMColumn.GetTargetName: string;
begin
  if IsAliasDefined then
  begin
    Result := Alias;
  end else begin
    Result := Name;
  end;
end;

function TAqDBORMColumn.GetValueGetter: IAqRttiValueGetter;
begin
  if not Assigned(FValueGetter) then
  begin
    FValueGetter := DoGetValueGetter;
  end;

  Result := FValueGetter;
end;

procedure TAqDBORMColumn.SetDBValue(const pInstance: TObject; pValue: IAqDBValue);
var
  lValue: TValue;
begin
  lValue := GetValue(pInstance);

  case GetType of
    TAqDataType.adtBoolean:
      pValue.AsBoolean := lValue.AsBoolean;
    TAqDataType.adtEnumerated:
      pValue.AsInt64 := lValue.AsOrdinal;
    TAqDataType.adtUInt8:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtUInt8);
      end else begin
        pValue.AsUInt8 := lValue.AsInteger;
      end;
    TAqDataType.adtInt8:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtInt8);
      end else begin
        pValue.AsInt8 := lValue.AsInteger;
      end;
    TAqDataType.adtUInt16:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtUInt16);
      end else begin
        pValue.AsUInt16 := lValue.AsInteger;
      end;
    TAqDataType.adtInt16:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtInt16);
      end else begin
        pValue.AsInt16 := lValue.AsInteger;
      end;
    TAqDataType.adtUInt32:
{$IF CompilerVersion >= 25}
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtUInt32);
      end else begin
        pValue.AsUInt32 := lValue.AsUInt64;
      end;
{$ELSE}
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtInt32);
      end else begin
        pValue.AsUInt32 := lValue.AsInt64;
      end;
{$IFEND}
    TAqDataType.adtInt32:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtInt32);
      end else begin
        pValue.AsInt32 :=  lValue.AsInteger;
      end;
    TAqDataType.adtUInt64:
{$IF CompilerVersion >= 25}
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtUInt64);
      end else begin
        pValue.AsUInt64 := lValue.AsUInt64;
      end;
{$ELSE}
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtInt32);
      end else begin
        pValue.AsUInt64 := lValue.AsInt64;
      end;
{$IFEND}
    TAqDataType.adtInt64:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtInt64);
      end else begin
        pValue.AsInt64 := lValue.AsInt64;
      end;
    TAqDataType.adtCurrency:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtCurrency);
      end else begin
        pValue.AsCurrency := lValue.AsCurrency;
      end;
    TAqDataType.adtDouble:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtDouble);
      end else begin
        pValue.AsDouble := lValue.AsExtended;
      end;
    TAqDataType.adtSingle:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtSingle);
      end else begin
        pValue.AsSingle := lValue.AsExtended;
      end;
    TAqDataType.adtDatetime:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtDatetime);
      end else begin
        pValue.AsDateTime := lValue.AsExtended;
      end;
    TAqDataType.adtDate:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtDate);
      end else begin
        pValue.AsDate := lValue.AsExtended;
      end;
    TAqDataType.adtTime:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtTime);
      end else begin
        pValue.AsTime := lValue.AsExtended;
      end;
{$IFNDEF AQMOBILE}
    TAqDataType.adtAnsiChar:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtAnsiChar);
      end else begin
        pValue.AsAnsiString := AnsiString(lValue.AsString);
      end;
{$ENDIF}
    TAqDataType.adtChar:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtChar);
      end else begin
        pValue.AsString := lValue.AsString;
      end;
{$IFNDEF AQMOBILE}
    TAqDataType.adtAnsiString:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtAnsiString);
      end else begin
        pValue.AsAnsiString := AnsiString(lValue.AsString);
      end;
{$ENDIF}
    TAqDataType.adtString, TAqDataType.adtWideString:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtWideString);
      end else begin
        pValue.AsString := lValue.AsString;
      end;
    TAqDataType.adtGUID:
      if TestIfValueIsNull(lValue) then
      begin
        pValue.SetNull(TAqDataType.adtGUID);
      end else begin
        pValue.AsGUID := lValue.AsType<TGUID>;
      end;
  else
    raise EAqInternal.Create('Unexpected type when setting value to ' + Self.Name + ' DB Value.');
  end;
end;

procedure TAqDBORMColumn.SetObjectValue(const pInstance: TObject; pValue: TValue);
begin
  SetValue(pInstance, pValue);
end;

procedure TAqDBORMColumn.SetObjectValue(const pInstance: TObject; pValue: IAqDBReadValue);
begin
  SetValue(pInstance, pValue.GetAsTValue(GetTypeInfo));
end;

function TAqDBORMColumn.TestIfValueIsNull(const pValue: TValue): Boolean;
begin
  Result := IsNullable;

  if Result then
  begin
    case GetType of
      adtUInt8..adtInt64:
        Result := pValue.AsOrdinal = 0;
      adtCurrency, adtDouble, adtSingle, adtDatetime, adtDate, adtTime:
        Result := pValue.AsExtended = 0;
      adtAnsiChar, adtChar, adtAnsiString, adtString, adtWideString:
        Result := pValue.AsString.IsEmpty;
      adtGUID:
        Result := TAqGUIDFunctions.IsEmpty(pValue.AsType<TGUID>);
    end;
  end;
end;

function TAqDBORMColumn.VerifyIfIsHasAttribute: Boolean;
begin
  Result := Assigned(FAttribute);
end;

{ TAqDBORMTable }

procedure TAqDBORMTable.AddColumn(const pField: TRttiField; const pAttribute: AqColumn);
begin
  AddColumn(pField, TAqDBORMColumnField.Create(Self, pField, pAttribute));
end;

procedure TAqDBORMTable.AddColumn(const pProperty: TRttiProperty; const pAttribute: AqColumn);
begin
  AddColumn(pProperty, TAqDBORMColumnProperty.Create(Self, pProperty, pAttribute));
end;

procedure TAqDBORMTable.AddColumn(const pRttiMember: TRttiMember; const pAttribute: AqColumn);
begin
  pRttiMember.Disambiguate(
    procedure(pField: TRttiField)
    begin
      AddColumn(pField, pAttribute);
    end,
    procedure(pProperty: TRttiProperty)
    begin
      AddColumn(pProperty, pAttribute);
    end);
end;

procedure TAqDBORMTable.AddColumn(const pRttiMember: TRttiMember; const pColumn: TAqDBORMColumn);
begin
  FColumns.Add(pColumn);
  FColumnsByMember.Add(pRttiMember, pColumn);
end;

constructor TAqDBORMTable.Create(const pType: TRttiType);
begin
  FType := pType;
  FColumns := TAqList<TAqDBORMColumn>.Create(True);
  FColumnsByMember := TAqDictionary<TRttiMember, TAqDBORMColumn>.Create;
end;

function TAqDBORMTable.ExtractTableName(const pType: TRttiType): string;
begin
  if (pType.Name.Length > 1) and pType.Name.ToUpper.StartsWith('T') then
  begin
    Result := pType.Name.RightFromPosition(1, True);
  end else begin
    Result := pType.Name;
  end;
end;

function TAqDBORMTable.GetColumn(const pName: string; out pColumn: TAqDBORMColumn): Boolean;
var
  lIColumn: Int32;
begin
  Result := False;
  lIColumn := FColumns.Count;

  while not Result and (lIColumn > 0) do
  begin
    Dec(lIColumn);

    Result := string.SameText(pName, FColumns[lIColumn].TargetName);

    if Result then
    begin
      pColumn := FColumns[lIColumn];
    end;
  end;
end;

function TAqDBORMTable.GetColumnByRttiMember(const pRttiMember: TRttiMember; out pColumn: TAqDBORMColumn): Boolean;
begin
  Result := FColumnsByMember.TryGetValue(pRttiMember, pColumn);
end;

function TAqDBORMTable.GetColumns: IAqReadableList<TAqDBORMColumn>;
begin
  Result := FColumns.GetReadOnlyList;
end;

function TAqDBORMTable.HasAutoIncrementColumn(out pColumn: TAqDBORMColumn): Boolean;
var
  lI: Int32;
begin
  Result := False;
  lI := 0;
  while not Result and (lI < FColumns.Count) do
  begin
    Result := Assigned(FColumns[lI].Attribute) and FColumns[lI].Attribute.AutoIncrement;

    if Result then
    begin
      pColumn := FColumns[lI];
    end else begin
      Inc(lI);
    end;
  end;
end;

procedure TAqDBORMTable.SetType(const pType: TRttiType);
begin
  FType := pType;
end;

{ TAqDBORMTable<T> }

constructor TAqDBORMTable<T>.Create(const pAttribute: T; const pType: TRttiType);
begin
  inherited Create(pType);

  FAttribute := pAttribute;
end;

function TAqDBORMTable<T>.GetName: string;
begin
  if Assigned(FAttribute) and FAttribute.IsNameDefined then
  begin
    Result := FAttribute.Name;
  end else if Assigned(&Type) then
  begin
    Result := ExtractTableName(&Type);
  end else begin
    raise EAqInternal.Create('Impossible to get the table name.');
  end;
end;

procedure TAqDBORMTable<T>.SetAttribute(const pAttribute: T; const pType: TRttiType);
begin
  SetType(pType);
  FAttribute := pAttribute;
end;

{ TAqDBORMColumnField }

constructor TAqDBORMColumnField.Create(const pTable: TAqDBORMTable; const pField: TRttiField;
  const pAttribute: AqColumn);
begin
  inherited Create(pTable, pAttribute);

  FField := pField;
end;

function TAqDBORMColumnField.DoGetValueGetter: IAqRttiValueGetter;
begin
  Result := TAqRttiFieldValueGetter.Create(FField);
end;

function TAqDBORMColumnField.GetMetadataName: string;
begin
  if (FField.Name.Length > 1) and FField.Name.ToUpper.StartsWith('F') then
  begin
    Result := FField.Name.RightFromPosition(1, True);
  end else begin
    Result := FField.Name;
  end;
end;

function TAqDBORMColumnField.GetRttiMember: TRttiMember;
begin
  Result := FField;
end;

function TAqDBORMColumnField.GetType: TAqDataType;
begin
  Result := FField.FieldType.GetDataType;
end;

function TAqDBORMColumnField.GetTypeInfo: PTypeInfo;
begin
  Result := FField.FieldType.Handle;
end;

function TAqDBORMColumnField.GetValue(const pInstance: TObject): TValue;
begin
  Result := FField.GetValue(pInstance);
end;

procedure TAqDBORMColumnField.SetValue(const pInstance: TObject; const pValue: TValue);
begin
  FField.SetValue(pInstance, pValue);
end;

{ TAqDBORMColumnProperty }

constructor TAqDBORMColumnProperty.Create(const pTable: TAqDBORMTable; const pProperty: TRttiProperty;
  const pAttribute: AqColumn);
begin
  inherited Create(pTable, pAttribute);

  FProperty := pProperty;
end;

function TAqDBORMColumnProperty.DoGetValueGetter: IAqRttiValueGetter;
begin
  Result := TAqRttiPropertyValueGetter.Create(FProperty);
end;

function TAqDBORMColumnProperty.GetMetadataName: string;
begin
  Result := FProperty.Name;
end;

function TAqDBORMColumnProperty.GetRttiMember: TRttiMember;
begin
  Result := FProperty;
end;

function TAqDBORMColumnProperty.GetType: TAqDataType;
begin
  Result := FProperty.PropertyType.GetDataType;
end;

function TAqDBORMColumnProperty.GetTypeInfo: PTypeInfo;
begin
  Result := FProperty.PropertyType.Handle;
end;

function TAqDBORMColumnProperty.GetValue(const pInstance: TObject): TValue;
begin
  Result := FProperty.GetValue(pInstance);
end;

procedure TAqDBORMColumnProperty.SetValue(const pInstance: TObject; const pValue: TValue);
begin
  if not FProperty.IsWritable then
  begin
    raise EAqInternal.Create('Property ' + FProperty.Name + ' is read only.');
  end;

  FProperty.SetValue(pInstance, pValue);
end;

{ TAqDBORMDetail }
{
function TAqDBORMDetail.AddItem(const pMaster: TObject): TObject;
begin
  Result := DoAddItem(pMaster);
end;

constructor TAqDBORMDetail.Create(const pORM: TAqDBORM; const pMember: TRttiMember);
begin
  FORM := pORM;
  FMember := pMember;
end;

function TAqDBORMDetail.GetDetailKeys: IAqReadableList<TAqDBORMColumn>;
begin
  Result := FORM.GetDetailKeys;
end;

function TAqDBORMDetail.GetItems(const pMaster: TObject): IAqReadableList<TObject>;
begin
  Result := DoGetItems(pMaster);
end;

function TAqDBORMDetail.VerifyIfIsDetailsAreLoaded(const pMaster: TObject): Boolean;
begin
  Result := DoVerifyIfIsDetailsAreLoaded(pMaster);
end;

function TAqDBORMDetail.VerifyIfLazyLoadingIsEnabled: Boolean;
begin
  Result := DoVerifyIfLazyLoadingIsEnabled;
end;
}
{ TAqDBORMListDetailInterpreter }

function TAqDBORMListDetailInterpreter.Interpret(const pRttiMember: TRttiMember;
  out pORMDetail: IAqDBORMDetail): Boolean;
var
  lMemberType: TRttiType;
  lGenericTypeNames: TArray<string>;
  lInternalType: TRttiType;
  lConstructor: TRttiMethod;

  function FindListMemberType: Boolean;
  begin
    Result := False;
    lMemberType := pRttiMember.MemberType;

    while not Result and Assigned(lMemberType) do
    begin
      Result := lMemberType.IsGeneric and (lMemberType.GetGenericName = 'System.Generics.Collections.TList<>');

      if not Result then
      begin
        lMemberType := lMemberType.BaseType;
      end;
    end;
  end;

  function CheckUniqueGenericTypeName: Boolean;
  begin
    lGenericTypeNames := lMemberType.GetGenericTypeNames;
    Result := Length(lGenericTypeNames) = 1;
  end;

  function FindInternalType: Boolean;
  begin
    lInternalType := TAqRtti.&Implementation.FindType(lGenericTypeNames[0]);
    Result := Assigned(lInternalType);
  end;

  function FindInternalTypeConstructor: Boolean;
  begin
    Result := (lInternalType.GetDataType = adtClass) and lInternalType.GetParameterlessConstructor(lConstructor);
  end;
begin
  Result := FindListMemberType and
    CheckUniqueGenericTypeName and
    FindInternalType and
    FindInternalTypeConstructor;

  if Result then
  begin
    pORMDetail := TAqDBORMListDetail.Create(pRttiMember, lInternalType.AsInstance.MetaclassType, lConstructor);
  end;
end;

{ TAqDBORMListDetail }

constructor TAqDBORMListDetail.Create(const pMasterMember: TRttiMember;
  const pItemClass: TClass; const pItemConstructor: TRttiMethod);
begin
  inherited Create;

  FItemClass := pItemClass;
  FORM := TAqDBORMReader.Instance.GetORM(pItemClass);
  FMasterMember := pMasterMember;

  if Assigned(pItemConstructor) then
  begin
    FItemConstructor := pItemConstructor;
  end else begin
    if not TAqRtti.&Implementation.GetType(pItemClass).GetParameterlessConstructor(FItemConstructor) then
    begin
      raise EAqInternal.CreateFmt('Impossible to create this detail whithout a default constructor for %s.',
        [pItemClass.QualifiedClassName]);
    end;
  end;
end;

function TAqDBORMListDetail.AddItem(const pMaster: TObject): TObject;
begin
  Result := FItemConstructor.Invoke(FItemClass, []).AsObject;

  try
    GetMemberValueAsObjectList(pMaster).Add(Result);
  except
    Result.Free;
    raise;
  end;
end;

function TAqDBORMListDetail.GetDeletedItens(const pMaster: TObject): IAqReadableList<TObject>;
begin
  raise EAqInternal.Create('This detail list do not support managed deleted items.');
end;

function TAqDBORMListDetail.GetItems(const pMaster: TObject): IAqReadableList<TObject>;
begin
  Result := TAqReadableList<TObject>.Create(GetMemberValueAsObjectList(pMaster));
end;

function TAqDBORMListDetail.GetORM: TAqDBORM;
begin
  Result := FORM;
end;

procedure TAqDBORMListDetail.Unload(const pMaster: TObject);
begin
  GetMemberValueAsObjectList(pMaster).Clear;
end;

function TAqDBORMListDetail.VerifyIfDeletedItensAreManaged: Boolean;
begin
  Result := False;
end;

function TAqDBORMListDetail.VerifyIfDetailsAreLoaded(const pMaster: TObject): Boolean;
begin
  Result := True;
end;

function TAqDBORMListDetail.VerifyIfLazyLoadingIsAvailable: Boolean;
begin
  Result := False;
end;

function TAqDBORMListDetail.GetMemberValueAsObjectList(const pMaster: TObject): TList<TObject>;
var
  lObject: TObject;
begin
  lObject := FMasterMember.UniversalGetValue(pMaster).AsObject;

  TAqRequirement.Test(Assigned(lObject), 'Detail object not assigned.');

  Result := TList<TObject>(lObject);
end;

initialization
  TAqDBORM.InitializeDefaultValues;
  TAqDBORMReader.InitializeInstance;

finalization
  TAqDBORMReader.ReleaseInstance;

end.
