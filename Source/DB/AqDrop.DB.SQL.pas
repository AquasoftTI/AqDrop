unit AqDrop.DB.SQL;

interface

uses
  System.Rtti,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Collections,
  AqDrop.Core.InterfacedObject,
  AqDrop.DB.SQL.Intf;

type
  TAqDBSQLAliasable = class;
  TAqDBSQLColumn = class;
  TAqDBSQLSubselect = class;
  TAqDBSQLSource = class;
  TAqDBSQLTable = class;
  TAqDBSQLSelect = class;

  TAqDBSQLAbstraction = class(TAqInterfacedObject)
  strict protected
    class function MustCountReferences: Boolean; override;
  end;

  TAqDBSQLAliasable = class(TAqDBSQLAbstraction, IAqDBSQLAliasable)
  strict private
    FAlias: string;

    function GetAlias: string;
    function GetIsAliasDefined: Boolean;
  public
    constructor Create(const pAlias: string = '');
  end;

  TAqDBSQLValue = class(TAqDBSQLAliasable, IAqDBSQLValue)
  strict private
    FAggregator: TAqDBSQLAggregatorType;
    function GetAggregator: TAqDBSQLAggregatorType;
  strict protected
    function GetValueType: TAqDBSQLValueType; virtual; abstract;
    function GetAsColumn: IAqDBSQLColumn; virtual;
    function GetAsOperation: IAqDBSQLOperation; virtual;
    function GetAsSubselect: IAqDBSQLSubselect; virtual;
    function GetAsConstant: IAqDBSQLConstant; virtual;
    function GetAsParameter: IAqDBSQLParameter; virtual;
  public
    constructor Create(const pAlias: string = ''; const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLColumn = class(TAqDBSQLValue, IAqDBSQLColumn)
  strict private
    FExpression: string;
    FSource: IAqDBSQLSource;

    function GetExpression: string;
    function GetSource: IAqDBSQLSource;
    function GetIsSourceDefined: Boolean;
  strict protected
    function GetValueType: TAqDBSQLValueType; override;
    function GetAsColumn: IAqDBSQLColumn; override;
  public
    constructor Create(const pExpression: string; pSource: IAqDBSQLSource = nil;
      const pAlias: string = ''; const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLOperation = class(TAqDBSQLValue, IAqDBSQLOperation)
  strict private
    FLeftOperand: IAqDBSQLValue;
    FOperator: TAqDBSQLOperator;
    FRightOperand: IAqDBSQLValue;

    function GetOperator: TAqDBSQLOperator;
    function GetRightOperand: IAqDBSQLValue;
    function GetLeftOperand: IAqDBSQLValue;
  strict protected
    function GetValueType: TAqDBSQLValueType; override;
    function GetAsOperation: IAqDBSQLOperation; override;
  public
    constructor Create(pLeftOperand: IAqDBSQLValue; const pOperator: TAqDBSQLOperator;
      pRightOperand: IAqDBSQLValue; const pAlias: string = '';
      const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLSubselect = class(TAqDBSQLValue, IAqDBSQLSubselect)
  strict private
    FSelect: IAqDBSQLSelect;

    function GetSelect: IAqDBSQLSelect;
  strict protected
    function GetValueType: TAqDBSQLValueType; override;
    function GetAsSubselect: IAqDBSQLSubselect; override;
  public
    constructor Create(pSelect: IAqDBSQLSelect; const pAlias: string = '';
      const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLConstant = class abstract(TAqDBSQLValue, IAqDBSQLConstant)
  strict protected
    function GetValueType: TAqDBSQLValueType; override;
    function GetAsConstant: IAqDBSQLConstant; override;


    function GetConstantType: TAqDBSQLConstantValueType; virtual; abstract;
    function GetAsTextConstant: IAqDBSQLTextConstant; virtual;
    function GetAsNumericConstant: IAqDBSQLNumericConstant; virtual;
    function GetAsDateTimeConstant: IAqDBSQLDateTimeConstant; virtual;
    function GetAsDateConstant: IAqDBSQLDateConstant; virtual;
    function GetAsTimeConstant: IAqDBSQLTimeConstant; virtual;
    function GetAsBooleanConstant: IAqDBSQLBooleanConstant; virtual;
  end;

  TAqDBSQLTextConstant = class(TAqDBSQLConstant, IAqDBSQLTextConstant)
  strict private
    FValue: string;
    function GetValue: string;
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsTextConstant: IAqDBSQLTextConstant; override;
  public
    constructor Create(const pValue: string; const pAlias: string = '';
      const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLNumericConstant = class(TAqDBSQLConstant, IAqDBSQLNumericConstant)
  strict private
    FValue: Double;
    function GetValue: Double;
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsNumericConstant: IAqDBSQLNumericConstant; override;
  public
    constructor Create(const pValue: Double; const pAlias: string = '';
      const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLDateTimeConstant = class(TAqDBSQLConstant, IAqDBSQLDateTimeConstant)
  strict private
    FValue: TDateTime;
    function GetValue: TDateTime;
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsDateTimeConstant: IAqDBSQLDateTimeConstant; override;
  public
    constructor Create(const pValue: TDateTime; const pAlias: string = '';
      const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLDateConstant = class(TAqDBSQLConstant, IAqDBSQLDateConstant)
  strict private
    FValue: TDate;
    function GetValue: TDate;
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsDateConstant: IAqDBSQLDateConstant; override;
  public
    constructor Create(const pValue: TDate; const pAlias: string = '';
      const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLTimeConstant = class(TAqDBSQLConstant, IAqDBSQLTimeConstant)
  strict private
    FValue: TTime;
    function GetValue: TTime;
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsTimeConstant: IAqDBSQLTimeConstant; override;
  public
    constructor Create(const pValue: TTime);
  end;

  TAqDBSQLBooleanConstant = class(TAqDBSQLConstant, IAqDBSQLBooleanConstant)
  strict private
    FValue: Boolean;
    function GetValue: Boolean;
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsBooleanConstant: IAqDBSQLBooleanConstant; override;
  public
    constructor Create(const pValue: Boolean; const pAlias: string = '';
      const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLParameter = class(TAqDBSQLValue, IAqDBSQLParameter)
  strict private
    FName: string;

    function GetName: string;
  strict protected
    function GetValueType: TAqDBSQLValueType; override;
    function GetAsParameter: IAqDBSQLParameter; override;
  public
    constructor Create(const pName: string; const pAlias: string = '';
      const pAggregator: TAqDBSQLAggregatorType = atNone);
  end;

  TAqDBSQLSource = class(TAqDBSQLAliasable, IAqDBSQLSource)
  strict protected
    function GetSourceType: TAqDBSQLSourceType; virtual; abstract;
    function GetAsTable: IAqDBSQLTable; virtual;
    function GetAsSelect: IAqDBSQLSelect; virtual;
  end;

  TAqDBSQLTable = class(TAqDBSQLSource, IAqDBSQLTable, IAqDBSQLSource)
  strict private
    FName: string;

    function GetName: string;
  strict protected
    function GetSourceType: TAqDBSQLSourceType; override;
    function GetAsTable: IAqDBSQLTable; override;
  public
    constructor Create(const pName: string; const pAlias: string = '');
  end;

  TAqDBSQLCondition = class(TAqDBSQLAbstraction, IAqDBSQLCondition)
  strict protected
    function GetConditionType: TAqDBSQLConditionType; virtual; abstract;

    function GetAsComparison: IAqDBSQLComparisonCondition; virtual;
    function GetAsValueIsNull: IAqDBSQLValueIsNullCondition; virtual;
    function GetAsComposed: IAqDBSQLComposedCondition; virtual;
    function GetAsBetween: IAqDBSQLBetweenCondition; virtual;
  end;

  TAqDBSQLComparisonCondition = class(TAqDBSQLCondition, IAqDBSQLComparisonCondition)
  strict private
    FLeftValue: IAqDBSQLValue;
    FComparison: TAqDBSQLComparison;
    FRightValue: IAqDBSQLValue;

    function GetLeftValue: IAqDBSQLValue;
    function GetComparison: TAqDBSQLComparison;
    function GetRightValue: IAqDBSQLValue;
  strict protected
    function GetConditionType: TAqDBSQLConditionType; override;
    function GetAsComparison: IAqDBSQLComparisonCondition; override;
  public
    constructor Create(pLeftValue: IAqDBSQLValue; const pComparison: TAqDBSQLComparison;
      pRightValue: IAqDBSQLValue);
  end;

  TAqDBSQLValueIsNullCondition = class(TAqDBSQLCondition, IAqDBSQLValueIsNullCondition)
  strict private
    FValue: IAqDBSQLValue;
    function GetValue: IAqDBSQLValue;
  strict protected
    function GetConditionType: TAqDBSQLConditionType; override;
    function GetAsValueIsNull: IAqDBSQLValueIsNullCondition; override;
  public
    constructor Create(pValue: IAqDBSQLValue);
  end;

  TAqDBSQLComposedCondition = class(TAqDBSQLCondition, IAqDBSQLComposedCondition)
  strict private
    FConditions: TAqList<IAqDBSQLCondition>;
    FOperators: TAqList<TAqDBSQLBooleanOperator>;

    function GetConditions: AqDrop.Core.Collections.Intf.IAqReadList<AqDrop.DB.SQL.Intf.IAqDBSQLCondition>;
    function GetLinkOperators: AqDrop.Core.Collections.Intf.IAqReadList<AqDrop.DB.SQL.Intf.TAqDBSQLBooleanOperator>;
  strict protected
    function GetConditionType: TAqDBSQLConditionType; override;
    function GetAsComposed: IAqDBSQLComposedCondition; override;
  public
    constructor Create(const pInitialCondition: IAqDBSQLCondition);
    destructor Destroy; override;

    function AddCondition(const pLinkOperator: TAqDBSQLBooleanOperator; pCondition: IAqDBSQLCondition): Int32;
    function AddAnd(const pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
    function AddOr(const pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
    function AddXor(const pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
  end;

  TAqDBSQLBetweenCondition = class(TAqDBSQLCondition, IAqDBSQLBetweenCondition)
  strict private
    FValue: IAqDBSQLValue;
    FRangeBegin: IAqDBSQLValue;
    FRangeEnd: IAqDBSQLValue;
    function GetValue: IAqDBSQLValue;
    function GetRangeBegin: IAqDBSQLValue;
    function GetRangeEnd: IAqDBSQLValue;
  strict protected
    function GetAsBetween: IAqDBSQLBetweenCondition; override;
    function GetConditionType: TAqDBSQLConditionType; override;
  public
    constructor Create(pValue, pRangeBegin, pRangeEnd: IAqDBSQLValue);
  end;

  TAqDBSQLJoin = class(TAqDBSQLAliasable, IAqDBSQLJoin)
  strict private
    FType: TAqDBSQLJoinType;
    FSource: IAqDBSQLSource;
    FCondition: IAqDBSQLCondition;

    function GetSource: IAqDBSQLSource;
    function GetCondition: IAqDBSQLCondition;
    function GetJoinType: TAqDBSQLJoinType;
  public
    constructor Create(const pType: TAqDBSQLJoinType; pSource: IAqDBSQLSource;
      pCondition: IAqDBSQLCondition);
  end;

  TAqDBSQLSelect = class(TAqDBSQLSource, IAqDBSQLSource, IAqDBSQLSelect, IAqDBSQLCommand)
  strict private
    FColumns: TAqList<IAqDBSQLValue>;
    FSource: IAqDBSQLSource;
    FJoins: TAqList<IAqDBSQLJoin>;
    FLimit: UInt32;
    FCondition: IAqDBSQLCondition;
    FOrderBy: TAqList<IAqDBSQLValue>;

    constructor InternalCreate(const pAlias: string);

    function GetColumns: IAqReadList<IAqDBSQLValue>;
    function GetSource: IAqDBSQLSource;

    function GetHasJoins: Boolean;
    function GetJoins: IAqReadList<IAqDBSQLJoin>;

    function GetIsConditionDefined: Boolean;
    function GetCondition: IAqDBSQLCondition;
    procedure SetCondition(pValue: IAqDBSQLCondition);
    function CustomizeCondition(const pNewCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;

    function GetIsLimitDefined: Boolean;
    function GetLimit: UInt32;
    procedure SetLimit(const pValue: UInt32);

    function GetIsOrderByDefined: Boolean;
    function GetOrderBy: IAqReadList<IAqDBSQLValue>;

    function GetAsDelete: IAqDBSQLDelete;
    function GetAsInsert: IAqDBSQLInsert;
    function GetAsUpdate: IAqDBSQLUpdate;
  strict protected
    function GetCommandType: TAqDBSQLCommandType;
    function GetSourceType: TAqDBSQLSourceType; override;
    function GetAsSelect: IAqDBSQLSelect; override;
  public
    constructor Create(const pSource: TAqDBSQLSource; const pAlias: string = ''); overload;
    constructor Create(const pSourceTable: string; const pAlias: string = ''); overload;
    destructor Destroy; override;

    function AddColumn(pValue: IAqDBSQLValue): Int32; overload;
    function AddColumn(const pExpression: string; const pAlias: string = ''; pSource: IAqDBSQLSource = nil;
      const pAggregator: TAqDBSQLAggregatorType = atNone): IAqDBSQLColumn; overload;

    function AddJoin(const pType: TAqDBSQLJoinType; pSource: IAqDBSQLSource;
      pCondition: IAqDBSQLCondition): IAqDBSQLJoin;

    function AddOrderBy(pValue: IAqDBSQLValue): Int32;

    procedure UnsetLimit;
  end;

  TAqDBSQLCommand = class(TAqDBSQLAbstraction, IAqDBSQLCommand)
  strict protected
    function GetCommandType: TAqDBSQLCommandType; virtual; abstract;
    function GetAsDelete: IAqDBSQLDelete; virtual;
    function GetAsInsert: IAqDBSQLInsert; virtual;
    function GetAsSelect: IAqDBSQLSelect; virtual;
    function GetAsUpdate: IAqDBSQLUpdate; virtual;
  end;

  TAqDBSQLAssignment = class(TAqDBSQLAbstraction, IAqDBSQLAssignment)
  strict private
    FColumn: IAqDBSQLColumn;
    FValue: IAqDBSQLValue;

    function GetColumn: IAqDBSQLColumn;
    function GetValue: IAqDBSQLValue;
  public
    constructor Create(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue);
  end;

  TAqDBSQLInsert = class(TAqDBSQLCommand, IAqDBSQLInsert)
  strict private
    FTable: IAqDBSQLTable;
    FAssignments: TAqList<IAqDBSQLAssignment>;

    function GetAssignments: IAqReadList<IAqDBSQLAssignment>;
    function GetTable: IAqDBSQLTable;
  strict protected
    function GetCommandType: TAqDBSQLCommandType; override;
    function GetAsInsert: IAqDBSQLInsert; override;
  public
    constructor Create(pTable: IAqDBSQLTable); overload;
    constructor Create(const pTableName: string); overload;
    destructor Destroy; override;

    function AddAssignment(pAssignment: IAqDBSQLAssignment): Int32; overload;
    function AddAssignment(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue): IAqDBSQLAssignment; overload;
  end;

  TAqDBSQLUpdate = class(TAqDBSQLCommand, IAqDBSQLUpdate)
  strict private
    FTable: IAqDBSQLTable;
    FAssignments: TAqList<IAqDBSQLAssignment>;
    FCondition: IAqDBSQLCondition;

    function GetAssignments: IAqReadList<IAqDBSQLAssignment>;
    function GetTable: IAqDBSQLTable;
    function GetIsConditionDefined: Boolean;
    function GetCondition: IAqDBSQLCondition;
    procedure SetCondition(pValue: IAqDBSQLCondition);
  strict protected
    function GetCommandType: TAqDBSQLCommandType; override;
    function GetAsUpdate: IAqDBSQLUpdate; override;
  public
    constructor Create(pTable: IAqDBSQLTable); overload;
    constructor Create(const pTableName: string); overload;
    destructor Destroy; override;

    function AddAssignment(pAssignment: IAqDBSQLAssignment): Int32; overload;
    function AddAssignment(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue): IAqDBSQLAssignment; overload;
  end;

  TAqDBSQLDelete = class(TAqDBSQLCommand, IAqDBSQLDelete)
  strict private
    FTable: IAqDBSQLTable;
    FCondition: IAqDBSQLCondition;

    function GetTable: IAqDBSQLTable;
    function GetIsConditionDefined: Boolean;
    function GetCondition: IAqDBSQLCondition;
    procedure SetCondition(pValue: IAqDBSQLCondition);
  strict protected
    function GetCommandType: TAqDBSQLCommandType; override;
    function GetAsDelete: IAqDBSQLDelete; override;
  public
    constructor Create(pTable: IAqDBSQLTable); overload;
    constructor Create(const pTableName: string); overload;
  end;

implementation

uses
  AqDrop.Core.Exceptions;

{ TAqDBSQLColumn }

function TAqDBSQLColumn.GetAsColumn: IAqDBSQLColumn;
begin
  Result := Self;
end;

constructor TAqDBSQLColumn.Create(const pExpression: string; pSource: IAqDBSQLSource;
  const pAlias: string; const pAggregator: TAqDBSQLAggregatorType);
begin
  inherited Create(pAlias, pAggregator);

  FExpression := pExpression;
  FSource := pSource;
end;

function TAqDBSQLColumn.GetExpression: string;
begin
  Result := FExpression;
end;

function TAqDBSQLColumn.GetSource: IAqDBSQLSource;
begin
  Result := FSource;
end;

function TAqDBSQLColumn.GetIsSourceDefined: Boolean;
begin
  Result := Assigned(FSource);
end;

function TAqDBSQLColumn.GetValueType: TAqDBSQLValueType;
begin
  Result := TAqDBSQLValueType.vtColumn;
end;

{ TAqDBSQLAliasable }

constructor TAqDBSQLAliasable.Create(const pAlias: string);
begin
  FAlias := pAlias;
end;

{ TAqDBSQLSubselectColumn }

function TAqDBSQLSubselect.GetAsSubselect: IAqDBSQLSubselect;
begin
  Result := Self;
end;

constructor TAqDBSQLSubselect.Create(pSelect: IAqDBSQLSelect; const pAlias: string;
  const pAggregator: TAqDBSQLAggregatorType);
begin
  inherited Create(pAlias, pAggregator);

  FSelect := pSelect;
end;

function TAqDBSQLSubselect.GetSelect: IAqDBSQLSelect;
begin
  Result := FSelect;
end;

function TAqDBSQLSubselect.GetValueType: TAqDBSQLValueType;
begin
  Result := TAqDBSQLValueType.vtSubselect;
end;

{ TAqDBSQLTable }

function TAqDBSQLTable.GetAsTable: IAqDBSQLTable;
begin
  Result := Self;
end;

constructor TAqDBSQLTable.Create(const pName, pAlias: string);
begin
  inherited Create(pAlias);

  FName := pName;
end;

function TAqDBSQLTable.GetName: string;
begin
  Result := FName;
end;

function TAqDBSQLTable.GetSourceType: TAqDBSQLSourceType;
begin
  Result := TAqDBSQLSourceType.stTable;
end;

{ TAqDBSQLSelect }

constructor TAqDBSQLSelect.Create(const pSourceTable, pAlias: string);
begin
  InternalCreate(pAlias);
  FSource := TAqDBSQLTable.Create(pSourceTable);
end;

function TAqDBSQLSelect.CustomizeCondition(const pNewCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
begin
  if GetIsConditionDefined then
  begin
    Result := TAqDBSQLComposedCondition.Create(FCondition);
    Result.AddAnd(pNewCondition)
  end else begin
    Result := TAqDBSQLComposedCondition.Create(pNewCondition);
  end;
end;

function TAqDBSQLSelect.AddColumn(const pExpression: string; const pAlias: string; pSource: IAqDBSQLSource;
  const pAggregator: TAqDBSQLAggregatorType): IAqDBSQLColumn;
begin
  if Assigned(pSource) then
  begin
    Result := TAqDBSQLColumn.Create(pExpression, pSource, pAlias, pAggregator);
  end else begin
    Result := TAqDBSQLColumn.Create(pExpression, Self.FSource, pAlias, pAggregator);
  end;
  FColumns.Add(Result);
end;

function TAqDBSQLSelect.AddColumn(pValue: IAqDBSQLValue): Int32;
begin
  Result := FColumns.Add(pValue);
end;

function TAqDBSQLSelect.AddJoin(const pType: TAqDBSQLJoinType; pSource: IAqDBSQLSource;
  pCondition: IAqDBSQLCondition): IAqDBSQLJoin;
begin
  Result := TAqDBSQLJoin.Create(pType, pSource, pCondition);

  if not Assigned(FJoins) then
  begin
    FJoins := TAqList<IAqDBSQLJoin>.Create;
  end;

  FJoins.Add(Result);
end;

function TAqDBSQLSelect.AddOrderBy(pValue: IAqDBSQLValue): Int32;
begin
  if not Assigned(FOrderBy) then
  begin
    FOrderBy := TAqList<IAqDBSQLValue>.Create;
  end;

  Result := FOrderBy.Add(pValue);
end;

function TAqDBSQLSelect.GetAsDelete: IAqDBSQLDelete;
begin
  raise EAqInternal.Create('Objects of ' + Self.ClassName + ' cannot be consumed as IAqDBDelete.');
end;

function TAqDBSQLSelect.GetAsInsert: IAqDBSQLInsert;
begin
  raise EAqInternal.Create('Objects of ' + Self.ClassName + ' cannot be consumed as IAqDBInsert.');
end;

function TAqDBSQLSelect.GetAsSelect: IAqDBSQLSelect;
begin
  Result := Self;
end;

function TAqDBSQLSelect.GetAsUpdate: IAqDBSQLUpdate;
begin
  raise EAqInternal.Create('Objects of ' + Self.ClassName + ' cannot be consumed as IAqDBSQLUpdate.');
end;

constructor TAqDBSQLSelect.InternalCreate(const pAlias: string);
begin
  inherited Create(pAlias);

  FColumns := TAqList<IAqDBSQLValue>.Create;
  FLimit :=  High(FLimit);
end;

procedure TAqDBSQLSelect.SetCondition(pValue: IAqDBSQLCondition);
begin
  FCondition := pValue;
end;

procedure TAqDBSQLSelect.SetLimit(const pValue: UInt32);
begin
  FLimit := pValue;
end;

procedure TAqDBSQLSelect.UnsetLimit;
begin
  FLimit := High(FLimit);
end;

constructor TAqDBSQLSelect.Create(const pSource: TAqDBSQLSource; const pAlias: string);
begin
  InternalCreate(pAlias);
  FSource := pSource;
end;

destructor TAqDBSQLSelect.Destroy;
begin
  FOrderBy.Free;
  FJoins.Free;
  FColumns.Free;

  inherited;
end;

function TAqDBSQLSelect.GetColumns: IAqReadList<IAqDBSQLValue>;
begin
  Result := FColumns.GetIReadList;
end;

function TAqDBSQLSelect.GetSource: IAqDBSQLSource;
begin
  Result := FSource;
end;

function TAqDBSQLSelect.GetCommandType: TAqDBSQLCommandType;
begin
  Result := TAqDBSQLCommandType.ctSelect;
end;

function TAqDBSQLSelect.GetCondition: IAqDBSQLCondition;
begin
  Result := FCondition;
end;

function TAqDBSQLSelect.GetHasJoins: Boolean;
begin
  Result := Assigned(FJoins) and (FJoins.Count > 0);
end;

function TAqDBSQLSelect.GetIsConditionDefined: Boolean;
begin
  Result := Assigned(FCondition);
end;

function TAqDBSQLSelect.GetIsLimitDefined: Boolean;
begin
  Result := FLimit <> High(FLimit);
end;

function TAqDBSQLSelect.GetIsOrderByDefined: Boolean;
begin
  Result := Assigned(FOrderBy) and (FOrderBy.Count > 0);
end;

function TAqDBSQLSelect.GetJoins: IAqReadList<IAqDBSQLJoin>;
begin
  Result := FJoins.GetIReadList;
end;

function TAqDBSQLSelect.GetLimit: UInt32;
begin
  Result := FLimit;
end;

function TAqDBSQLSelect.GetOrderBy: IAqReadList<IAqDBSQLValue>;
begin
  Result := FOrderBy.GetIReadList;
end;

function TAqDBSQLSelect.GetSourceType: TAqDBSQLSourceType;
begin
  Result := TAqDBSQLSourceType.stSelect;
end;

{ TAqDBSQLSource }

function TAqDBSQLSource.GetAsSelect: IAqDBSQLSelect;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLSelect.');
end;

function TAqDBSQLSource.GetAsTable: IAqDBSQLTable;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBTable.');
end;

{ TAqDBOperationColumn }

function TAqDBSQLOperation.GetAsOperation: IAqDBSQLOperation;
begin
  Result := Self;
end;

constructor TAqDBSQLOperation.Create(pLeftOperand: IAqDBSQLValue; const pOperator: TAqDBSQLOperator;
  pRightOperand: IAqDBSQLValue; const pAlias: string; const pAggregator: TAqDBSQLAggregatorType);
begin
  inherited Create(pAlias, pAggregator);

  FLeftOperand := pLeftOperand;
  FOperator := pOperator;
  FRightOperand := pRightOperand;
end;

function TAqDBSQLOperation.GetOperator: TAqDBSQLOperator;
begin
  Result := FOperator;
end;

function TAqDBSQLOperation.GetRightOperand: IAqDBSQLValue;
begin
  Result := FRightOperand;
end;

function TAqDBSQLOperation.GetLeftOperand: IAqDBSQLValue;
begin
  Result := FLeftOperand;
end;

function TAqDBSQLOperation.GetValueType: TAqDBSQLValueType;
begin
  Result := TAqDBSQLValueType.vtOperation;
end;

{ TAqDBSQLValue }

function TAqDBSQLValue.GetAsColumn: IAqDBSQLColumn;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBColumn.');
end;

function TAqDBSQLValue.GetAsConstant: IAqDBSQLConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLConstant.');
end;

function TAqDBSQLValue.GetAsOperation: IAqDBSQLOperation;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBOperationValue.');
end;

function TAqDBSQLValue.GetAsParameter: IAqDBSQLParameter;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLParameter.');
end;

function TAqDBSQLValue.GetAsSubselect: IAqDBSQLSubselect;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLSubselect.');
end;

constructor TAqDBSQLValue.Create(const pAlias: string; const pAggregator: TAqDBSQLAggregatorType);
begin
  inherited Create(pAlias);

  FAggregator := pAggregator;
end;

function TAqDBSQLAliasable.GetAlias: string;
begin
  Result := FAlias;
end;

function TAqDBSQLAliasable.GetIsAliasDefined: Boolean;
begin
  Result := FAlias <> '';
end;

function TAqDBSQLValue.GetAggregator: TAqDBSQLAggregatorType;
begin
  Result := FAggregator;
end;

{ TAqDBSQLComparisonCondition }

constructor TAqDBSQLComparisonCondition.Create(pLeftValue: IAqDBSQLValue; const pComparison: TAqDBSQLComparison;
  pRightValue: IAqDBSQLValue);
begin
  FLeftValue := pLeftValue;
  FComparison := pComparison;
  FRightValue := pRightValue;
end;

function TAqDBSQLComparisonCondition.GetAsComparison: IAqDBSQLComparisonCondition;
begin
  Result := Self;
end;

function TAqDBSQLComparisonCondition.GetComparison: TAqDBSQLComparison;
begin
  Result := FComparison;
end;

function TAqDBSQLComparisonCondition.GetConditionType: TAqDBSQLConditionType;
begin
  Result := TAqDBSQLConditionType.ctComparison;
end;

function TAqDBSQLComparisonCondition.GetLeftValue: IAqDBSQLValue;
begin
  Result := FLeftValue;
end;

function TAqDBSQLComparisonCondition.GetRightValue: IAqDBSQLValue;
begin
  Result := FRightValue;
end;

{ TAqDBSQLValueIsNullCondition }

constructor TAqDBSQLValueIsNullCondition.Create(pValue: IAqDBSQLValue);
begin
  FValue := pValue;
end;

function TAqDBSQLValueIsNullCondition.GetAsValueIsNull: IAqDBSQLValueIsNullCondition;
begin
  Result := Self;
end;

function TAqDBSQLValueIsNullCondition.GetConditionType: TAqDBSQLConditionType;
begin
  Result := TAqDBSQLConditionType.ctValueIsNull;
end;

function TAqDBSQLValueIsNullCondition.GetValue: IAqDBSQLValue;
begin
  Result := FValue;
end;

{ TAqDBSQLAbstraction }

class function TAqDBSQLAbstraction.MustCountReferences: Boolean;
begin
  Result := True;
end;

{ TAqDBSQLJoin }

constructor TAqDBSQLJoin.Create(const pType: TAqDBSQLJoinType; pSource: IAqDBSQLSource; pCondition: IAqDBSQLCondition);
begin
  inherited Create;

  FSource := pSource;
  FCondition := pCondition;
end;

function TAqDBSQLJoin.GetCondition: IAqDBSQLCondition;
begin
  Result := FCondition;
end;

function TAqDBSQLJoin.GetJoinType: TAqDBSQLJoinType;
begin
  Result := FType;
end;

function TAqDBSQLJoin.GetSource: IAqDBSQLSource;
begin
  Result := FSource;
end;

{ TAqDBSQLComposedCondition }

function TAqDBSQLComposedCondition.AddAnd(const pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
begin
  AddCondition(TAqDBSQLBooleanOperator.boAnd, pCondition);
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddCondition(const pLinkOperator: TAqDBSQLBooleanOperator;
  pCondition: IAqDBSQLCondition): Int32;
begin
  FOperators.Add(pLinkOperator);
  Result := FConditions.Add(pCondition);
end;

function TAqDBSQLComposedCondition.AddOr(const pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
begin
  AddCondition(TAqDBSQLBooleanOperator.boOr, pCondition);
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddXor(const pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
begin
  AddCondition(TAqDBSQLBooleanOperator.boXor, pCondition);
  Result := Self;
end;

constructor TAqDBSQLComposedCondition.Create(const pInitialCondition: IAqDBSQLCondition);
begin
  FConditions := TAqList<IAqDBSQLCondition>.Create;
  FOperators := TAqList<TAqDBSQLBooleanOperator>.Create;
  FConditions.Add(pInitialCondition);
end;

destructor TAqDBSQLComposedCondition.Destroy;
begin
  FOperators.Free;
  FConditions.Free;

  inherited;
end;

function TAqDBSQLComposedCondition.GetAsComposed: IAqDBSQLComposedCondition;
begin
  Result := Self;
end;

function TAqDBSQLComposedCondition.GetConditions: IAqReadList<AqDrop.DB.SQL.Intf.IAqDBSQLCondition>;
begin
  Result := FConditions.GetIReadList;
end;

function TAqDBSQLComposedCondition.GetConditionType: TAqDBSQLConditionType;
begin
  Result := TAqDBSQLConditionType.ctComposed;
end;

function TAqDBSQLComposedCondition.GetLinkOperators: IAqReadList<AqDrop.DB.SQL.Intf.TAqDBSQLBooleanOperator>;
begin
  Result := FOperators.GetIReadList;
end;

{ TAqDBSQLCondition }

function TAqDBSQLCondition.GetAsBetween: IAqDBSQLBetweenCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLComparisonCondition.');
end;

function TAqDBSQLCondition.GetAsComparison: IAqDBSQLComparisonCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLComparisonCondition.');
end;

function TAqDBSQLCondition.GetAsComposed: IAqDBSQLComposedCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLComposedCondition.');
end;

function TAqDBSQLCondition.GetAsValueIsNull: IAqDBSQLValueIsNullCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName +
    ' cannot be consumed as IAqDBSQLValueIsNullCondition.');
end;

{ TAqDBSQLCommand }

function TAqDBSQLCommand.GetAsDelete: IAqDBSQLDelete;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLDelete.');
end;

function TAqDBSQLCommand.GetAsInsert: IAqDBSQLInsert;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLInsert.');
end;

function TAqDBSQLCommand.GetAsSelect: IAqDBSQLSelect;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLSelect.');
end;

function TAqDBSQLCommand.GetAsUpdate: IAqDBSQLUpdate;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLUpdate.');
end;

{ TAqDBSQLInsert }

constructor TAqDBSQLInsert.Create(pTable: IAqDBSQLTable);
begin
  FTable := pTable;
  FAssignments := TAqList<IAqDBSQLAssignment>.Create;
end;

function TAqDBSQLInsert.AddAssignment(pAssignment: IAqDBSQLAssignment): Int32;
begin
  Result := FAssignments.Add(pAssignment);
end;

function TAqDBSQLInsert.AddAssignment(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue): IAqDBSQLAssignment;
begin
  Result := TAqDBSQLAssignment.Create(pColumn, pValue);
  FAssignments.Add(Result);
end;

constructor TAqDBSQLInsert.Create(const pTableName: string);
begin
  Create(TAqDBSQLTable.Create(pTableName));
end;

destructor TAqDBSQLInsert.Destroy;
begin
  FAssignments.Free;

  inherited;
end;

function TAqDBSQLInsert.GetAsInsert: IAqDBSQLInsert;
begin
  Result := Self;
end;

function TAqDBSQLInsert.GetAssignments: IAqReadList<IAqDBSQLAssignment>;
begin
  Result := FAssignments.GetIReadList;
end;

function TAqDBSQLInsert.GetCommandType: TAqDBSQLCommandType;
begin
  Result := TAqDBSQLCommandType.ctInsert;
end;

function TAqDBSQLInsert.GetTable: IAqDBSQLTable;
begin
  Result := FTable;
end;

{ TAqDBSQLAssignment }

constructor TAqDBSQLAssignment.Create(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue);
begin
  FColumn := pColumn;
  FValue := pValue;
end;

function TAqDBSQLAssignment.GetColumn: IAqDBSQLColumn;
begin
  Result := FColumn;
end;

function TAqDBSQLAssignment.GetValue: IAqDBSQLValue;
begin
  Result := FValue;
end;

{ TAqDBSQLParameter }

constructor TAqDBSQLParameter.Create(const pName: string; const pAlias: string = '';
  const pAggregator: TAqDBSQLAggregatorType = atNone);
begin
  inherited Create(pAlias, pAggregator);

  FName := pName;
end;

function TAqDBSQLParameter.GetAsParameter: IAqDBSQLParameter;
begin
  Result := Self;
end;

function TAqDBSQLParameter.GetName: string;
begin
  Result := FName;
end;

function TAqDBSQLParameter.GetValueType: TAqDBSQLValueType;
begin
  Result := TAqDBSQLValueType.vtParameter;
end;

{ TAqDBSQLBetweenCondition }

constructor TAqDBSQLBetweenCondition.Create(pValue, pRangeBegin, pRangeEnd: IAqDBSQLValue);
begin
  FValue := pValue;
  FRangeBegin := pRangeBegin;
  FRangeEnd := pRangeEnd;
end;

function TAqDBSQLBetweenCondition.GetAsBetween: IAqDBSQLBetweenCondition;
begin
  Result := Self;
end;

function TAqDBSQLBetweenCondition.GetConditionType: TAqDBSQLConditionType;
begin
  Result := TAqDBSQLConditionType.ctBetween;
end;

function TAqDBSQLBetweenCondition.GetRangeEnd: IAqDBSQLValue;
begin
  Result := FRangeEnd;
end;

function TAqDBSQLBetweenCondition.GetRangeBegin: IAqDBSQLValue;
begin
  Result := FRangeBegin;
end;

function TAqDBSQLBetweenCondition.GetValue: IAqDBSQLValue;
begin
  Result := FValue;
end;

{ TAqDBSQLConstant }

function TAqDBSQLConstant.GetAsBooleanConstant: IAqDBSQLBooleanConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLBooleanConstant.');
end;

function TAqDBSQLConstant.GetAsConstant: IAqDBSQLConstant;
begin
  Result := Self;
end;

function TAqDBSQLConstant.GetAsDateConstant: IAqDBSQLDateConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLDateConstant.');
end;

function TAqDBSQLConstant.GetAsDateTimeConstant: IAqDBSQLDateTimeConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLDateTimeConstant.');
end;

function TAqDBSQLConstant.GetAsNumericConstant: IAqDBSQLNumericConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLNumericConstant.');
end;

function TAqDBSQLConstant.GetAsTextConstant: IAqDBSQLTextConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLTextConstant.');
end;

function TAqDBSQLConstant.GetAsTimeConstant: IAqDBSQLTimeConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.ClassName + ' cannot be consumed as IAqDBSQLTimeConstant.');
end;

function TAqDBSQLConstant.GetValueType: TAqDBSQLValueType;
begin
  Result := TAqDBSQLValueType.vtConstant;
end;

{ TAqDBSQLTextConstant }

constructor TAqDBSQLTextConstant.Create(const pValue: string; const pAlias: string = '';
  const pAggregator: TAqDBSQLAggregatorType = atNone);
begin
  inherited Create(pAlias, pAggregator);

  FValue := pValue;
end;

function TAqDBSQLTextConstant.GetAsTextConstant: IAqDBSQLTextConstant;
begin
  Result := Self;
end;

function TAqDBSQLTextConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvText;
end;

function TAqDBSQLTextConstant.GetValue: string;
begin
  Result := FValue;
end;

{ TAqDBSQLNumericConstant }

constructor TAqDBSQLNumericConstant.Create(const pValue: Double; const pAlias: string = '';
  const pAggregator: TAqDBSQLAggregatorType = atNone);
begin
  inherited Create(pAlias, pAggregator);

  FValue := pValue;
end;

function TAqDBSQLNumericConstant.GetAsNumericConstant: IAqDBSQLNumericConstant;
begin
  Result := Self;
end;

function TAqDBSQLNumericConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvNumeric;
end;

function TAqDBSQLNumericConstant.GetValue: Double;
begin
  Result := FValue;
end;

{ TAqDBSQLDateTimeConstant }

constructor TAqDBSQLDateTimeConstant.Create(const pValue: TDateTime; const pAlias: string = '';
  const pAggregator: TAqDBSQLAggregatorType = atNone);
begin
  inherited Create(pAlias, pAggregator);

  FValue := pValue;
end;

function TAqDBSQLDateTimeConstant.GetAsDateTimeConstant: IAqDBSQLDateTimeConstant;
begin
  Result := Self;
end;

function TAqDBSQLDateTimeConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvDateTime;
end;

function TAqDBSQLDateTimeConstant.GetValue: TDateTime;
begin
  Result := FValue;
end;

{ TAqDBSQLBooleanConstant }

constructor TAqDBSQLBooleanConstant.Create(const pValue: Boolean; const pAlias: string = '';
  const pAggregator: TAqDBSQLAggregatorType = atNone);
begin
  inherited Create(pAlias, pAggregator);

  FValue := pValue;
end;

function TAqDBSQLBooleanConstant.GetAsBooleanConstant: IAqDBSQLBooleanConstant;
begin
  Result := Self;
end;

function TAqDBSQLBooleanConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvBoolean;
end;

function TAqDBSQLBooleanConstant.GetValue: Boolean;
begin
  Result := FValue;
end;

{ TAqDBSQLDateConstant }

constructor TAqDBSQLDateConstant.Create(const pValue: TDate; const pAlias: string = '';
  const pAggregator: TAqDBSQLAggregatorType = atNone);
begin
  inherited Create(pAlias, pAggregator);

  FValue := pValue;
end;

function TAqDBSQLDateConstant.GetAsDateConstant: IAqDBSQLDateConstant;
begin
  Result := Self;
end;

function TAqDBSQLDateConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvDate;
end;

function TAqDBSQLDateConstant.GetValue: TDate;
begin
  Result := FValue;
end;

{ TAqDBSQLTimeConstant }

constructor TAqDBSQLTimeConstant.Create(const pValue: TTime);
begin
  FValue := pValue;
end;

function TAqDBSQLTimeConstant.GetAsTimeConstant: IAqDBSQLTimeConstant;
begin
  Result := Self;
end;

function TAqDBSQLTimeConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvTime;
end;

function TAqDBSQLTimeConstant.GetValue: TTime;
begin
  Result := FValue;
end;

{ TAqDBSQLUpdate }

function TAqDBSQLUpdate.AddAssignment(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue): IAqDBSQLAssignment;
begin
  Result := TAqDBSQLAssignment.Create(pColumn, pValue);
  FAssignments.Add(Result);
end;

function TAqDBSQLUpdate.AddAssignment(pAssignment: IAqDBSQLAssignment): Int32;
begin
  Result := FAssignments.Add(pAssignment);
end;

constructor TAqDBSQLUpdate.Create(const pTableName: string);
begin
  Create(TAqDBSQLTable.Create(pTableName));
end;

destructor TAqDBSQLUpdate.Destroy;
begin
  FAssignments.Free;

  inherited;
end;

constructor TAqDBSQLUpdate.Create(pTable: IAqDBSQLTable);
begin
  FTable := pTable;
  FAssignments := TAqList<IAqDBSQLAssignment>.Create;
end;

function TAqDBSQLUpdate.GetAssignments: IAqReadList<IAqDBSQLAssignment>;
begin
  Result := FAssignments.GetIReadList;
end;

function TAqDBSQLUpdate.GetAsUpdate: IAqDBSQLUpdate;
begin
  Result := Self;
end;

function TAqDBSQLUpdate.GetCommandType: TAqDBSQLCommandType;
begin
  Result := TAqDBSQLCommandType.ctUpdate;
end;

function TAqDBSQLUpdate.GetCondition: IAqDBSQLCondition;
begin
  Result := FCondition;
end;

function TAqDBSQLUpdate.GetIsConditionDefined: Boolean;
begin
  Result := Assigned(FCondition);
end;

function TAqDBSQLUpdate.GetTable: IAqDBSQLTable;
begin
  Result := FTable;
end;

procedure TAqDBSQLUpdate.SetCondition(pValue: IAqDBSQLCondition);
begin
  FCondition := pValue;
end;

{ TAqDBSQLDelete }

constructor TAqDBSQLDelete.Create(pTable: IAqDBSQLTable);
begin
  FTable := pTable;
end;

constructor TAqDBSQLDelete.Create(const pTableName: string);
begin
  Create(TAqDBSQLTable.Create(pTableName));
end;

function TAqDBSQLDelete.GetAsDelete: IAqDBSQLDelete;
begin
  Result := Self;
end;

function TAqDBSQLDelete.GetCommandType: TAqDBSQLCommandType;
begin
  Result := TAqDBSQLCommandType.ctDelete;
end;

function TAqDBSQLDelete.GetCondition: IAqDBSQLCondition;
begin
  Result := FCondition;
end;

function TAqDBSQLDelete.GetIsConditionDefined: Boolean;
begin
  Result := Assigned(FCondition);
end;

function TAqDBSQLDelete.GetTable: IAqDBSQLTable;
begin
  Result := FTable;
end;

procedure TAqDBSQLDelete.SetCondition(pValue: IAqDBSQLCondition);
begin
  FCondition := pValue;
end;

end.
