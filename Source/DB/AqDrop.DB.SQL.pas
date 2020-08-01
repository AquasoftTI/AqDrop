unit AqDrop.DB.SQL;

interface

uses
  System.Classes,
  System.Rtti,
  AqDrop.Core.Types,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.InterfacedObject,
  AqDrop.DB.SQL.Intf;

type
  TAqDBSQLAliasable = class;
  TAqDBSQLColumn = class;
  TAqDBSQLSubselect = class;
  TAqDBSQLSource = class;
  TAqDBSQLTable = class;
  TAqDBSQLSelect = class;

  TAqDBSQLAbstraction = class(TAqARCObject);

  TAqDBSQLAliasable = class(TAqDBSQLAbstraction, IAqDBSQLAliasable)
  strict private
    FAlias: string;

    function GetAlias: string;
    function GetIsAliasDefined: Boolean;
  strict protected
    procedure SetAlias(const pAlias: string);
    procedure ClearAlias;
  public
    constructor Create(const pAlias: string = '');

    property IsAliasDefined: Boolean read GetIsAliasDefined;
    property Alias: string read GetAlias;
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

    property Aggregator: TAqDBSQLAggregatorType read FAggregator;
  public
    constructor Create(const pAlias: string = ''; const pAggregator: TAqDBSQLAggregatorType = atNone);

    {TODO 3 -oTatu -cMelhoria: verificar se essa função permanece depois ou não, e se o parâmetro type pode ser omitido}
    class function FromValue(const pValue: TValue; const pType: TAqDataType): TAqDBSQLValue;
  end;

  TAqDBSQLColumn = class(TAqDBSQLValue, IAqDBSQLColumn)
  strict private
    FExpression: string;
    FSource: IAqDBSQLSource;
    FDefaultValue: string;

    function GetExpression: string;
    function GetSource: IAqDBSQLSource;
    function GetIsSourceDefined: Boolean;
    Function GetDefaultValue: string;
  strict protected
    function GetValueType: TAqDBSQLValueType; override;
    function GetAsColumn: IAqDBSQLColumn; override;
  public
    function SetDefaultValue(const pValor: string): IAqDBSQLColumn;
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
    function GetAsIntConstant: IAqDBSQLIntConstant; virtual;
    function GetAsUIntConstant: IAqDBSQLUIntConstant; virtual;
    function GetAsDoubleConstant: IAqDBSQLDoubleConstant; virtual;
    function GetAsCurrencyConstant: IAqDBSQLCurrencyConstant; virtual;
    function GetAsDateTimeConstant: IAqDBSQLDateTimeConstant; virtual;
    function GetAsDateConstant: IAqDBSQLDateConstant; virtual;
    function GetAsTimeConstant: IAqDBSQLTimeConstant; virtual;
    function GetAsBooleanConstant: IAqDBSQLBooleanConstant; virtual;
    function GetAsGUIDConstant: IAqDBSQLGUIDConstant; virtual;
  end;

  TAqDBSQLGenericConstant<T> = class(TAqDBSQLConstant)
  strict private
    FValue: T;
  public
    constructor Create(const pValue: T; const pAlias: string = '';
      const pAggregator: TAqDBSQLAggregatorType = atNone);
    function GetValue: T;
    procedure SetValue(const pValue: T);
  end;

  TAqDBSQLTextConstant = class(TAqDBSQLGenericConstant<string>, IAqDBSQLTextConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsTextConstant: IAqDBSQLTextConstant; override;
  end;

  TAqDBSQLIntConstant = class(TAqDBSQLGenericConstant<Int64>, IAqDBSQLIntConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsIntConstant: IAqDBSQLIntConstant; override;
  end;

  TAqDBSQLUIntConstant = class(TAqDBSQLGenericConstant<UInt64>, IAqDBSQLUIntConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsUIntConstant: IAqDBSQLUIntConstant; override;
  end;

  TAqDBSQLDoubleConstant = class(TAqDBSQLGenericConstant<Double>, IAqDBSQLDoubleConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsDoubleConstant: IAqDBSQLDoubleConstant; override;
  end;

  TAqDBSQLCurrencyConstant = class(TAqDBSQLGenericConstant<Currency>, IAqDBSQLCurrencyConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsCurrencyConstant: IAqDBSQLCurrencyConstant; override;
  end;

  TAqDBSQLDateTimeConstant = class(TAqDBSQLGenericConstant<TDateTime>, IAqDBSQLDateTimeConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsDateTimeConstant: IAqDBSQLDateTimeConstant; override;
  end;

  TAqDBSQLDateConstant = class(TAqDBSQLGenericConstant<TDate>, IAqDBSQLDateConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsDateConstant: IAqDBSQLDateConstant; override;
  end;

  TAqDBSQLTimeConstant = class(TAqDBSQLGenericConstant<TTime>, IAqDBSQLTimeConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsTimeConstant: IAqDBSQLTimeConstant; override;
  end;

  TAqDBSQLBooleanConstant = class(TAqDBSQLGenericConstant<Boolean>, IAqDBSQLBooleanConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsBooleanConstant: IAqDBSQLBooleanConstant; override;
  end;

  TAqDBSQLGUIDConstant = class(TAqDBSQLGenericConstant<TGUID>, IAqDBSQLGUIDConstant)
  strict protected
    function GetConstantType: TAqDBSQLConstantValueType; override;
    function GetAsGUIDConstant: IAqDBSQLGUIDConstant; override;
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
  strict private
    FNegated: Boolean;
  strict protected
    function GetConditionType: TAqDBSQLConditionType; virtual; abstract;
    function VerifyIfIsNegated: Boolean;

    function GetAsComparison: IAqDBSQLComparisonCondition; virtual;
    function GetAsValueIsNull: IAqDBSQLValueIsNullCondition; virtual;
    function GetAsComposed: IAqDBSQLComposedCondition; virtual;
    function GetAsBetween: IAqDBSQLBetweenCondition; virtual;
    function GetAsLike: IAqDBSQLLikeCondition; virtual;
    function GetAsIn: IAqDBSQLInCondition; virtual;
    function GetAsExists: IAqDBSQLExistsCondition; virtual;

    function Negate: IAqDBSQLCondition;
  end;

  TAqDBSQLComparisonCondition = class(TAqDBSQLCondition, IAqDBSQLComparisonCondition)
  strict private
    FLeftValue: IAqDBSQLValue;
    FComparison: TAqDBSQLComparison;
    FRightValue: IAqDBSQLValue;

    function GetLeftValue: IAqDBSQLValue;
    function GetComparison: TAqDBSQLComparison;
    function GetRightValue: IAqDBSQLValue;

    procedure SetLeftValue(pValue: IAqDBSQLValue);
    procedure SetRightValue(pValue: IAqDBSQLValue);
    procedure SetComparison(const pComparison: TAqDBSQLComparison);
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
    FConditions: IAqList<IAqDBSQLCondition>;
    FOperators: IAqList<TAqDBSQLBooleanOperator>;

    function GetConditions: IAqReadableList<IAqDBSQLCondition>;
    function GetLinkOperators: IAqReadableList<TAqDBSQLBooleanOperator>;
  strict protected
    function GetConditionType: TAqDBSQLConditionType; override;
    function GetAsComposed: IAqDBSQLComposedCondition; override;
  public
    constructor Create(pInitialCondition: IAqDBSQLCondition = nil);

    function GetIsInitialized: Boolean;

    function AddCondition(const pLinkOperator: TAqDBSQLBooleanOperator; pCondition: IAqDBSQLCondition): Int32;
    function AddAnd(pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
    function AddOr(pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
    function AddXor(pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;

    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: UInt64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: UInt64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison; pValue: Boolean;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison; pValue: Boolean;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;

    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: UInt64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: UInt64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: Boolean;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: Boolean;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: TGUID;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnEqual(const pColumnName: string; pValue: TGUID;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;

    function AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(const pColumnName: string; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(const pColumnName: string; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(const pColumnName: string; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(const pColumnName: string; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(const pColumnName: string; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(const pColumnName: string; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(const pColumnName: string; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterThan(const pColumnName: string; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;

    function AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(const pColumnName: string; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(const pColumnName: string; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(const pColumnName: string; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(const pColumnName: string; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(const pColumnName: string; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(const pColumnName: string; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(const pColumnName: string; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnGreaterEqualThan(const pColumnName: string; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;

    function AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(const pColumnName: string; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(const pColumnName: string; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(const pColumnName: string; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(const pColumnName: string; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(const pColumnName: string; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(const pColumnName: string; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(const pColumnName: string; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessThan(const pColumnName: string; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;

    function AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(const pColumnName: string; pValue: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(const pColumnName: string; pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(const pColumnName: string; pValue: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(const pColumnName: string; pValue: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(const pColumnName: string; pValue: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(const pColumnName: string; pValue: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(const pColumnName: string; pValue: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLessEqualThan(const pColumnName: string; pValue: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;

    function AddColumnIsNull(pColumn: IAqDBSQLColumn;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnIsNull(const pColumnName: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;

    function AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(const pColumnName: string; const pLeftBoundary, pRightBoundary: IAqDBSQLValue;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(const pColumnName: string; const pLeftBoundary, pRightBoundary: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(const pColumnName: string; const pLeftBoundary, pRightBoundary: Int64;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(const pColumnName: string; const pLeftBoundary, pRightBoundary: Double;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(const pColumnName: string; const pLeftBoundary, pRightBoundary: Currency;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(const pColumnName: string; const pLeftBoundary, pRightBoundary: TDateTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(const pColumnName: string; const pLeftBoundary, pRightBoundary: TDate;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnBetween(const pColumnName: string; const pLeftBoundary, pRightBoundary: TTime;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;

    function AddColumnLike(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLTextConstant;
      const pLeftWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pRightWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLike(pColumn: IAqDBSQLColumn; const pValue: string;
      const pLeftWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pRightWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLike(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLTextConstant;
      const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition; overload;
    function AddColumnLike(pColumn: IAqDBSQLColumn; const pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition; overload;
    function AddColumnLike(const pColumnName: string; pValue: IAqDBSQLTextConstant;
      const pLeftWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pRightWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLike(const pColumnName: string; const pValue: string;
      const pLeftWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pRightWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd):
      IAqDBSQLComposedCondition; overload;
    function AddColumnLike(const pColumnName: string; pValue: IAqDBSQLTextConstant;
      const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition; overload;
    function AddColumnLike(const pColumnName: string; const pValue: string;
      const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition; overload;
  end;

  TAqDBSQLBetweenCondition = class(TAqDBSQLCondition, IAqDBSQLBetweenCondition)
  strict private
    FValue: IAqDBSQLValue;
    FLeftBoundary: IAqDBSQLValue;
    FRightBoundary: IAqDBSQLValue;
    function GetValue: IAqDBSQLValue;
    function GetLeftBoundary: IAqDBSQLValue;
    function GetRightBoundary: IAqDBSQLValue;
  strict protected
    function GetAsBetween: IAqDBSQLBetweenCondition; override;
    function GetConditionType: TAqDBSQLConditionType; override;
  public
    constructor Create(pValue, pLeftBoundary, pRightBoundary: IAqDBSQLValue);
  end;

  TAqDBSQLInCondition = class(TAqDBSQLCondition, IAqDBSQLInCondition)
  strict private
    FTestableValue: IAqDBSQLValue;
    FInValues: IAqList<IAqDBSQLValue>;

    function GetTestableValue: IAqDBSQLValue;
    function GetInValues: IAqReadableList<IAqDBSQLValue>;

    procedure SetTestableValue(pValue: IAqDBSQLValue);
    procedure AddInValue(pValue: IAqDBSQLValue);
  strict protected
    function GetAsIn: IAqDBSQLInCondition; override;
    function GetConditionType: TAqDBSQLConditionType; override;
  public
    constructor Create(pTestableValue: IAqDBSQLValue); overload;
  end;

  TAqDBSQLExistsCondition = class(TAqDBSQLCondition, IAqDBSQLExistsCondition)
  strict private
    FSelect: IAqDBSQLSelect;
  strict protected
    function GetSelect: IAqDBSQLSelect;
    function GetAsExists: IAqDBSQLExistsCondition; override;
    function GetConditionType: TAqDBSQLConditionType; override;
  public
    constructor Create(pSource: IAqDBSQLSource); overload;
    constructor Create(pTable: string); overload;
  end;

  TAqDBSQLLikeCondition = class(TAqDBSQLCondition, IAqDBSQLLikeCondition)
  strict private
    FLeftValue: IAqDBSQLValue;
    FRightValue: IAqDBSQLTextConstant;
    FLeftWildCard: TAqDBSQLLikeWildCard;
    FRightWildCard: TAqDBSQLLikeWildCard;

    function GetLeftValue: IAqDBSQLValue;
    function GetRightValue: IAqDBSQLTextConstant;
    procedure SetLeftValue(pValue: IAqDBSQLValue);
    procedure SetRightValue(pValue: IAqDBSQLTextConstant);
    function GetLeftWildCard: TAqDBSQLLikeWildCard;
    function GetRightWildCard: TAqDBSQLLikeWildCard;
    procedure SetLeftWildCard(pValue: TAqDBSQLLikeWildCard);
    procedure SetRightWildCard(pValue: TAqDBSQLLikeWildCard);
  strict protected
    function GetAsLike: IAqDBSQLLikeCondition; override;
    function GetConditionType: TAqDBSQLConditionType; override;
  public
    constructor Create(pLeftValue: IAqDBSQLValue; pRightValue: IAqDBSQLTextConstant;
      const pLeftWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pRightWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars); overload;
    constructor Create(pLeftValue: string; pRightValue: string;
      const pLeftWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars;
      const pRightWildCard: TAqDBSQLLikeWildCard = TAqDBSQLLikeWildCard.lwcMultipleChars); overload;
  end;

  TAqDBSQLJoin = class(TAqDBSQLAbstraction, IAqDBSQLJoin)
  strict private
    FType: TAqDBSQLJoinType;
    FPreviousJoin: IAqDBSQLJoin;
    FJoinSource: IAqDBSQLSource;
    FMainSource: IAqDBSQLSource;

    function GetJoinType: TAqDBSQLJoinType;
    function GetHasPreviousJoin: Boolean;
    function GetPreviousJoin: IAqDBSQLJoin;
    procedure UpdateJoinTypeWithHighestPriority(const pJoinType: TAqDBSQLJoinType);
  strict protected
    function GetSource: IAqDBSQLSource;
    function GetMainSource: IAqDBSQLSource;
    function GetConditionType: TAqDBSQLJoinConditionType; virtual; abstract;
    function GetIdentifier: string; virtual;
    function GetAsJoinWithComposedCondition: IAqDBSQLJoinWithComposedCondition; virtual;
    function GetAsJoinWithCustomCondition: IAqDBSQLJoinWithCustomCondition; virtual;
    procedure RaiseNotPossibleToMountIdentifier;
  public
    constructor Create(const pType: TAqDBSQLJoinType; pJoinSource: IAqDBSQLSource;
      pMainSource: IAqDBSQLSource = nil); overload;
    constructor Create(const pType: TAqDBSQLJoinType; pPreviousJoin: IAqDBSQLJoin;
      pJoinSource: IAqDBSQLSource); overload;
  end;

  TAqDBSQLJoinWithComposedCondition = class(TAqDBSQLJoin, IAqDBSQLJoinWithComposedCondition)
  strict private
    FCondition: IAqDBSQLCondition;

    function GetCondition: IAqDBSQLCondition;

    function &On(const pColumnName: string): IAqDBSQLJoinWithComposedCondition;
    function EqualsTo(pValue: IAqDBSQLValue): IAqDBSQLJoinWithComposedCondition; overload;
    function EqualsTo(const pColumnName: string): IAqDBSQLJoinWithComposedCondition; overload;
  strict protected
    function GetConditionType: TAqDBSQLJoinConditionType; override;
    function GetIdentifier: string; override;
    function GetAsJoinWithComposedCondition: IAqDBSQLJoinWithComposedCondition; override;
  public
    constructor Create(const pType: TAqDBSQLJoinType; pJoinSource: IAqDBSQLSource;
      pCondition: IAqDBSQLCondition); overload;
    constructor Create(const pType: TAqDBSQLJoinType; pJoinSource, pMasterSource: IAqDBSQLSource;
      pCondition: IAqDBSQLCondition); overload;
    constructor Create(const pType: TAqDBSQLJoinType; pPreviousJoin: IAqDBSQLJoin;
      pJoinSource: IAqDBSQLSource; pCondition: IAqDBSQLCondition); overload;
  end;

  TAqDBSQLJoinWithCustomCondition = class(TAqDBSQLJoin, IAqDBSQLJoinWithCustomCondition)
  strict private
    FCustomCondition: string;

    function GetCustomCondition: string;
  strict protected
    function GetConditionType: TAqDBSQLJoinConditionType; override;
    function GetIdentifier: string; override;
    function GetAsJoinWithCustomCondition: IAqDBSQLJoinWithCustomCondition; override;
  public
    constructor Create(const pType: TAqDBSQLJoinType; pJoinSource: IAqDBSQLSource;
      const pCustomCondition: string); overload;
    constructor Create(const pType: TAqDBSQLJoinType; pJoinSource, pMasterSource: IAqDBSQLSource;
      const pCustomCondition: string); overload;
    constructor Create(const pType: TAqDBSQLJoinType; pPreviousJoin: IAqDBSQLJoin;
      pJoinSource: IAqDBSQLSource; const pCustomCondition: string); overload;
  end;

  TAqDBSQLOrderByItem = class(TAqDBSQLAbstraction, IAqDBSQLOrderByItem)
  strict private
    FValue: IAqDBSQLValue;
    FAscending: Boolean;

    function GetValue: IAqDBSQLValue;
    function GetIsAscending: Boolean;
  public
    constructor Create(pValue: IAqDBSQLValue; const pAscending: Boolean);
  end;

  TAqDBSQLConditionDescriptor = class(TAqARCObject, IAqDBSQLConditionDescriptor)
  strict private
    FNegated: Boolean;
  strict protected
    function GetConditionDescriptorType: TAqDBSQLConditionDescriptorType; virtual; abstract;

    function GetAsComposedConditionDescriptor: IAqDBSQLComposedConditionDescriptor; virtual;
    function GetAsSimpleComparisonDescriptor: IAqDBSQLSimpleComparisonDescriptor; virtual;
    function GetAsLikeDescriptor: IAqDBSQLLikeDescriptor; virtual;
    function GetAsBetweenDescriptor: IAqDBSQLBetweenDescriptor; virtual;
    function GetAsInDescriptor: IAqDBSQLInDescriptor; virtual;
    function GetAsIsNullDescriptor: IAqDBSQLIsNullDescriptor; virtual;
    function GetAsIsNotNullDescriptor: IAqDBSQLIsNotNullDescriptor; virtual;

    function VerifyIfIsNegated: Boolean;
    function Negate: IAqDBSQLConditionDescriptor;
  end;

  TAqDBSQLComposedConditionDescriptor = class(TAqDBSQLConditionDescriptor, IAqDBSQLComposedConditionDescriptor)
  strict private
    FConditions: IAqList<IAqDBSQLConditionDescriptor>;
    FLinks: IAqList<TAqDBSQLBooleanOperator>;

    function GetCount: Int32;
    function GetItem(const pIndex: Int32): IAqDBSQLConditionDescriptor;
    function GetLinkOperator(const pIndex: Int32): TAqDBSQLBooleanOperator;

    function AddCondition(pCondition: IAqDBSQLConditionDescriptor;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd): Int32;
    function AddComposedDescriptor(
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd): IAqDBSQLComposedConditionDescriptor;
    function AddComparison(const pSourceIdentifier, pColumnName: string; const pComparison: TAqDBSQLComparison;
      pComparisonValue: IAqDBSQLValue; const pLinkOperator: TAqDBSQLBooleanOperator =
      TAqDBSQLBooleanOperator.boAnd): IAqDBSQLSimpleComparisonDescriptor; overload;
    function AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
      pComparisonValue: IAqDBSQLValue; const pLinkOperator: TAqDBSQLBooleanOperator =
      TAqDBSQLBooleanOperator.boAnd): IAqDBSQLSimpleComparisonDescriptor; overload;
    function AddLike(const pSourceIdentifier, pColumnName: string; pLikeValue: IAqDBSQLTextConstant;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd): IAqDBSQLLikeDescriptor; overload;
    function AddLike(const pColumnName: string; pLikeValue: IAqDBSQLTextConstant;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd): IAqDBSQLLikeDescriptor; overload;
    function AddIsNull(const pColumnName: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd): IAqDBSQLIsNullDescriptor; overload;
    function AddIsNull(const pSourceIdentifier, pColumnName: string;
      const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd): IAqDBSQLIsNullDescriptor; overload;

    {Métodos para sintaxe fluente}
    function AndColumnEquals(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: string): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pColumnName: string;
      pComparisonValue: string): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: TDateTime): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pColumnName: string;
      pComparisonValue: TDateTime): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pColumnName: string;
      pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: TGUID): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnEquals(const pColumnName: string;
      pComparisonValue: TGUID): IAqDBSQLComposedConditionDescriptor; overload;

    function AndColumnIsLessOrEqual(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsLessOrEqual(const pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsLessOrEqual(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsLessOrEqual(const pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsLessOrEqual(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsLessOrEqual(const pColumnName: string;
      pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsLessOrEqual(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsLessOrEqual(const pColumnName: string;
      pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor; overload;

    function AndColumnIsGreaterOrEqual(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreaterOrEqual(const pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreaterOrEqual(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreaterOrEqual(const pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreaterOrEqual(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreaterOrEqual(const pColumnName: string;
      pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreaterOrEqual(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreaterOrEqual(const pColumnName: string;
      pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor; overload;

    function AndColumnIsGreater(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreater(const pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreater(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreater(const pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreater(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreater(const pColumnName: string;
      pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreater(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsGreater(const pColumnName: string;
      pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor; overload;

    function AndColumnLike(const pSourceIdentifier, pColumnName: string;
      pLikeValue: IAqDBSQLTextConstant): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnLike(const pColumnName: string;
      pLikeValue: IAqDBSQLTextConstant): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnLike(const pSourceIdentifier, pColumnName: string;
      pLikeValue: string): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnLike(const pColumnName: string;
      pLikeValue: string): IAqDBSQLComposedConditionDescriptor; overload;

    function AndColumnIsNull(const pSourceIdentifier, pColumnName: string): IAqDBSQLComposedConditionDescriptor; overload;
    function AndColumnIsNull(const pColumnName: string): IAqDBSQLComposedConditionDescriptor; overload;

    function OrColumnEquals(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function OrColumnEquals(const pColumnName: string;
      pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor; overload;
    function OrColumnEquals(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function OrColumnEquals(const pColumnName: string;
      pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor; overload;
    function OrColumnEquals(const pSourceIdentifier, pColumnName: string;
      pComparisonValue: String): IAqDBSQLComposedConditionDescriptor; overload;
    function OrColumnEquals(const pColumnName: string;
      pComparisonValue: String): IAqDBSQLComposedConditionDescriptor; overload;

    function OrColumnLike(const pSourceIdentifier, pColumnName: string;
      pLikeValue: IAqDBSQLTextConstant): IAqDBSQLComposedConditionDescriptor; overload;
    function OrColumnLike(const pColumnName: string;
      pLikeValue: IAqDBSQLTextConstant): IAqDBSQLComposedConditionDescriptor; overload;
    function OrColumnLike(const pSourceIdentifier, pColumnName: string;
      pLikeValue: string): IAqDBSQLComposedConditionDescriptor; overload;
    function OrColumnLike(const pColumnName: string;
      pLikeValue: string): IAqDBSQLComposedConditionDescriptor; overload;

    function OrColumnIsNull(const pSourceIdentifier, pColumnName: string): IAqDBSQLComposedConditionDescriptor; overload;
    function OrColumnIsNull(const pColumnName: string): IAqDBSQLComposedConditionDescriptor; overload;
  strict protected
    function GetConditionDescriptorType: TAqDBSQLConditionDescriptorType; override;
    function GetAsComposedConditionDescriptor: IAqDBSQLComposedConditionDescriptor; override;
  public
    constructor Create;
  end;

  TAqDBSQLColumnBasedConditionDescriptor = class(TAqDBSQLConditionDescriptor, IAqDBSQLColumnBasedConditionDescriptor)
  strict private
    FColumnName: string;
    FSourceIdentifier: string;

    function GetColumnName: string;
    function VerifyIfHasSourceIdentifier: Boolean;
    function GetSourceIdentifier: string;
    procedure SetSourceIdentifier(const pValue: string);
    procedure ClearSourceIdentifier;
  public
    constructor Create(const pColumnName: string);
  end;

  TAqDBSQLSimpleComparisonDescriptor = class(TAqDBSQLColumnBasedConditionDescriptor, IAqDBSQLSimpleComparisonDescriptor)
  strict private
    FComparison: TAqDBSQLComparison;
    FComparisonValue: IAqDBSQLValue;

    function GetComparison: TAqDBSQLComparison;
    function GetComparisonValue: IAqDBSQLValue;
  strict protected
    function GetConditionDescriptorType: TAqDBSQLConditionDescriptorType; override;
    function GetAsSimpleComparisonDescriptor: IAqDBSQLSimpleComparisonDescriptor; override;
  public
    constructor Create(const pColumnName: string; const pComparison: TAqDBSQLComparison;
      pComparisonValue: IAqDBSQLValue);
  end;

  TAqDBSQLLikeDescriptor = class(TAqDBSQLColumnBasedConditionDescriptor, IAqDBSQLLikeDescriptor)
  strict private
    FLikeValue: IAqDBSQLTextConstant;

    function GetLikeValue: IAqDBSQLTextConstant;
  strict protected
    function GetConditionDescriptorType: TAqDBSQLConditionDescriptorType; override;
    function GetAsLikeDescriptor: IAqDBSQLLikeDescriptor; override;
  public
    constructor Create(const pColumnName: string; pLikeValue: IAqDBSQLTextConstant);
  end;

  TAqDBSQLBetweenDescriptor = class(TAqDBSQLColumnBasedConditionDescriptor, IAqDBSQLBetweenDescriptor)
  strict private
    FLeftBoundaryValue: IAqDBSQLConstant;
    FRightBoundaryValue: IAqDBSQLConstant;

    function GetLeftBoundaryValue: IAqDBSQLConstant;
    function GetRightBoundaryValue: IAqDBSQLConstant;
  strict protected
    function GetConditionDescriptorType: TAqDBSQLConditionDescriptorType; override;
    function GetAsBetweenDescriptor: IAqDBSQLBetweenDescriptor; override;
  public
    constructor Create(const pColumnName: string; pLeftBoundaryValue, pRightBoundaryValue: IAqDBSQLConstant);
  end;

  TAqDBSQLInDescriptor = class(TAqDBSQLColumnBasedConditionDescriptor, IAqDBSQLInDescriptor)
  strict private
    FInValues: IAqList<IAqDBSQLConstant>;

    function GetInValues: IAqReadableList<IAqDBSQLConstant>;
    procedure AddInValue(pValue: IAqDBSQLConstant);
  strict protected
    function GetConditionDescriptorType: TAqDBSQLConditionDescriptorType; override;
    function GetAsInDescriptor: IAqDBSQLInDescriptor; override;
  public
    constructor Create(const pColumnName: string);
  end;

  TAqDBSQLIsNullDescriptor = class(TAqDBSQLColumnBasedConditionDescriptor, IAqDBSQLIsNullDescriptor)
  strict protected
    function GetConditionDescriptorType: TAqDBSQLConditionDescriptorType; override;
    function GetAsIsNullDescriptor: IAqDBSQLIsNullDescriptor; override;
  end;

  TAqDBSQLIsNotNullDescriptor = class(TAqDBSQLColumnBasedConditionDescriptor, IAqDBSQLIsNotNullDescriptor)
  strict protected
    function GetConditionDescriptorType: TAqDBSQLConditionDescriptorType; override;
    function GetAsIsNotNullDescriptor: IAqDBSQLIsNotNullDescriptor; override;
  end;

  TAqDBSQLJoinParameters = class(TAqDBSQLAbstraction, IAqDBSQLJoinParameters)
  strict private
    FJoinType: TAqDBSQLJoinType;
    {TODO 3 -oTatu -cMelhoria: atualmente o mais source join permanece com uma referência para um objeto original, mesmo que este idealmente
    tenha sido descartado durante um takesetup (caso de identifier já existente), então seria bom estudar se isto está ok, ou se seria possível
    trocar a referência pela que ficou}
    FMainSourceJoin: IAqDBSQLJoinParameters;
    FCustomCondition: string;
    FMainColumns: TStringList;
    FJoinTable: string;
    FJoinTableAlias: string;
    FJoinColumns: TStringList;
  public
    constructor Create(const pJoinTable: string; const pMainTableColumns, pJoinTableColumns: TStrings;
      const pJoinType: TAqDBSQLJoinType = TAqDBSQLJoinType.jtLeftJoin); overload;
    constructor Create(const pJoinTable: string; const pMainTableColumns, pJoinTableColumns: string;
      const pJoinType: TAqDBSQLJoinType = TAqDBSQLJoinType.jtLeftJoin); overload;
    constructor Create(pMainSourceJoin: IAqDBSQLJoinParameters; const pJoinTable: string;
      const pMainTableColumns, pJoinTableColumns: string;
      const pJoinType: TAqDBSQLJoinType = TAqDBSQLJoinType.jtLeftJoin); overload;
    constructor Create(pMainSourceJoin: IAqDBSQLJoinParameters; const pJoinTable: string;
      const pMainTableColumns, pJoinTableColumns: TStrings;
      const pJoinType: TAqDBSQLJoinType = TAqDBSQLJoinType.jtLeftJoin); overload;
    constructor Create(const pJoinTable: string; const pCustomCondition: string;
      const pJoinType: TAqDBSQLJoinType = TAqDBSQLJoinType.jtLeftJoin); overload;
    constructor Create(pMainSourceJoin: IAqDBSQLJoinParameters; const pJoinTable, pCustomCondition: string;
      const pJoinType: TAqDBSQLJoinType = TAqDBSQLJoinType.jtLeftJoin); overload;
    destructor Destroy; override;

    function GetJoinType: TAqDBSQLJoinType;
    function GetMainSourceJoin: IAqDBSQLJoinParameters;
    function VerifyIfHasCustomCondition: Boolean;
    function GetCustomCondition: string;
    function GetMainColumns: TStrings;
    function GetJoinTable: string;
    function GetJoinTableAlias: string;
    function GetJoinColumns: TStrings;

    function SetJoinTableAlias(const pJoinTableAlias: string): IAqDBSQLJoinParameters;

    procedure UpdateJoinTypeWithHighestPriority(const pJoinType: TAqDBSQLJoinType);

    function GetIdentifier: string;
  end;

  TAqDBSQLOrderByDescriptor = class(TAqDBSQLAbstraction, IAqDBSQLOrderByDescriptor)
  strict private
    FSourceIdentifier: string;
    FColumnName: string;
    FAscending: Boolean;
    FColumnShouldBeReturnedAsResult: Boolean;
    FGeneratedColumn: IAqDBSQLColumn;
  public
    constructor Create(const pSourceIdentifier, pColumnName: string;
      const pColumnShouldBeReturnedAsResult: Boolean; const pAscending: Boolean);

    function VerifyIfHasSourceIdentifier: Boolean;
    function GetSourceIdentifier: string;
    function GetColumnName: string;
    function GetIsAscending: Boolean;
    function GetColumnShouldBeReturnedAsResult: Boolean;
    function GetGeneratedColumn: IAqDBSQLColumn;
    procedure SetGeneratedColumn(pColumn: IAqDBSQLColumn);
  end;

  TAqDBSQLSelectSetup = class(TAqDBSQLAbstraction, IAqDBSQLSelectSetup)
  strict private
    FCustomCondition: IAqDBSQLComposedCondition;
    FJoinsParameters: IAqList<IAqDBSQLJoinParameters>;
    FConditionDescriptors: IAqDBSQLComposedConditionDescriptor;
    FOrderByList: IAqList<IAqDBSQLOrderByDescriptor>;
    FIsDistinguished: Boolean;

    function DoGetJoinsParameters: IAqList<IAqDBSQLJoinParameters>;
    function DoGetOrderbyList: IAqList<IAqDBSQLOrderByDescriptor>;
  public
    constructor Create(pInitialCondition: IAqDBSQLCondition); overload;

    function GetIsCustomConditionDefied: Boolean;
    function GetCustomCondition: IAqDBSQLComposedCondition;

    function GetHasJoinsParameters: Boolean;
    function GetJoinsParameters: IAqReadableList<IAqDBSQLJoinParameters>;

    function GetIsDistinguished: Boolean;
    function Distinct: IAqDBSQLSelectSetup;

    function AddJoinParameters(pJoinParameters: IAqDBSQLJoinParameters): Int32; overload;
    function AddJoinParameters(const pJoinTable, pMainTableColumns, pJoinTableColumns: string;
      const pJoinType: TAqDBSQLJoinType = TAqDBSQLJoinType.jtLeftJoin): IAqDBSQLJoinParameters; overload;
    function AddJoinParameters(const pJoinTable: string;
      const pMainTableColumns, pJoinTableColumns: array of string;
      const pJoinType: TAqDBSQLJoinType = TAqDBSQLJoinType.jtLeftJoin): IAqDBSQLJoinParameters; overload;
    function AddJoinParameters(const pJoinTable: string;
      const pMainTableColumns, pJoinTableColumns: TStrings;
      const pJoinType: TAqDBSQLJoinType = TAqDBSQLJoinType.jtLeftJoin): IAqDBSQLJoinParameters; overload;

    function GetHasConditionDescriptors: Boolean;
    function GetConditionDescriptors: IAqDBSQLComposedConditionDescriptor;

    function AddOrderBy(pOrderByDescriptor: IAqDBSQLOrderByDescriptor): Int32; overload;
    function AddOrderBy(const pColumnName: string;
      const pColumnShouldBeReturnedAsResult: Boolean; const pAscending: Boolean): IAqDBSQLOrderByDescriptor; overload;
    function AddOrderBy(const pIdentifier: string; pColumnName: string;
      const pColumnShouldBeReturnedAsResult: Boolean; const pAscending: Boolean): IAqDBSQLOrderByDescriptor; overload;
    function GetHasOrderBy: Boolean;
    function GetOrderByList: IAqReadableList<IAqDBSQLOrderByDescriptor>;

    procedure TakeSetup(pSetup: IAqDBSQLSelectSetup);
  end;

  TAqDBSQLSelect = class(TAqDBSQLSource, IAqDBSQLSource, IAqDBSQLSelect, IAqDBSQLCommand)
  strict private
    FColumns: IAqList<IAqDBSQLValue>;
    FSource: IAqDBSQLSource;
    FJoins: IAqList<IAqDBSQLJoin>;
    FLimit: UInt32;
    FOffset: UInt32;
    FCondition: IAqDBSQLCondition;
    FGroupBy: IAqList<IAqDBSQLValue>;
    FOrderBy: IAqList<IAqDBSQLOrderByItem>;
    FIsDistinguished: Boolean;

    procedure Reset;

    constructor InternalCreate(const pAlias: string);

    function GetColumns: IAqReadableList<IAqDBSQLValue>;
    function GetSource: IAqDBSQLSource;

    function GetHasJoins: Boolean;
    function DoGetJoins: IAqList<IAqDBSQLJoin>;
    function GetJoins: IAqReadableList<IAqDBSQLJoin>;

    function GetSourcesAliases: IAqDictionary<string, IAqDBSQLSource>;

    function GetIsConditionDefined: Boolean;
    function GetCondition: IAqDBSQLCondition;
    procedure SetCondition(pValue: IAqDBSQLCondition);
    function CustomizeCondition(pNewCondition: IAqDBSQLCondition = nil): IAqDBSQLComposedCondition;

    function GetIsLimitDefined: Boolean;
    function GetLimit: UInt32;
    procedure SetLimit(const pValue: UInt32);

    function GetIsOffsetDefined: Boolean;
    function GetOffset: UInt32;
    procedure SetOffset(const pValue: UInt32);

    function GetIsDistinguished: Boolean;
    function Distinct: IAqDBSQLSelect;

    function GetIsGroupByDefined: Boolean;
    function GetGroupBy: IAqReadableList<IAqDBSQLValue>;

    function GetIsOrderByDefined: Boolean;
    function GetOrderBy: IAqReadableList<IAqDBSQLOrderbyItem>;

    function GetAsDelete: IAqDBSQLDelete;
    function GetAsInsert: IAqDBSQLInsert;
    function GetAsUpdate: IAqDBSQLUpdate;
  strict protected
    function GetCommandType: TAqDBSQLCommandType;
    function GetSourceType: TAqDBSQLSourceType; override;
    function GetAsSelect: IAqDBSQLSelect; override;
  public
    constructor Create(const pSource: IAqDBSQLSource; const pAlias: string = ''); overload;
    constructor Create(const pSourceTable: string; const pAlias: string = ''); overload;

    function GetColumnByExpression(const pExpression: string): IAqDBSQLColumn;

    function AddColumn(pValue: IAqDBSQLValue): Int32; overload;
    function AddColumn(const pExpression: string): IAqDBSQLColumn; overload;
    function AddColumn(const pExpression: string; const pAlias: string): IAqDBSQLColumn; overload;
    function AddColumn(const pExpression, pAlias: string; pSource: IAqDBSQLSource): IAqDBSQLColumn; overload;
    function AddColumn(const pExpression, pAlias: string; pSource: IAqDBSQLSource;
      const pAggregator: TAqDBSQLAggregatorType): IAqDBSQLColumn; overload;
    function AddColumn(const pExpression: string; pSource: IAqDBSQLSource): IAqDBSQLColumn; overload;
    function AddColumn(const pExpression: string; pSource: IAqDBSQLSource;
      const pAggregator: TAqDBSQLAggregatorType): IAqDBSQLColumn; overload;
    function AddColumn(const pExpression: string; const pAggregator: TAqDBSQLAggregatorType): IAqDBSQLColumn; overload;

    function AddJoin(pJoin: IAqDBSQLJoin): Int32; overload;
    function AddJoin(const pType: TAqDBSQLJoinType; pSource: IAqDBSQLSource;
      pCondition: IAqDBSQLCondition): IAqDBSQLJoinWithComposedCondition; overload;

    function InnerJoin(const pTableName: string): IAqDBSQLJoinWithComposedCondition; Overload;
    function InnerJoin(const pTableName, pAlias: string): IAqDBSQLJoinWithComposedCondition; Overload;
    function LeftJoin(const pTableName: string): IAqDBSQLJoinWithComposedCondition; Overload;
    function LeftJoin(const pTableName, pAlias: string): IAqDBSQLJoinWithComposedCondition; Overload;

    procedure TakeSetup(pSetup: IAqDBSQLSelectSetup);

    function AddGroupBy(pValue: IAqDBSQLValue): Int32; overload;
    function AddGroupBy(pExpression: string): Int32; overload;
    function AddGroupBy(pExpression: string; pSource: IAqDBSQLSource): Int32; overload;

    function AddOrderBy(pValue: IAqDBSQLValue; const pAscending: Boolean = True): Int32; overload;
    function AddOrderBy(const pColumnName: string; const pAscending: Boolean = True): Int32; overload;

    procedure ClearLimit;
    procedure ClearOffset;

    procedure Encapsulate;
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
    FAssignments: IAqList<IAqDBSQLAssignment>;

    function GetAssignments: IAqReadableList<IAqDBSQLAssignment>;
    function GetTable: IAqDBSQLTable;
  strict protected
    function GetCommandType: TAqDBSQLCommandType; override;
    function GetAsInsert: IAqDBSQLInsert; override;
  public
    constructor Create(pTable: IAqDBSQLTable); overload;
    constructor Create(const pTableName: string); overload;

    function AddAssignment(pAssignment: IAqDBSQLAssignment): Int32; overload;
    function AddAssignment(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue): IAqDBSQLAssignment; overload;
  end;

  TAqDBSQLUpdate = class(TAqDBSQLCommand, IAqDBSQLUpdate)
  strict private
    FTable: IAqDBSQLTable;
    FAssignments: IAqList<IAqDBSQLAssignment>;
    FCondition: IAqDBSQLCondition;

    function GetAssignments: IAqReadableList<IAqDBSQLAssignment>;
    function GetTable: IAqDBSQLTable;
    function GetIsConditionDefined: Boolean;
    function GetCondition: IAqDBSQLCondition;
    procedure SetCondition(pValue: IAqDBSQLCondition);
    function CustomizeCondition(pNewCondition: IAqDBSQLCondition = nil): IAqDBSQLComposedCondition;
  strict protected
    function GetCommandType: TAqDBSQLCommandType; override;
    function GetAsUpdate: IAqDBSQLUpdate; override;
  public
    constructor Create(pTable: IAqDBSQLTable); overload;
    constructor Create(const pTableName: string); overload;

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
    function CustomizeCondition(pNewCondition: IAqDBSQLCondition = nil): IAqDBSQLComposedCondition;
  strict protected
    function GetCommandType: TAqDBSQLCommandType; override;
    function GetAsDelete: IAqDBSQLDelete; override;
  public
    constructor Create(pTable: IAqDBSQLTable); overload;
    constructor Create(const pTableName: string); overload;
  end;

implementation

uses
  System.SysUtils,
  System.TypInfo,
  AqDrop.Core.Helpers,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Collections,
  AqDrop.Core.Helpers.Rtti;

{ TAqDBSQLColumn }

function TAqDBSQLColumn.GetAsColumn: IAqDBSQLColumn;
begin
  Result := Self;
end;

function TAqDBSQLColumn.GetDefaultValue: string;
begin
  Result := FDefaultValue;
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

function TAqDBSQLColumn.SetDefaultValue(const pValor: String): IAqDBSQLColumn;
begin
  FDefaultValue := pValor;
  Result := Self;
end;

{ TAqDBSQLAliasable }

procedure TAqDBSQLAliasable.ClearAlias;
begin
  FAlias := string.Empty;
end;

constructor TAqDBSQLAliasable.Create(const pAlias: string);
begin
  SetAlias(pAlias);
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

function TAqDBSQLSelect.CustomizeCondition(pNewCondition: IAqDBSQLCondition = nil): IAqDBSQLComposedCondition;
begin
  if GetIsConditionDefined then
  begin
    Result := TAqDBSQLComposedCondition.Create(FCondition);
    if Assigned(pNewCondition) then
    begin
      Result.AddAnd(pNewCondition);
    end;
  end else begin
    Result := TAqDBSQLComposedCondition.Create(pNewCondition);
  end;

  FCondition := Result;
end;

function TAqDBSQLSelect.Distinct: IAqDBSQLSelect;
begin
  FIsDistinguished := True;
  Result := Self;
end;

function TAqDBSQLSelect.DoGetJoins: IAqList<IAqDBSQLJoin>;
begin
  if not Assigned(FJoins) then
  begin
    FJoins := TAqList<IAqDBSQLJoin>.Create;
  end;

  Result := FJoins;
end;

procedure TAqDBSQLSelect.Encapsulate;
var
  lInnerSelect: TAqDBSQLSelect;
begin
  lInnerSelect := TAqDBSQLSelect.Create;

  try
    lInnerSelect.SetAlias('encapsultadedsource');
    lInnerSelect.FColumns := FColumns;
    lInnerSelect.FSource := FSource;
    lInnerSelect.FJoins := FJoins;
    lInnerSelect.FLimit := FLimit;
    lInnerSelect.FOffset := FOffset;
    lInnerSelect.FCondition := FCondition;
    lInnerSelect.FOrderBy := FOrderBy;

    Reset;

    FSource := lInnerSelect;
  except
    lInnerSelect.Free;
    raise;
  end;
end;

function TAqDBSQLSelect.AddColumn(const pExpression: string; const pAlias: string; pSource: IAqDBSQLSource;
  const pAggregator: TAqDBSQLAggregatorType): IAqDBSQLColumn;
begin
  Result := TAqDBSQLColumn.Create(pExpression, pSource, pAlias, pAggregator);
  FColumns.Add(Result);
end;

function TAqDBSQLSelect.AddJoin(pJoin: IAqDBSQLJoin): Int32;
begin
  Result := DoGetJoins.Add(pJoin);
end;

function TAqDBSQLSelect.AddColumn(pValue: IAqDBSQLValue): Int32;
begin
  Result := FColumns.Add(pValue);
end;

function TAqDBSQLSelect.AddColumn(const pExpression, pAlias: string; pSource: IAqDBSQLSource): IAqDBSQLColumn;
begin
  Result := AddColumn(pExpression, pAlias, pSource, TAqDBSQLAggregatorType.atNone);
end;

function TAqDBSQLSelect.AddColumn(const pExpression, pAlias: string): IAqDBSQLColumn;
begin
  Result := AddColumn(pExpression, pAlias, nil, TAqDBSQLAggregatorType.atNone);
end;

function TAqDBSQLSelect.AddColumn(const pExpression: string): IAqDBSQLColumn;
begin
  Result := AddColumn(pExpression, '', nil, TAqDBSQLAggregatorType.atNone);
end;

function TAqDBSQLSelect.AddColumn(const pExpression: string; const pAggregator: TAqDBSQLAggregatorType): IAqDBSQLColumn;
begin
  Result := AddColumn(pExpression, '', nil, pAggregator);
end;

function TAqDBSQLSelect.AddGroupBy(pValue: IAqDBSQLValue): Int32;
begin
  if not Assigned(FGroupBy) then
  begin
    FGroupBy := TAqList<IAqDBSQLValue>.Create;
  end;

  Result := FGroupBy.Add(pValue);
end;

function TAqDBSQLSelect.AddGroupBy(pExpression: string): Int32;
begin
  Result := AddGroupBy(TAqDBSQLColumn.Create(pExpression, FSource));
end;

function TAqDBSQLSelect.AddGroupBy(pExpression: string;
  pSource: IAqDBSQLSource): Int32;
begin
  Result := AddGroupBy(TAqDBSQLColumn.Create(pExpression, pSource));
end;

function TAqDBSQLSelect.AddColumn(const pExpression: string; pSource: IAqDBSQLSource;
  const pAggregator: TAqDBSQLAggregatorType): IAqDBSQLColumn;
begin
  Result := AddColumn(pExpression, '', pSource, pAggregator);
end;

function TAqDBSQLSelect.AddColumn(const pExpression: string; pSource: IAqDBSQLSource): IAqDBSQLColumn;
begin
  Result := AddColumn(pExpression, '', pSource, TAqDBSQLAggregatorType.atNone);
end;

function TAqDBSQLSelect.AddJoin(const pType: TAqDBSQLJoinType; pSource: IAqDBSQLSource;
  pCondition: IAqDBSQLCondition): IAqDBSQLJoinWithComposedCondition;
begin
  Result := TAqDBSQLJoinWithComposedCondition.Create(pType, pSource, pCondition);

  AddJoin(Result);
end;

function TAqDBSQLSelect.AddOrderBy(const pColumnName: string; const pAscending: Boolean): Int32;
begin
  Result := AddOrderBy(TAqDBSQLColumn.Create(pColumnName, FSource), pAscending);
end;

function TAqDBSQLSelect.AddOrderBy(pValue: IAqDBSQLValue; const pAscending: Boolean): Int32;
begin
  if not Assigned(FOrderBy) then
  begin
    FOrderBy := TAqList<IAqDBSQLOrderByItem>.Create;
  end;

  Result := FOrderBy.Add(TAqDBSQLOrderByItem.Create(pValue, pAscending));
end;

function TAqDBSQLSelect.GetAsDelete: IAqDBSQLDelete;
begin
  raise EAqInternal.Create('Objects of ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBDelete.');
end;

function TAqDBSQLSelect.GetAsInsert: IAqDBSQLInsert;
begin
  raise EAqInternal.Create('Objects of ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBInsert.');
end;

function TAqDBSQLSelect.GetAsSelect: IAqDBSQLSelect;
begin
  Result := Self;
end;

function TAqDBSQLSelect.GetAsUpdate: IAqDBSQLUpdate;
begin
  raise EAqInternal.Create('Objects of ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBSQLUpdate.');
end;

function TAqDBSQLSelect.InnerJoin(const pTableName, pAlias: string): IAqDBSQLJoinWithComposedCondition;
begin
  Result := AddJoin(TAqDBSQLJoinType.jtInnerJoin, TAqDBSQLTable.Create(pTableName, pAlias), nil);
end;

function TAqDBSQLSelect.InnerJoin(const pTableName: string): IAqDBSQLJoinWithComposedCondition;
begin
  Result := Self.InnerJoin(pTableName, EmptyStr);
end;

constructor TAqDBSQLSelect.InternalCreate(const pAlias: string);
begin
  inherited Create(pAlias);

  Reset;
end;

function TAqDBSQLSelect.LeftJoin(const pTableName, pAlias: string): IAqDBSQLJoinWithComposedCondition;
begin
  Result := AddJoin(TAqDBSQLJoinType.jtLeftJoin, TAqDBSQLTable.Create(pTableName, pAlias), nil);
end;

function TAqDBSQLSelect.LeftJoin(const pTableName: string): IAqDBSQLJoinWithComposedCondition;
begin
  Result := Self.LeftJoin(pTableName, EmptyStr);
end;

procedure TAqDBSQLSelect.Reset;
begin
  FColumns := TAqList<IAqDBSQLValue>.Create;
  FLimit := High(FLimit);
  FOffset :=  0;
  FSource := nil;
  FJoins := nil;
  FCondition := nil;
  FOrderBy := nil;
  FIsDistinguished := False;
end;

procedure TAqDBSQLSelect.SetCondition(pValue: IAqDBSQLCondition);
begin
  FCondition := pValue;
end;

procedure TAqDBSQLSelect.SetLimit(const pValue: UInt32);
begin
  FLimit := pValue;
end;

procedure TAqDBSQLSelect.SetOffset(const pValue: UInt32);
begin
  FOffset := pValue;
end;

procedure TAqDBSQLSelect.TakeSetup(pSetup: IAqDBSQLSelectSetup);
var
  lJoinParameters: IAqDBSQLJoinParameters;
  lJoinsByIdentifier: IAqDictionary<string, IAqDBSQLJoin>;
  lI: Int32;
  lJoins: IAqReadableList<IAqDBSQLJoin>;
  lMainSource: IAqDBSQLSource;
  lMainSourceJoin: IAqDBSQLJoin;
  lJoinSource: IAqDBSQLTable;
  lKnownAliases: IAqDictionary<string, IAqDBSQLSource>;
  lAlias: string;
  lAttempts: Int32;
  lOnCondition: IAqDBSQLComposedCondition;
  lMainColumn: IAqDBSQLColumn;
  lJoinColumn: IAqDBSQLColumn;
  lJoin: IAqDBSQLJoin;
  lWhereCondition: IAqDBSQLComposedCondition;
  lOrderBy: IAqDBSQLOrderByDescriptor;
  lOrderBySource: IAqDBSQLSource;
  lOrderByColumn: IAqDBSQLColumn;
  lOrderByIndex: Int32;
  lExistingOrderByColumn: Boolean;

  function GetSourceByIdentifier(const pSourceIdentifier: string): IAqDBSQLSource;
  begin
    if pSourceIdentifier.IsEmpty then
    begin
      Result := FSource;
    end else if lJoinsByIdentifier.TryGetValue(pSourceIdentifier, lJoin) then
    begin
      Result := lJoin.Source;
    end else
    begin
      raise EAqInternal.CreateFmt('Join not found for identifier %s.', [pSourceIdentifier]);
    end;
  end;

  function GetLinkOperator(pComposedDescriptor: IAqDBSQLComposedConditionDescriptor;
    const pConditionIndex: Int32): TAqDBSQLBooleanOperator;
  begin
    if pConditionIndex <= 0 then
    begin
      Result := TAqDBSQLBooleanOperator.boAnd;
    end else begin
      Result := pComposedDescriptor.LinkOperators[pConditionIndex - 1];
    end;
  end;

  procedure AddConditionByDescriptor(pWhereCondition: IAqDBSQLComposedCondition;
    pDescriptor: IAqDBSQLConditionDescriptor;
    const pLinkOperator: TAqDBSQLBooleanOperator = TAqDBSQLBooleanOperator.boAnd);
  var
    lComparisonDescriptor: IAqDBSQLSimpleComparisonDescriptor;
    lLikeDescriptor: IAqDBSQLLikeDescriptor;
    lNewCondition: IAqDBSQLCondition;
    lNewComposedCondition: IAqDBSQLComposedCondition;
    lComposedDescriptor: IAqDBSQLComposedConditionDescriptor;
    lBetweenDescriptor: IAqDBSQLBetweenDescriptor;
    lInDescriptor: IAqDBSQLInDescriptor;
    lInCondition: IAqDBSQLInCondition;
    lInValue: IAqDBSQLConstant;
    lIsNullDescriptor: IAqDBSQLIsNullDescriptor;
    lIsNotNullDescriptor: IAqDBSQLIsNotNullDescriptor;
    lI: Int32;
  begin
    case pDescriptor.ConditionDescriptorType of
      cdComposed:
        begin
          lNewCondition := TAqDBSQLComposedCondition.Create;
          lNewComposedCondition := lNewCondition.GetAsComposed;
          lComposedDescriptor := pDescriptor.GetAsComposedConditionDescriptor;

          for lI := 0 to lComposedDescriptor.Count - 1 do
          begin
            AddConditionByDescriptor(lNewComposedCondition, lComposedDescriptor.Items[lI],
              GetLinkOperator(lComposedDescriptor, lI));
          end;
        end;
      cdComparison:
        begin
          lComparisonDescriptor := pDescriptor.GetAsSimpleComparisonDescriptor;
          lNewCondition := TAqDBSQLComparisonCondition.Create(
            TAqDBSQLColumn.Create(lComparisonDescriptor.ColumnName,
            GetSourceByIdentifier(lComparisonDescriptor.SourceIdentifier)),
            lComparisonDescriptor.Comparison,
            lComparisonDescriptor.ComparisonValue);
        end;
      cdBetween:
        begin
          lBetweenDescriptor := pDescriptor.GetAsBetweenDescriptor;
          lNewCondition := TAqDBSQLBetweenCondition.Create(
            TAqDBSQLColumn.Create(lBetweenDescriptor.ColumnName,
            GetSourceByIdentifier(lBetweenDescriptor.SourceIdentifier)),
            lBetweenDescriptor.LeftBoundaryValue,
            lBetweenDescriptor.RightBoundaryValue);
        end;
      cdLike:
        begin
          lLikeDescriptor := pDescriptor.GetAsLikeDescriptor;
          lNewCondition := TAqDBSQLLikeCondition.Create(
            TAqDBSQLColumn.Create(lLikeDescriptor.ColumnName, GetSourceByIdentifier(lLikeDescriptor.SourceIdentifier)),
            lLikeDescriptor.LikeValue);
        end;
      cdIn:
        begin
          lInDescriptor := pDescriptor.GetAsInDescriptor;
          lInCondition := TAqDBSQLInCondition.Create(
            TAqDBSQLColumn.Create(lInDescriptor.ColumnName, GetSourceByIdentifier(lInDescriptor.SourceIdentifier)));

          for lInValue in lInDescriptor.InValues do
          begin
            lInCondition.AddInValue(lInValue);
          end;

          lNewCondition := lInCondition;
        end;
      cdIsNull:
        begin
          lIsNullDescriptor := pDescriptor.GetAsIsNullDescriptor;
          lNewCondition := TAqDBSQLValueIsNullCondition.Create(
            TAqDBSQLColumn.Create(lIsNullDescriptor.ColumnName,
            GetSourceByIdentifier(lIsNullDescriptor.SourceIdentifier)));
        end;
      cdIsNotNull:
        begin
          {TODO 3 -oTatu -cVerificar: verificar se é melhor criar uma condição específca para 'is not null' e respectivo solver, ou o not na frente tem mesmo efeito e performance}
          lIsNotNullDescriptor := pDescriptor.GetAsIsNotNullDescriptor;
          lNewCondition := TAqDBSQLValueIsNullCondition.Create(
            TAqDBSQLColumn.Create(lIsNotNullDescriptor.ColumnName,
            GetSourceByIdentifier(lIsNotNullDescriptor.SourceIdentifier)));
          lNewCondition.Negate;
        end;
    end;

    if pDescriptor.IsNegated then
    begin
      lNewCondition.Negate;
    end;

    pWhereCondition.AddCondition(pLinkOperator, lNewCondition);
  end;
begin
  if Assigned(pSetup) then
  begin
    lWhereCondition := nil;

    if pSetup.IsDistinguished then
    begin
      Self.Distinct;
    end;

    if pSetup.IsCustomConditionDefied then
    begin
      CustomizeCondition(pSetup.CustomCondition);
    end;

    if pSetup.HasJoinsParameters then
    begin
      lJoinsByIdentifier := TAqDictionary<string, IAqDBSQLJoin>.Create;

      for lJoinParameters in pSetup.JoinsParameters do
      begin
        if not lJoinParameters.HasCustomCondition and((lJoinParameters.MainColumns.Count <= 0) or
          (lJoinParameters.MainColumns.Count <> lJoinParameters.JoinColumns.Count)) then
        begin
          raise EAqInternal.Create('Invalid number of columns in the join parameter.');
        end;

        lJoins := GetJoins;
        if lJoins.Find(
          function(pItem: IAqDBSQLJoin): Boolean
          begin
            Result := pItem.Identifier = lJoinParameters.Identifier;
          end, lI) then
        begin
          lJoinsByIdentifier.AddOrSetValue(lJoinParameters.Identifier, lJoins[lI]);
          lJoin := lJoins[lI];
          lJoin.UpdateJoinTypeWithHighestPriority(lJoinParameters.JoinType);
        end else 
        begin
          if not Assigned(lJoinParameters.MainSourceJoin) then                     
          begin
            lMainSource := FSource;
            lMainSourceJoin := nil;
          end else 
          begin
            if not lJoinsByIdentifier.TryGetValue(lJoinParameters.MainSourceJoin.Identifier, lMainSourceJoin) then
            begin
              raise EAqInternal.Create('Previous join not found.');
            end;

            lMainSource := lMainSourceJoin.Source;
          end;

          lKnownAliases := GetSourcesAliases;

          lAlias := lJoinParameters.JoinTableAlias;
          lAttempts := 1;
          while lKnownAliases.ContainsKey(lAlias) do
          begin
            Inc(lAttempts);
            lAlias := lJoinParameters.JoinTableAlias + lAttempts.ToString;
          end;

          lJoinSource := TAqDBSQLTable.Create(lJoinParameters.JoinTable, lAlias);
          lKnownAliases.Add(lAlias, lJoinSource);

          if lJoinParameters.HasCustomCondition then
          begin
            if Assigned(lMainSourceJoin) then
            begin
              lJoin := TAqDBSQLJoinWithCustomCondition.Create(lJoinParameters.JoinType, lMainSourceJoin, lJoinSource,
                lJoinParameters.CustomCondition);
            end else
            begin
              lJoin := TAqDBSQLJoinWithCustomCondition.Create(lJoinParameters.JoinType, lJoinSource, lMainSource,
                lJoinParameters.CustomCondition);
            end;
          end else
          begin
            lOnCondition := TAqDBSQLComposedCondition.Create;

            for lI := 0 to lJoinParameters.MainColumns.Count - 1 do
            begin
              lMainColumn := TAqDBSQLColumn.Create(lJoinParameters.MainColumns[lI], lMainSource);
              lJoinColumn := TAqDBSQLColumn.Create(lJoinParameters.JoinColumns[lI], lJoinSource);

              lOnCondition.AddColumnEqual(lMainColumn, lJoinColumn);
            end;

            if Assigned(lMainSourceJoin) then
            begin
              lJoin := TAqDBSQLJoinWithComposedCondition.Create(lJoinParameters.JoinType, lMainSourceJoin,
                lJoinSource, lOnCondition);
            end else
            begin
              lJoin := TAqDBSQLJoinWithComposedCondition.Create(lJoinParameters.JoinType, lJoinSource, lOnCondition);
            end;
          end;

          AddJoin(lJoin);

          lJoinsByIdentifier.AddOrSetValue(lJoinParameters.Identifier, lJoin);
        end;
      end;
    end;

    if pSetup.HasConditionDescriptors then
    begin
      AddConditionByDescriptor(Self.CustomizeCondition, pSetup.ConditionDescriptors);
    end;

    if pSetup.IsDistinguished then
    begin
      Self.Distinct;
    end;

    if pSetup.HasOrderBy then
    begin
      for lOrderBy in pSetup.OrderByList do
      begin
        lOrderBySource := GetSourceByIdentifier(lOrderBy.SourceIdentifier);

        lExistingOrderByColumn := Assigned(FOrderBy) and FOrderBy.Find(
          function(pItem: IAqDBSQLOrderByItem): Boolean
          begin
            Result := (pItem.Value.ValueType = TAqDBSQLValueType.vtColumn) and
              (pItem.Value.GetAsColumn.Expression = lOrderBy.ColumnName) and
              (pItem.Value.GetAsColumn.Source = lOrderBySource);
          end, lOrderByIndex);
        if lExistingOrderByColumn then
        begin
          lOrderByColumn := FOrderBy[lOrderByIndex].Value.GetAsColumn;
        end else begin
          lOrderByColumn := TAqDBSQLColumn.Create(lOrderBy.ColumnName, lOrderBySource);
          lOrderByIndex := AddOrderBy(lOrderByColumn, lOrderBy.Ascending);
        end;

        if lOrderBy.ColumnShouldBeReturnedAsResult then
        begin
          if FColumns.Find(
            function(pItem: IAqDBSQLValue): Boolean
            begin
              Result := (pItem = lOrderByColumn) or ((pItem.ValueType = TAqDBSQLValueType.vtColumn) and
                (pItem.GetAsColumn.Expression = lOrderByColumn.Expression) and
                (pItem.GetAsColumn.Source = lOrderByColumn.Source));
            end, lI) then
          begin
            lOrderByColumn := FColumns[lI].GetAsColumn;
            lExistingOrderByColumn := True;
          end else
          begin
            FColumns.Add(lOrderByColumn);
          end;

          if not lOrderByColumn.IsAliasDefined then
          begin
            if lExistingOrderByColumn or (lOrderByColumn.Source = FSource) then
            begin
              lOrderByColumn.SetAlias(lOrderByColumn.Expression);
            end else
            begin
              lOrderByColumn.SetAlias('__INJECTED_ORDER_BY_' + lOrderByIndex.ToString);
            end;
          end;
        end;

        lOrderBy.SetGeneratedColumn(lOrderByColumn);
      end;
    end;
  end;
end;

procedure TAqDBSQLSelect.ClearLimit;
begin
  FLimit := High(FLimit);
end;

procedure TAqDBSQLSelect.ClearOffset;
begin
  FOffset := 0;
end;

constructor TAqDBSQLSelect.Create(const pSource: IAqDBSQLSource; const pAlias: string);
begin
  InternalCreate(pAlias);
  FSource := pSource;
end;

function TAqDBSQLSelect.GetColumnByExpression(const pExpression: string): IAqDBSQLColumn;
var
  lI: Int32;
begin
  lI := 0;
  Result := nil;

  while not Assigned(Result) and (lI < FColumns.Count) do
  begin
    if (FColumns[lI].ValueType = TAqDBSQLValueType.vtColumn) and
      (FColumns[lI].GetAsColumn.Expression = pExpression) then
    begin
      Result := FColumns[lI].GetAsColumn;
    end else begin
      Inc(lI);
    end;
  end;
end;

function TAqDBSQLSelect.GetColumns: IAqReadableList<IAqDBSQLValue>;
begin
  Result := FColumns.GetReadOnlyList;
end;

function TAqDBSQLSelect.GetSource: IAqDBSQLSource;
begin
  Result := FSource;
end;

function TAqDBSQLSelect.GetSourcesAliases: IAqDictionary<string, IAqDBSQLSource>;
var
  lJoin: IAqDBSQLJoin;
begin
  Result := TAqDictionary<string, IAqDBSQLSource>.Create;

  if Assigned(FSource) then
  begin
    if not FSource.IsAliasDefined then
    begin
      if FSource.SourceType = TAqDBSQLSourceType.stTable then
      begin
        FSource.SetAlias(FSource.GetAsTable.Name);
      end else begin
        raise EAqInternal.CreateFmt('This source type (%s) should have an alias.',
          [GetEnumName(TypeInfo(TAqDBSQLSourceType), Integer(FSource.SourceType))]);
      end;
    end;

    Result.Add(FSource.Alias, FSource);
  end;

  if GetHasJoins then
  begin
    for lJoin in GetJoins do
    begin
      if lJoin.Source.IsAliasDefined then
      begin
        Result.Add(lJoin.Source.Alias, lJoin.Source);
      end;
    end;
  end;
end;

function TAqDBSQLSelect.GetCommandType: TAqDBSQLCommandType;
begin
  Result := TAqDBSQLCommandType.ctSelect;
end;

function TAqDBSQLSelect.GetCondition: IAqDBSQLCondition;
begin
  Result := FCondition;
end;

function TAqDBSQLSelect.GetGroupBy: IAqReadableList<IAqDBSQLValue>;
begin
  Result := FGroupBy.GetReadOnlyList;
end;

function TAqDBSQLSelect.GetHasJoins: Boolean;
begin
  Result := Assigned(FJoins) and (FJoins.Count > 0);
end;

function TAqDBSQLSelect.GetIsConditionDefined: Boolean;
begin
  Result := Assigned(FCondition);
end;

function TAqDBSQLSelect.GetIsDistinguished: Boolean;
begin
  Result := FIsDistinguished;
end;

function TAqDBSQLSelect.GetIsGroupByDefined: Boolean;
begin
  Result := Assigned(FGroupBy) and (FGroupBy.Count > 0);
end;

function TAqDBSQLSelect.GetIsLimitDefined: Boolean;
begin
  Result := FLimit <> High(FLimit);
end;

function TAqDBSQLSelect.GetIsOffsetDefined: Boolean;
begin
  Result := FOffset > 0;
end;

function TAqDBSQLSelect.GetIsOrderByDefined: Boolean;
begin
  Result := Assigned(FOrderBy) and (FOrderBy.Count > 0);
end;

function TAqDBSQLSelect.GetJoins: IAqReadableList<IAqDBSQLJoin>;
begin
  Result := DoGetJoins.GetReadOnlyList;
end;

function TAqDBSQLSelect.GetLimit: UInt32;
begin
  Result := FLimit;
end;

function TAqDBSQLSelect.GetOffset: UInt32;
begin
  Result := FOffset;
end;

function TAqDBSQLSelect.GetOrderBy: IAqReadableList<IAqDBSQLOrderByItem>;
begin
  Result := FOrderBy.GetReadOnlyList;
end;

function TAqDBSQLSelect.GetSourceType: TAqDBSQLSourceType;
begin
  Result := TAqDBSQLSourceType.stSelect;
end;

{ TAqDBSQLSource }

function TAqDBSQLSource.GetAsSelect: IAqDBSQLSelect;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBSQLSelect.');
end;

function TAqDBSQLSource.GetAsTable: IAqDBSQLTable;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBTable.');
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
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBColumn.');
end;

function TAqDBSQLValue.GetAsConstant: IAqDBSQLConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBSQLConstant.');
end;

function TAqDBSQLValue.GetAsOperation: IAqDBSQLOperation;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBOperationValue.');
end;

function TAqDBSQLValue.GetAsParameter: IAqDBSQLParameter;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBSQLParameter.');
end;

function TAqDBSQLValue.GetAsSubselect: IAqDBSQLSubselect;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBSQLSubselect.');
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
  Result := not FAlias.IsEmpty;
end;

procedure TAqDBSQLAliasable.SetAlias(const pAlias: string);
begin
  FAlias := pAlias;
end;

class function TAqDBSQLValue.FromValue(const pValue: TValue; const pType: TAqDataType): TAqDBSQLValue;
begin
  {TODO 3 -oTatu -cDesejável: criar overloads no drop para aceitar fluent sintax com tvalue como parâmetro}
  case pType of
    TAqDataType.adtUInt8..TAqDataType.adtInt64:
      Result := TAqDBSQLIntConstant.Create(pValue.AsInt64);
    TAqDataType.adtString:
      Result := TAqDBSQLTextConstant.Create(pValue.AsString);
    TAqDataType.adtDate:
      Result := TAqDBSQLDateConstant.Create(pValue.AsType<TDate>);
    TAqDataType.adtCurrency:
      Result := TAqDBSQLCurrencyConstant.Create(pValue.AsCurrency);
  else
    raise EAqInternal.CreateFmt('Unexpected type when converting TValue to IAqDBSQLValue (%d).',
      [Int32(pType)]);
  end;
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

procedure TAqDBSQLComparisonCondition.SetComparison(const pComparison: TAqDBSQLComparison);
begin
  FComparison := pComparison;
end;

procedure TAqDBSQLComparisonCondition.SetLeftValue(pValue: IAqDBSQLValue);
begin
  FLeftValue := pValue;
end;

procedure TAqDBSQLComparisonCondition.SetRightValue(pValue: IAqDBSQLValue);
begin
  FRightValue := pValue;
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

{ TAqDBSQLJoin }

procedure TAqDBSQLJoin.UpdateJoinTypeWithHighestPriority(const pJoinType: TAqDBSQLJoinType);
begin
  if pJoinType < FType then
  begin
    FType := pJoinType;
  end;
end;

constructor TAqDBSQLJoin.Create(const pType: TAqDBSQLJoinType; pPreviousJoin: IAqDBSQLJoin;
  pJoinSource: IAqDBSQLSource);
begin
  Create(pType, pJoinSource);

  FPreviousJoin := pPreviousJoin;
end;

constructor TAqDBSQLJoin.Create(const pType: TAqDBSQLJoinType; pJoinSource, pMainSource: IAqDBSQLSource);
begin
  inherited Create;

  FType := pType;
  FJoinSource := pJoinSource;
  FMainSource := pMainSource;
end;

function TAqDBSQLJoin.GetAsJoinWithComposedCondition: IAqDBSQLJoinWithComposedCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as ' +
    TAqRtti.&Implementation.GetType(TypeInfo(IAqDBSQLJoinWithComposedCondition)).QualifiedName + '.');
end;

function TAqDBSQLJoin.GetAsJoinWithCustomCondition: IAqDBSQLJoinWithCustomCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as ' +
    TAqRtti.&Implementation.GetType(TypeInfo(IAqDBSQLJoinWithCustomCondition)).QualifiedName + '.');
end;

function TAqDBSQLJoin.GetHasPreviousJoin: Boolean;
begin
  Result := Assigned(FPreviousJoin);
end;

function TAqDBSQLJoin.GetIdentifier: string;
begin
  if Assigned(FPreviousJoin) then
  begin
    Result := FPreviousJoin.Identifier + '|';
  end else
  begin
    Result := '';
  end;

  if FJoinSource.SourceType = stTable then
  begin
    Result := Result + FJoinSource.GetAsTable.Name.ToUpper;
  end else
  begin
    RaiseNotPossibleToMountIdentifier;
  end;
end;

function TAqDBSQLJoin.GetJoinType: TAqDBSQLJoinType;
begin
  Result := FType;
end;

function TAqDBSQLJoin.GetMainSource: IAqDBSQLSource;
begin
  if GetHasPreviousJoin then
  begin
    Result := FPreviousJoin.Source;
  end else begin
    Result := FMainSource;
  end;
end;

function TAqDBSQLJoin.GetPreviousJoin: IAqDBSQLJoin;
begin
  Result := FPreviousJoin;
end;

function TAqDBSQLJoin.GetSource: IAqDBSQLSource;
begin
  Result := FJoinSource;
end;

procedure TAqDBSQLJoin.RaiseNotPossibleToMountIdentifier;
begin
  raise EAqInternal.Create('It wasn''t possible to mount the join identifier.');
end;

{ TAqDBSQLComposedCondition }

function TAqDBSQLComposedCondition.AddAnd(pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
begin
  AddCondition(TAqDBSQLBooleanOperator.boAnd, pCondition);
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnBetween(pColumn: IAqDBSQLColumn;
  const pLeftBoundary, pRightBoundary: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLBetweenCondition.Create(pColumn,
    TAqDBSQLDateTimeConstant.Create(pLeftBoundary), TAqDBSQLDateTimeConstant.Create(pRightBoundary)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnBetween(const pColumnName: string;
  const pLeftBoundary, pRightBoundary: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnBetween(TAqDBSQLColumn.Create(pColumnName), pLeftBoundary, pRightBoundary, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnBetween(pColumn: IAqDBSQLColumn;
  const pLeftBoundary, pRightBoundary: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLBetweenCondition.Create(pColumn,
    TAqDBSQLCurrencyConstant.Create(pLeftBoundary), TAqDBSQLCurrencyConstant.Create(pRightBoundary)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnBetween(const pColumnName: string;
  const pLeftBoundary, pRightBoundary: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnBetween(TAqDBSQLColumn.Create(pColumnName), pLeftBoundary, pRightBoundary, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLBetweenCondition.Create(pColumn,
    TAqDBSQLTimeConstant.Create(pLeftBoundary), TAqDBSQLTimeConstant.Create(pRightBoundary)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnBetween(const pColumnName: string;
  const pLeftBoundary, pRightBoundary: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnBetween(TAqDBSQLColumn.Create(pColumnName), pLeftBoundary, pRightBoundary, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLBetweenCondition.Create(pColumn,
    TAqDBSQLDateConstant.Create(pLeftBoundary), TAqDBSQLDateConstant.Create(pRightBoundary)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnBetween(const pColumnName: string;
  const pLeftBoundary, pRightBoundary: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnBetween(TAqDBSQLColumn.Create(pColumnName), pLeftBoundary, pRightBoundary, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnBetween(pColumn: IAqDBSQLColumn;
  const pLeftBoundary, pRightBoundary: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLBetweenCondition.Create(pColumn,
    TAqDBSQLTextConstant.Create(pLeftBoundary), TAqDBSQLTextConstant.Create(pRightBoundary)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnBetween(const pColumnName, pLeftBoundary, pRightBoundary: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnBetween(TAqDBSQLColumn.Create(pColumnName), pLeftBoundary, pRightBoundary, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnBetween(pColumn: IAqDBSQLColumn;
  const pLeftBoundary, pRightBoundary: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLBetweenCondition.Create(pColumn, pLeftBoundary, pRightBoundary));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnBetween(const pColumnName: string;
  const pLeftBoundary, pRightBoundary: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnBetween(TAqDBSQLColumn.Create(pColumnName), pLeftBoundary, pRightBoundary, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnBetween(pColumn: IAqDBSQLColumn;
  const pLeftBoundary, pRightBoundary: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLBetweenCondition.Create(pColumn,
    TAqDBSQLDoubleConstant.Create(pLeftBoundary), TAqDBSQLDoubleConstant.Create(pRightBoundary)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnBetween(const pColumnName: string;
  const pLeftBoundary, pRightBoundary: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnBetween(TAqDBSQLColumn.Create(pColumnName), pLeftBoundary, pRightBoundary, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnBetween(pColumn: IAqDBSQLColumn; const pLeftBoundary, pRightBoundary: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLBetweenCondition.Create(pColumn,
    TAqDBSQLIntConstant.Create(pLeftBoundary), TAqDBSQLIntConstant.Create(pRightBoundary)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnBetween(const pColumnName: string;
  const pLeftBoundary, pRightBoundary: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnBetween(TAqDBSQLColumn.Create(pColumnName), pLeftBoundary, pRightBoundary, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual,
    TAqDBSQLDateConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual,
    TAqDBSQLDateTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: Boolean;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual,
    TAqDBSQLBooleanConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: Boolean;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: UInt64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual,
    TAqDBSQLUIntConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: UInt64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual,
    TAqDBSQLTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual,
    TAqDBSQLTextConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual, pValue));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual,
    TAqDBSQLIntConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual,
    TAqDBSQLCurrencyConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual,
    TAqDBSQLDoubleConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterEqual,
    TAqDBSQLDateTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(const pColumnName: string; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterEqual,
    TAqDBSQLCurrencyConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(const pColumnName: string; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterEqual,
    TAqDBSQLTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(const pColumnName: string; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterEqual,
    TAqDBSQLDateConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(const pColumnName: string; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterEqual,
    TAqDBSQLTextConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(const pColumnName: string; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterEqual, pValue));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(const pColumnName: string; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterEqual,
    TAqDBSQLDoubleConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(const pColumnName: string; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(pColumn: IAqDBSQLColumn; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterEqual,
    TAqDBSQLIntConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterEqualThan(const pColumnName: string; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterThan,
    TAqDBSQLDoubleConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(const pColumnName: string; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterThan,
    TAqDBSQLCurrencyConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(const pColumnName: string; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterThan,
    TAqDBSQLIntConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterThan, pValue));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(const pColumnName: string; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(const pColumnName: string; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterThan,
    TAqDBSQLTextConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(const pColumnName: string; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterThan,
    TAqDBSQLTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(const pColumnName: string; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterThan,
    TAqDBSQLDateConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(const pColumnName: string; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(pColumn: IAqDBSQLColumn; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpGreaterThan,
    TAqDBSQLDateTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnGreaterThan(const pColumnName: string; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnGreaterThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnIsNull(const pColumnName: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnIsNull(TAqDBSQLColumn.Create(pColumnName), pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnIsNull(pColumn: IAqDBSQLColumn;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLValueIsNullCondition.Create(pColumn));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(const pColumnName: string; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessEqual,
    TAqDBSQLIntConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(const pColumnName: string; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessEqual,
    TAqDBSQLDoubleConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(const pColumnName: string; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessEqual, pValue));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(const pColumnName: string; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessEqual,
    TAqDBSQLTextConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(const pColumnName: string; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessEqual,
    TAqDBSQLDateConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(const pColumnName: string; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  {TODO 3 -oTatu -cMelhoria: trocar todas as implementações de comparações específicas por um addcomparison e devidos parâmetros, como abaixo.}
  Result := AddComparison(pColumnName, TAqDBSQLComparison.cpLessEqual, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessEqual,
    TAqDBSQLTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(const pColumnName: string; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessEqual,
    TAqDBSQLCurrencyConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(const pColumnName: string; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessEqualThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessEqualThan(pColumn: IAqDBSQLColumn; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessEqual,
    TAqDBSQLDateTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessThan,
    TAqDBSQLDateTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(const pColumnName: string; pValue: TDateTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessThan,
    TAqDBSQLCurrencyConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(const pColumnName: string; pValue: Currency;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessThan,
    TAqDBSQLTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(const pColumnName: string; pValue: TTime;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLike(pColumn: IAqDBSQLColumn; const pValue: string;
  const pLeftWildCard: TAqDBSQLLikeWildCard; const pRightWildCard: TAqDBSQLLikeWildCard;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLike(pColumn, TAqDBSQLTextConstant.Create(pValue), pLeftWildCard, pRightWildCard, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLike(const pColumnName: string; pValue: IAqDBSQLTextConstant;
  const pLeftWildCard: TAqDBSQLLikeWildCard; const pRightWildCard: TAqDBSQLLikeWildCard;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLike(TAqDBSQLColumn.Create(pColumnName), pValue, pLeftWildCard, pRightWildCard, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLike(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLTextConstant;
  const pLeftWildCard: TAqDBSQLLikeWildCard; const pRightWildCard: TAqDBSQLLikeWildCard;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLLikeCondition.Create(pColumn, pValue, pLeftWildCard, pRightWildCard));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLike(const pColumnName, pValue: string;
  const pLeftWildCard: TAqDBSQLLikeWildCard; const pRightWildCard: TAqDBSQLLikeWildCard;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLike(TAqDBSQLColumn.Create(pColumnName), TAqDBSQLTextConstant.Create(pValue),
    pLeftWildCard, pRightWildCard, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessThan,
    TAqDBSQLDateConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(const pColumnName: string; pValue: TDate;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessThan,
    TAqDBSQLTextConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(const pColumnName: string; pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessThan, pValue));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(const pColumnName: string; pValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessThan,
    TAqDBSQLDoubleConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(const pColumnName: string; pValue: Double;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(pColumn: IAqDBSQLColumn; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpLessThan,
    TAqDBSQLIntConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddColumnLessThan(const pColumnName: string; pValue: Int64;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLessThan(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddCondition(const pLinkOperator: TAqDBSQLBooleanOperator;
  pCondition: IAqDBSQLCondition): Int32;
begin
  if GetIsInitialized then
  begin
    FOperators.Add(pLinkOperator);
  end;

  Result := FConditions.Add(pCondition);
end;

function TAqDBSQLComposedCondition.AddOr(pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
begin
  AddCondition(TAqDBSQLBooleanOperator.boOr, pCondition);
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddXor(pCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
begin
  AddCondition(TAqDBSQLBooleanOperator.boXor, pCondition);
  Result := Self;
end;

constructor TAqDBSQLComposedCondition.Create(pInitialCondition: IAqDBSQLCondition);
begin
  FConditions := TAqList<IAqDBSQLCondition>.Create;
  FOperators := TAqList<TAqDBSQLBooleanOperator>.Create;

  if Assigned(pInitialCondition) then
  begin
    FConditions.Add(pInitialCondition);
  end;
end;

function TAqDBSQLComposedCondition.GetAsComposed: IAqDBSQLComposedCondition;
begin
  Result := Self;
end;

function TAqDBSQLComposedCondition.GetConditions: IAqReadableList<AqDrop.DB.SQL.Intf.IAqDBSQLCondition>;
begin
  Result := FConditions.GetReadOnlyList;
end;

function TAqDBSQLComposedCondition.GetConditionType: TAqDBSQLConditionType;
begin
  Result := TAqDBSQLConditionType.ctComposed;
end;

function TAqDBSQLComposedCondition.GetIsInitialized: Boolean;
begin
  Result := FConditions.Count > 0;
end;

function TAqDBSQLComposedCondition.GetLinkOperators: IAqReadableList<AqDrop.DB.SQL.Intf.TAqDBSQLBooleanOperator>;
begin
  Result := FOperators.GetReadOnlyList;
end;

function TAqDBSQLComposedCondition.AddColumnLike(pColumn: IAqDBSQLColumn; const pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLike(pColumn, TAqDBSQLTextConstant.Create(pValue),
    TAqDBSQLLikeWildCard.lwcMultipleChars,
    TAqDBSQLLikeWildCard.lwcMultipleChars,
    pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLike(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLTextConstant;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLike(pColumn, pValue,
    TAqDBSQLLikeWildCard.lwcMultipleChars,
    TAqDBSQLLikeWildCard.lwcMultipleChars,
    pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLike(const pColumnName, pValue: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLike(TAqDBSQLColumn.Create(pColumnName),
    TAqDBSQLTextConstant.Create(pValue),
    TAqDBSQLLikeWildCard.lwcMultipleChars,
    TAqDBSQLLikeWildCard.lwcMultipleChars,
    pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: UInt64; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, pComparison, TAqDBSQLUIntConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: Int64; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: UInt64; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: Double; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: Double; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, pComparison, TAqDBSQLDoubleConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: IAqDBSQLValue; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: IAqDBSQLValue; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLComparisonCondition.Create(pColumn, pComparison, pValue));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: string; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, pComparison, TAqDBSQLTextConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: Int64; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, pComparison, TAqDBSQLIntConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: string; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: TTime; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, pComparison, TAqDBSQLTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: TDate; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: TTime; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: Boolean; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: Boolean; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, pComparison, TAqDBSQLBooleanConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: Currency; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: Currency; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, pComparison, TAqDBSQLCurrencyConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: TDateTime; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, pComparison, TAqDBSQLDateTimeConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(pColumn: IAqDBSQLColumn; const pComparison: TAqDBSQLComparison;
  pValue: TDate; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator,
    TAqDBSQLComparisonCondition.Create(pColumn, pComparison, TAqDBSQLDateConstant.Create(pValue)));
  Result := Self;
end;

function TAqDBSQLComposedCondition.AddComparison(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pValue: TDateTime; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddComparison(TAqDBSQLColumn.Create(pColumnName), pComparison, pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnLike(const pColumnName: string; pValue: IAqDBSQLTextConstant;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnLike(TAqDBSQLColumn.Create(pColumnName), pValue,
    TAqDBSQLLikeWildCard.lwcMultipleChars,
    TAqDBSQLLikeWildCard.lwcMultipleChars,
    pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(const pColumnName: string; pValue: TGUID;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  Result := AddColumnEqual(TAqDBSQLColumn.Create(pColumnName), pValue, pLinkOperator);
end;

function TAqDBSQLComposedCondition.AddColumnEqual(pColumn: IAqDBSQLColumn; pValue: TGUID;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedCondition;
begin
  AddCondition(pLinkOperator, TAqDBSQLComparisonCondition.Create(pColumn, TAqDBSQLComparison.cpEqual, TAqDBSQLGUIDConstant.Create(pValue)));
  Result := Self;
end;

{ TAqDBSQLCondition }

function TAqDBSQLCondition.GetAsBetween: IAqDBSQLBetweenCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLBetweenCondition.');
end;

function TAqDBSQLCondition.GetAsComparison: IAqDBSQLComparisonCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLComparisonCondition.');
end;

function TAqDBSQLCondition.GetAsComposed: IAqDBSQLComposedCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLComposedCondition.');
end;

function TAqDBSQLCondition.GetAsExists: IAqDBSQLExistsCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLExistsCondition.');
end;

function TAqDBSQLCondition.GetAsIn: IAqDBSQLInCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLInCondition.');
end;

function TAqDBSQLCondition.GetAsLike: IAqDBSQLLikeCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLLikeCondition.');
end;

function TAqDBSQLCondition.GetAsValueIsNull: IAqDBSQLValueIsNullCondition;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLValueIsNullCondition.');
end;

function TAqDBSQLCondition.Negate: IAqDBSQLCondition;
begin
  FNegated := not FNegated;
  Result := Self;
end;

function TAqDBSQLCondition.VerifyIfIsNegated: Boolean;
begin
  Result := FNegated;
end;

{ TAqDBSQLCommand }

function TAqDBSQLCommand.GetAsDelete: IAqDBSQLDelete;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBSQLDelete.');
end;

function TAqDBSQLCommand.GetAsInsert: IAqDBSQLInsert;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBSQLInsert.');
end;

function TAqDBSQLCommand.GetAsSelect: IAqDBSQLSelect;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBSQLSelect.');
end;

function TAqDBSQLCommand.GetAsUpdate: IAqDBSQLUpdate;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName + ' cannot be consumed as IAqDBSQLUpdate.');
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

function TAqDBSQLInsert.GetAsInsert: IAqDBSQLInsert;
begin
  Result := Self;
end;

function TAqDBSQLInsert.GetAssignments: IAqReadableList<IAqDBSQLAssignment>;
begin
  Result := FAssignments.GetReadOnlyList;
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

constructor TAqDBSQLBetweenCondition.Create(pValue, pLeftBoundary, pRightBoundary: IAqDBSQLValue);
begin
  FValue := pValue;
  FLeftBoundary := pLeftBoundary;
  FRightBoundary := pRightBoundary;
end;

function TAqDBSQLBetweenCondition.GetAsBetween: IAqDBSQLBetweenCondition;
begin
  Result := Self;
end;

function TAqDBSQLBetweenCondition.GetConditionType: TAqDBSQLConditionType;
begin
  Result := TAqDBSQLConditionType.ctBetween;
end;

function TAqDBSQLBetweenCondition.GetRightBoundary: IAqDBSQLValue;
begin
  Result := FRightBoundary;
end;

function TAqDBSQLBetweenCondition.GetLeftBoundary: IAqDBSQLValue;
begin
  Result := FLeftBoundary;
end;

function TAqDBSQLBetweenCondition.GetValue: IAqDBSQLValue;
begin
  Result := FValue;
end;

{ TAqDBSQLConstant }

function TAqDBSQLConstant.GetAsBooleanConstant: IAqDBSQLBooleanConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLBooleanConstant.');
end;

function TAqDBSQLConstant.GetAsConstant: IAqDBSQLConstant;
begin
  Result := Self;
end;

function TAqDBSQLConstant.GetAsCurrencyConstant: IAqDBSQLCurrencyConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLCurrencyConstant.');
end;

function TAqDBSQLConstant.GetAsDateConstant: IAqDBSQLDateConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLDateConstant.');
end;

function TAqDBSQLConstant.GetAsDateTimeConstant: IAqDBSQLDateTimeConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLDateTimeConstant.');
end;

function TAqDBSQLConstant.GetAsDoubleConstant: IAqDBSQLDoubleConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLDoubleConstant.');
end;

function TAqDBSQLConstant.GetAsGUIDConstant: IAqDBSQLGUIDConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLGUIDConstant.');
end;

function TAqDBSQLConstant.GetAsIntConstant: IAqDBSQLIntConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName
    + ' cannot be consumed as IAqDBSQLIntConstant.');
end;

function TAqDBSQLConstant.GetAsTextConstant: IAqDBSQLTextConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLTextConstant.');
end;

function TAqDBSQLConstant.GetAsTimeConstant: IAqDBSQLTimeConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName +
    ' cannot be consumed as IAqDBSQLTimeConstant.');
end;

function TAqDBSQLConstant.GetAsUIntConstant: IAqDBSQLUIntConstant;
begin
  raise EAqInternal.Create('Objects of type ' + Self.QualifiedClassName
    + ' cannot be consumed as IAqDBSQLUIntConstant.');
end;

function TAqDBSQLConstant.GetValueType: TAqDBSQLValueType;
begin
  Result := TAqDBSQLValueType.vtConstant;
end;

{ TAqDBSQLTextConstant }

function TAqDBSQLTextConstant.GetAsTextConstant: IAqDBSQLTextConstant;
begin
  Result := Self;
end;

function TAqDBSQLTextConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvText;
end;

{ TAqDBSQLDateTimeConstant }

function TAqDBSQLDateTimeConstant.GetAsDateTimeConstant: IAqDBSQLDateTimeConstant;
begin
  Result := Self;
end;

function TAqDBSQLDateTimeConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvDateTime;
end;

{ TAqDBSQLBooleanConstant }

function TAqDBSQLBooleanConstant.GetAsBooleanConstant: IAqDBSQLBooleanConstant;
begin
  Result := Self;
end;

function TAqDBSQLBooleanConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvBoolean;
end;

{ TAqDBSQLDateConstant }

function TAqDBSQLDateConstant.GetAsDateConstant: IAqDBSQLDateConstant;
begin
  Result := Self;
end;

function TAqDBSQLDateConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvDate;
end;

{ TAqDBSQLTimeConstant }

function TAqDBSQLTimeConstant.GetAsTimeConstant: IAqDBSQLTimeConstant;
begin
  Result := Self;
end;

function TAqDBSQLTimeConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvTime;
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

function TAqDBSQLUpdate.CustomizeCondition(pNewCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
begin
  if GetIsConditionDefined then
  begin
    Result := TAqDBSQLComposedCondition.Create(FCondition);
    if Assigned(pNewCondition) then
    begin
      Result.AddAnd(pNewCondition);
    end;
  end else begin
    Result := TAqDBSQLComposedCondition.Create(pNewCondition);
  end;

  FCondition := Result;
end;

constructor TAqDBSQLUpdate.Create(pTable: IAqDBSQLTable);
begin
  FTable := pTable;
  FAssignments := TAqList<IAqDBSQLAssignment>.Create;
end;

function TAqDBSQLUpdate.GetAssignments: IAqReadableList<IAqDBSQLAssignment>;
begin
  Result := FAssignments.GetReadOnlyList;
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

function TAqDBSQLDelete.CustomizeCondition(pNewCondition: IAqDBSQLCondition): IAqDBSQLComposedCondition;
begin
  if GetIsConditionDefined then
  begin
    Result := TAqDBSQLComposedCondition.Create(FCondition);
    if Assigned(pNewCondition) then
    begin
      Result.AddAnd(pNewCondition);
    end;
  end else begin
    Result := TAqDBSQLComposedCondition.Create(pNewCondition);
  end;

  FCondition := Result;
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

{ TAqDBSQLGenericConstant<T> }

constructor TAqDBSQLGenericConstant<T>.Create(const pValue: T; const pAlias: string;
  const pAggregator: TAqDBSQLAggregatorType);
begin
  inherited Create(pAlias, pAggregator);

  FValue := pValue;
end;

function TAqDBSQLGenericConstant<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure TAqDBSQLGenericConstant<T>.SetValue(const pValue: T);
begin
  FValue := pValue;
end;

{ TAqDBSQLIntConstant }

function TAqDBSQLIntConstant.GetAsIntConstant: IAqDBSQLIntConstant;
begin
  Result := Self;
end;

function TAqDBSQLIntConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvInt;
end;

{ TAqDBSQLDoubleConstant }

function TAqDBSQLDoubleConstant.GetAsDoubleConstant: IAqDBSQLDoubleConstant;
begin
  Result := Self;
end;

function TAqDBSQLDoubleConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvDouble;
end;

{ TAqDBSQLCurrencyConstant }

function TAqDBSQLCurrencyConstant.GetAsCurrencyConstant: IAqDBSQLCurrencyConstant;
begin
  Result := Self;
end;

function TAqDBSQLCurrencyConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvCurrency;
end;

{ TAqDBSQLUIntConstant }

function TAqDBSQLUIntConstant.GetAsUIntConstant: IAqDBSQLUIntConstant;
begin
  Result := Self;
end;

function TAqDBSQLUIntConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvUInt;
end;

{ TAqDBSQLOderByItem }

constructor TAqDBSQLOrderByItem.Create(pValue: IAqDBSQLValue; const pAscending: Boolean);
begin
  FValue := pValue;
  FAscending := pAscending;
end;

function TAqDBSQLOrderByItem.GetIsAscending: Boolean;
begin
  Result := FAscending;
end;

function TAqDBSQLOrderByItem.GetValue: IAqDBSQLValue;
begin
  Result := FValue;
end;

{ TAqDBSQLLikeCondition }

constructor TAqDBSQLLikeCondition.Create(pLeftValue: IAqDBSQLValue; pRightValue: IAqDBSQLTextConstant;
  const pLeftWildCard: TAqDBSQLLikeWildCard; const pRightWildCard: TAqDBSQLLikeWildCard);
begin
  FLeftValue := pLeftValue;
  FRightValue := pRightValue;
  FLeftWildCard := pLeftWildCard;
  FRightWildCard := pRightWildCard;
end;

constructor TAqDBSQLLikeCondition.Create(pLeftValue, pRightValue: string; const pLeftWildCard,
  pRightWildCard: TAqDBSQLLikeWildCard);
begin
  Create(TAqDBSQLColumn.Create(pLeftValue), TAqDBSQLTextConstant.Create(pRightValue), pLeftWildCard, pRightWildCard);
end;

function TAqDBSQLLikeCondition.GetAsLike: IAqDBSQLLikeCondition;
begin
  Result := Self;
end;

function TAqDBSQLLikeCondition.GetConditionType: TAqDBSQLConditionType;
begin
  Result := TAqDBSQLConditionType.ctLike;
end;

function TAqDBSQLLikeCondition.GetLeftValue: IAqDBSQLValue;
begin
  Result := FLeftValue;
end;

function TAqDBSQLLikeCondition.GetLeftWildCard: TAqDBSQLLikeWildCard;
begin
  Result := FLeftWildCard;
end;

function TAqDBSQLLikeCondition.GetRightValue: IAqDBSQLTextConstant;
begin
  Result := FRightValue;
end;

function TAqDBSQLLikeCondition.GetRightWildCard: TAqDBSQLLikeWildCard;
begin
  Result := FRightWildCard;
end;

procedure TAqDBSQLLikeCondition.SetLeftValue(pValue: IAqDBSQLValue);
begin
  FLeftValue := pValue;
end;

procedure TAqDBSQLLikeCondition.SetLeftWildCard(pValue: TAqDBSQLLikeWildCard);
begin
  FLeftWildCard := pValue;
end;

procedure TAqDBSQLLikeCondition.SetRightValue(pValue: IAqDBSQLTextConstant);
begin
  FRightValue := pValue;
end;

procedure TAqDBSQLLikeCondition.SetRightWildCard(pValue: TAqDBSQLLikeWildCard);
begin
  FRightWildCard := pValue;
end;

{ TAqDBSQLSelectSetup }

function TAqDBSQLSelectSetup.AddJoinParameters(pJoinParameters: IAqDBSQLJoinParameters): Int32;
begin
  if not Assigned(FJoinsParameters) or (FJoinsParameters.Count = 0) or not FJoinsParameters.Find(
    function(pItem: IAqDBSQLJoinParameters): Boolean
    begin
      Result := pItem.Identifier = pJoinParameters.Identifier;
    end) then
  begin
    Result := DoGetJoinsParameters.Add(pJoinParameters);
  end else
  begin
    Result := -1;
  end;
end;

function TAqDBSQLSelectSetup.AddJoinParameters(const pJoinTable, pMainTableColumns, pJoinTableColumns: string;
  const pJoinType: TAqDBSQLJoinType): IAqDBSQLJoinParameters;
var
  lMainTableColumns: TStringList;
  lJoinTableColumns: TStringList;
begin
  lMainTableColumns := TStringList.Create;

  try
    lJoinTableColumns := TStringList.Create;

    try
      lMainTableColumns.Delimiter := ';';
      lMainTableColumns.DelimitedText := pMainTableColumns;

      lJoinTableColumns.Delimiter := ';';
      lJoinTableColumns.DelimitedText := pJoinTableColumns;

      Result := AddJoinParameters(pJoinTable, lMainTableColumns, lJoinTableColumns, pJoinType);
    finally
      lJoinTableColumns.Free;
    end;
  finally
    lMainTableColumns.Free;
  end;
end;

function TAqDBSQLSelectSetup.AddJoinParameters(const pJoinTable: string;
  const pMainTableColumns, pJoinTableColumns: array of string;
  const pJoinType: TAqDBSQLJoinType): IAqDBSQLJoinParameters;
var
  lMasterTableColumns: TStringList;
  lJoinTableColumns: TStringList;
  lColumn: string;
begin
  lMasterTableColumns := TStringList.Create;

  try
    lJoinTableColumns := TStringList.Create;

    try
      for lColumn in pMainTableColumns do
      begin
        lMasterTableColumns.Add(lColumn);
      end;

      for lColumn in pJoinTableColumns do
      begin
        lJoinTableColumns.Add(lColumn);
      end;

      Result := AddJoinParameters(pJoinTable, lMasterTableColumns, lJoinTableColumns, pJoinType);
    finally
      lJoinTableColumns.Free;
    end;
  finally
    lMasterTableColumns.Free;
  end;
end;

function TAqDBSQLSelectSetup.AddJoinParameters(const pJoinTable: string;
  const pMainTableColumns, pJoinTableColumns: TStrings;
  const pJoinType: TAqDBSQLJoinType): IAqDBSQLJoinParameters;
var
  lLastJoinParameter: IAqDBSQLJoinParameters;
begin
  if Assigned(FJoinsParameters) and (FJoinsParameters.Count > 0) then
  begin
    lLastJoinParameter := FJoinsParameters.Last;
  end else begin
    lLastJoinParameter := nil;
  end;

  {TODO: criar sintaxe fluente para que a ligação de joins possa ser facilitada,
    atualmente a criação de joins sem ter essa informação faz com que a ligação aconteça sempre com o último parâmeto,
    pegando o seguinte caso: a liga com b que liga com c, e precisamos voltar para a que liga com d, seria algo do tipo
    setup.AddJoinParameters('b', 'a1', 'b1').AddJoinParameters('c', 'b2', 'c2');
    setup.AddJoinParameters('d', 'a1', 'd1'); // e aqui começa do main source novamente}
  Result := TAqDBSQLJoinParameters.Create(lLastJoinParameter, pJoinTable,
    pMainTableColumns, pJoinTableColumns, pJoinType);
  AddJoinParameters(Result);
end;

function TAqDBSQLSelectSetup.AddOrderBy(const pColumnName: string;
  const pColumnShouldBeReturnedAsResult: Boolean; const pAscending: Boolean): IAqDBSQLOrderByDescriptor;
begin
  Result := AddOrderBy(string.Empty, pColumnName, pColumnShouldBeReturnedAsResult, pAscending);
end;

function TAqDBSQLSelectSetup.AddOrderBy(pOrderByDescriptor: IAqDBSQLOrderByDescriptor): Int32;
begin
  Result := DoGetOrderbyList.Add(pOrderByDescriptor);
end;

function TAqDBSQLSelectSetup.AddOrderBy(const pIdentifier: string; pColumnName: string;
  const pColumnShouldBeReturnedAsResult: Boolean; const pAscending: Boolean): IAqDBSQLOrderByDescriptor;
begin
  Result := TAqDBSQLOrderByDescriptor.Create(pIdentifier, pColumnName, pColumnShouldBeReturnedAsResult, pAscending);
  AddOrderBy(Result);
end;

constructor TAqDBSQLSelectSetup.Create(pInitialCondition: IAqDBSQLCondition);
begin
  inherited Create;

  if Assigned(pInitialCondition) then
  begin
    GetCustomCondition.AddAnd(pInitialCondition);
  end;
end;

function TAqDBSQLSelectSetup.Distinct: IAqDBSQLSelectSetup;
begin
  FIsDistinguished := True;
  Result := Self;
end;

function TAqDBSQLSelectSetup.DoGetJoinsParameters: IAqList<IAqDBSQLJoinParameters>;
begin
  if not Assigned(FJoinsParameters) then
  begin
    FJoinsParameters := TAqList<IAqDBSQLJoinParameters>.Create;
  end;

  Result := FJoinsParameters;
end;

function TAqDBSQLSelectSetup.DoGetOrderbyList: IAqList<IAqDBSQLOrderByDescriptor>;
begin
  if not Assigned(FOrderByList) then
  begin
    FOrderByList := TAqList<IAqDBSQLOrderByDescriptor>.Create;
  end;

  Result := FOrderByList;
end;

function TAqDBSQLSelectSetup.GetConditionDescriptors: IAqDBSQLComposedConditionDescriptor;
begin
  if not Assigned(FConditionDescriptors) then
  begin
    FConditionDescriptors := TAqDBSQLComposedConditionDescriptor.Create;
  end;

  Result := FConditionDescriptors;
end;

function TAqDBSQLSelectSetup.GetCustomCondition: IAqDBSQLComposedCondition;
begin
  if not Assigned(FCustomCondition) then
  begin
    FCustomCondition := TAqDBSQLComposedCondition.Create;
  end;

  Result := FCustomCondition;
end;

function TAqDBSQLSelectSetup.GetHasConditionDescriptors: Boolean;
begin
  Result := Assigned(FConditionDescriptors) and (FConditionDescriptors.Count > 0);
end;

function TAqDBSQLSelectSetup.GetHasJoinsParameters: Boolean;
begin
  Result := Assigned(FJoinsParameters) and (FJoinsParameters.Count > 0);
end;

function TAqDBSQLSelectSetup.GetHasOrderBy: Boolean;
begin
  Result := Assigned(FOrderByList) and (FOrderByList.Count > 0);
end;

function TAqDBSQLSelectSetup.GetIsCustomConditionDefied: Boolean;
begin
  Result := Assigned(FCustomCondition);
end;

function TAqDBSQLSelectSetup.GetIsDistinguished: Boolean;
begin
  Result := FIsDistinguished;
end;

function TAqDBSQLSelectSetup.GetJoinsParameters: IAqReadableList<IAqDBSQLJoinParameters>;
begin
  Result := DoGetJoinsParameters.GetReadOnlyList;
end;

function TAqDBSQLSelectSetup.GetOrderByList: IAqReadableList<IAqDBSQLOrderByDescriptor>;
begin
  Result := DoGetOrderbyList.GetReadOnlyList;
end;

procedure TAqDBSQLSelectSetup.TakeSetup(pSetup: IAqDBSQLSelectsetup);
var
  lCandidate: IAqDBSQLJoinParameters;
  lJoinParameters: IAqList<IAqDBSQLJoinParameters>;
  lOrderBy: IAqDBSQLOrderByDescriptor;
  lOrderByList: IAqList<IAqDBSQLOrderByDescriptor>;
  lI: Int32;
begin
  if Assigned(pSetup) then
  begin
    if pSetup.IsDistinguished then
      Self.Distinct;

    if pSetup.IsCustomConditionDefied then
    begin
      GetCustomCondition.AddAnd(pSetup.CustomCondition);
    end;

    if pSetup.HasConditionDescriptors then
    begin
      {TODO 3 -oTatu -cMelhroia: criar sistema de identificação se descritor de condição não é repetida}
      GetConditionDescriptors.AddCondition(pSetup.ConditionDescriptors);
    end;

    if pSetup.HasJoinsParameters then
    begin
      lJoinParameters := DoGetJoinsParameters;
      for lCandidate in pSetup.JoinsParameters do
      begin
        if lJoinParameters.Find(
          function(pItem: IAqDBSQLJoinParameters): Boolean
          begin
            Result := pItem.Identifier = lCandidate.Identifier;
          end, lI) then
        begin
          lJoinParameters[lI].UpdateJoinTypeWithHighestPriority(lCandidate.JoinType);
        end else
        begin
          lJoinParameters.Add(lCandidate);
        end;
      end;
    end;

    if pSetup.HasOrderBy then
    begin
      lOrderByList := DoGetOrderbyList;

      for lOrderBy in pSetup.OrderByList do
      begin
        if not lOrderByList.Find(
          function(pItem: IAqDBSQLOrderByDescriptor): Boolean
          begin
            Result := (pItem.SourceIdentifier = lOrderBy.SourceIdentifier) and (pItem.ColumnName = lOrderBy.ColumnName);
          end) then
        begin
          lOrderByList.Add(lOrderBy);
        end;
      end;
    end;
  end;
end;

{ TAqDBSQLJoinParameters }

constructor TAqDBSQLJoinParameters.Create(const pJoinTable: string;
  const pMainTableColumns, pJoinTableColumns: TStrings; const pJoinType: TAqDBSQLJoinType);
begin
  inherited Create;

  FJoinType := pJoinType;
  FJoinTable := pJoinTable;
  FMainColumns := TStringList.Create;
  FJoinColumns := TStringList.Create;

  FMainColumns.Assign(pMainTableColumns);
  FJoinColumns.Assign(pJoinTableColumns);
end;

constructor TAqDBSQLJoinParameters.Create(pMainSourceJoin: IAqDBSQLJoinParameters; const pJoinTable: string;
  const pMainTableColumns, pJoinTableColumns: TStrings; const pJoinType: TAqDBSQLJoinType);
begin
  Create(pJoinTable, pMainTableColumns, pJoinTableColumns, pJoinType);

  FMainSourceJoin := pMainSourceJoin;
end;

constructor TAqDBSQLJoinParameters.Create(const pJoinTable, pMainTableColumns, pJoinTableColumns: string;
  const pJoinType: TAqDBSQLJoinType);
var
  lMainTableColumns: TStringList;
  lJoinTableColumns: TStringList;
begin
  lMainTableColumns := nil;
  lJoinTableColumns := nil;

  try
    lMainTableColumns := TStringList.Create;
    lMainTableColumns.Delimiter := ';';
    lMainTableColumns.DelimitedText := pMainTableColumns;

    lJoinTableColumns := TStringList.Create;
    lJoinTableColumns.Delimiter := ';';
    lJoinTableColumns.DelimitedText := pJoinTableColumns;

    Create(pJoinTable, lMainTableColumns, lJoinTableColumns, pJoinType);
  finally
    lMainTableColumns.Free;
    lJoinTableColumns.Free;
  end;
end;

constructor TAqDBSQLJoinParameters.Create(pMainSourceJoin: IAqDBSQLJoinParameters; const pJoinTable, pMainTableColumns,
  pJoinTableColumns: string; const pJoinType: TAqDBSQLJoinType);
var
  lMainTalbeColumns: TStringList;
  lJoinTalbeColumns: TStringList;
begin
  lMainTalbeColumns := nil;
  lJoinTalbeColumns := nil;
  try
    lMainTalbeColumns := TStringList.Create;
    lMainTalbeColumns.Delimiter := ';';
    lMainTalbeColumns.StrictDelimiter := True;
    lMainTalbeColumns.DelimitedText := pMainTableColumns;

    lJoinTalbeColumns := TStringList.Create;
    lJoinTalbeColumns.Delimiter := ';';
    lJoinTalbeColumns.StrictDelimiter := True;
    lJoinTalbeColumns.DelimitedText := pJoinTableColumns;

    Create(pMainSourceJoin, pJoinTable, lMainTalbeColumns, lJoinTalbeColumns, pJoinType);
  finally
    lJoinTalbeColumns.Free;
    lMainTalbeColumns.Free;
  end;
end;

destructor TAqDBSQLJoinParameters.Destroy;
begin
  FJoinColumns.Free;
  FMainColumns.Free;

  inherited;
end;

function TAqDBSQLJoinParameters.GetCustomCondition: string;
begin
  Result := FCustomCondition;
end;

function TAqDBSQLJoinParameters.GetIdentifier: string;
var
  lI: Int32;
  lCondition: string;
begin
  if Assigned(FMainSourceJoin) then
  begin
    Result := FMainSourceJoin.Identifier + '|';
  end else
  begin
    Result := '';
  end;

  if VerifyIfHasCustomCondition then
  begin
    lCondition := FCustomCondition;
  end else
  begin
    if (FMainColumns.Count <= 0) or (FMainColumns.Count <> FJoinColumns.Count) then
    begin
      raise EAqInternal.Create('Invalid number of columns in the join parameter.');
    end;

    lCondition := FMainColumns[0] + '=' + FJoinColumns[0];

    for lI := 1 to FMainColumns.Count - 1 do
    begin
      lCondition := lCondition + '|' + FMainColumns[lI] + '=' + FJoinColumns[lI];
    end;
  end;

  Result := Result + (FJoinTable + '(' + lCondition + ')').ToUpper;
end;

function TAqDBSQLJoinParameters.GetJoinColumns: TStrings;
begin
  Result := FJoinColumns;
end;

function TAqDBSQLJoinParameters.GetJoinTable: string;
begin
  Result := FJoinTable;
end;

function TAqDBSQLJoinParameters.GetJoinTableAlias: string;
begin
  if FJoinTableAlias.IsEmpty then
  begin
    Result := FJoinTable;
  end else
  begin
    Result := FJoinTableAlias;
  end;
end;

function TAqDBSQLJoinParameters.GetJoinType: TAqDBSQLJoinType;
begin
  Result := FJoinType;
end;

function TAqDBSQLJoinParameters.GetMainColumns: TStrings;
begin
  Result := FMainColumns;
end;

function TAqDBSQLJoinParameters.GetMainSourceJoin: IAqDBSQLJoinParameters;
begin
  Result := FMainSourceJoin;
end;

function TAqDBSQLJoinParameters.SetJoinTableAlias(const pJoinTableAlias: string): IAqDBSQLJoinParameters;
begin
  FJoinTableAlias := pJoinTableAlias;
  Result := Self;
end;

procedure TAqDBSQLJoinParameters.UpdateJoinTypeWithHighestPriority(const pJoinType: TAqDBSQLJoinType);
begin
  if pJoinType < FJoinType then
  begin
    FJoinType := pJoinType;
  end;
end;

function TAqDBSQLJoinParameters.VerifyIfHasCustomCondition: Boolean;
begin
  Result := not FCustomCondition.IsEmpty;
end;

constructor TAqDBSQLJoinParameters.Create(pMainSourceJoin: IAqDBSQLJoinParameters; const pJoinTable,
  pCustomCondition: string; const pJoinType: TAqDBSQLJoinType);
begin
  FMainSourceJoin := pMainSourceJoin;
  FJoinTable := pJoinTable;
  FCustomCondition := pCustomCondition;
  FJoinType := pJoinType;
end;

constructor TAqDBSQLJoinParameters.Create(const pJoinTable, pCustomCondition: string;
  const pJoinType: TAqDBSQLJoinType);
begin
  Create(nil, pJoinTable, pCustomCondition, pJoinType);
end;

{ TAqDBSQLSimpleComparisonDescriptor }

constructor TAqDBSQLSimpleComparisonDescriptor.Create(const pColumnName: string; const pComparison: TAqDBSQLComparison;
  pComparisonValue: IAqDBSQLValue);
begin
  inherited Create(pColumnName);

  FComparison := pComparison;
  FComparisonValue := pComparisonValue;
end;

function TAqDBSQLSimpleComparisonDescriptor.GetAsSimpleComparisonDescriptor: IAqDBSQLSimpleComparisonDescriptor;
begin
  Result := Self;
end;

function TAqDBSQLSimpleComparisonDescriptor.GetComparison: TAqDBSQLComparison;
begin
  Result := FComparison;
end;

function TAqDBSQLSimpleComparisonDescriptor.GetComparisonValue: IAqDBSQLValue;
begin
  Result := FComparisonValue;
end;

function TAqDBSQLSimpleComparisonDescriptor.GetConditionDescriptorType: TAqDBSQLConditionDescriptorType;
begin
  Result := TAqDBSQLConditionDescriptorType.cdComparison;
end;

{ TAqDBSQLConditionDescriptor }

function TAqDBSQLConditionDescriptor.GetAsBetweenDescriptor: IAqDBSQLBetweenDescriptor;
begin
  raise EAqInternal.Create('This descriptor doesn''t implement IAqDBSQLBetweenDescriptor.');
end;

function TAqDBSQLConditionDescriptor.GetAsComposedConditionDescriptor: IAqDBSQLComposedConditionDescriptor;
begin
  raise EAqInternal.Create('This descriptor doesn''t implement IAqDBSQLComposedConditionDescriptor.');
end;

function TAqDBSQLConditionDescriptor.GetAsInDescriptor: IAqDBSQLInDescriptor;
begin
  raise EAqInternal.Create('This descriptor doesn''t implement IAqDBSQLInDescriptor.');
end;

function TAqDBSQLConditionDescriptor.GetAsIsNotNullDescriptor: IAqDBSQLIsNotNullDescriptor;
begin
  raise EAqInternal.Create('This descriptor doesn''t implement IAqDBSQLIsNotNullDescriptor.');
end;

function TAqDBSQLConditionDescriptor.GetAsIsNullDescriptor: IAqDBSQLIsNullDescriptor;
begin
  raise EAqInternal.Create('This descriptor doesn''t implement IAqDBSQLIsNullDescriptor.');
end;

function TAqDBSQLConditionDescriptor.GetAsLikeDescriptor: IAqDBSQLLikeDescriptor;
begin
  raise EAqInternal.Create('This descriptor doesn''t implement IAqDBSQLLikeDescriptor.');
end;

function TAqDBSQLConditionDescriptor.GetAsSimpleComparisonDescriptor: IAqDBSQLSimpleComparisonDescriptor;
begin
  raise EAqInternal.Create('This descriptor doesn''t implement IAqDBSQLSimpleComparisonDescriptor.');
end;

function TAqDBSQLConditionDescriptor.Negate: IAqDBSQLConditionDescriptor;
begin
  FNegated := not FNegated;
  Result := Self;
end;

function TAqDBSQLConditionDescriptor.VerifyIfIsNegated: Boolean;
begin
  Result := FNegated;
end;

{ TAqDBSQLLikeDescriptor }

constructor TAqDBSQLLikeDescriptor.Create(const pColumnName: string; pLikeValue: IAqDBSQLTextConstant);
begin
  inherited Create(pColumnName);

  FLikeValue := pLikeValue;
end;

function TAqDBSQLLikeDescriptor.GetAsLikeDescriptor: IAqDBSQLLikeDescriptor;
begin
  Result := Self;
end;

function TAqDBSQLLikeDescriptor.GetConditionDescriptorType: TAqDBSQLConditionDescriptorType;
begin
  Result := TAqDBSQLConditionDescriptorType.cdLike;
end;

function TAqDBSQLLikeDescriptor.GetLikeValue: IAqDBSQLTextConstant;
begin
  Result := FLikeValue;
end;

{ TAqDBSQLOrderByDescriptor }

constructor TAqDBSQLOrderByDescriptor.Create(const pSourceIdentifier, pColumnName: string;
  const pColumnShouldBeReturnedAsResult: Boolean; const pAscending: Boolean);
begin
  FSourceIdentifier := pSourceIdentifier;
  FColumnName := pColumnName;
  FAscending := pAscending;
  FColumnShouldBeReturnedAsResult := pColumnShouldBeReturnedAsResult;
end;

function TAqDBSQLOrderByDescriptor.GetColumnName: string;
begin
  Result := FColumnName;
end;

function TAqDBSQLOrderByDescriptor.GetColumnShouldBeReturnedAsResult: Boolean;
begin
  Result := FColumnShouldBeReturnedAsResult;
end;

function TAqDBSQLOrderByDescriptor.GetGeneratedColumn: IAqDBSQLColumn;
begin
  Result := FGeneratedColumn;
end;

function TAqDBSQLOrderByDescriptor.GetSourceIdentifier: string;
begin
  Result := FSourceIdentifier;
end;

function TAqDBSQLOrderByDescriptor.GetIsAscending: Boolean;
begin
  Result := FAscending;
end;

procedure TAqDBSQLOrderByDescriptor.SetGeneratedColumn(pColumn: IAqDBSQLColumn);
begin
  FGeneratedColumn := pColumn;
end;

function TAqDBSQLOrderByDescriptor.VerifyIfHasSourceIdentifier: Boolean;
begin
  Result := not FSourceIdentifier.IsEmpty;
end;

{ TAqDBSQLComposedConditionDescriptor }

function TAqDBSQLComposedConditionDescriptor.AddComposedDescriptor(
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLComposedConditionDescriptor;
begin
  Result := TAqDBSQLComposedConditionDescriptor.Create;
  AddCondition(Result, pLinkOperator)
end;

function TAqDBSQLComposedConditionDescriptor.AddCondition(pCondition: IAqDBSQLConditionDescriptor;
  const pLinkOperator: TAqDBSQLBooleanOperator): Int32;
begin
  Result := FConditions.Add(pCondition);
  if Result > 0 then
  begin
    FLinks.Add(pLinkOperator);
  end;
end;

function TAqDBSQLComposedConditionDescriptor.AddIsNull(const pColumnName: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLIsNullDescriptor;
begin
  Result := AddIsNull('', pColumnName, pLinkOperator);
end;

function TAqDBSQLComposedConditionDescriptor.AddIsNull(const pSourceIdentifier, pColumnName: string;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLIsNullDescriptor;
begin
  Result := TAqDBSQLIsNullDescriptor.Create(pColumnName);
  Result.SourceIdentifier := pSourceIdentifier;
  AddCondition(Result, pLinkOperator);
end;

function TAqDBSQLComposedConditionDescriptor.AddLike(const pSourceIdentifier, pColumnName: string;
  pLikeValue: IAqDBSQLTextConstant; const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLLikeDescriptor;
begin
  Result := TAqDBSQLLikeDescriptor.Create(pColumnName, pLikeValue);
  Result.SourceIdentifier := pSourceIdentifier;
  AddCondition(Result, pLinkOperator);
end;

function TAqDBSQLComposedConditionDescriptor.AddComparison(const pSourceIdentifier, pColumnName: string;
  const pComparison: TAqDBSQLComparison; pComparisonValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLSimpleComparisonDescriptor;
begin
  Result := TAqDBSQLSimpleComparisonDescriptor.Create(pColumnName, pComparison, pComparisonValue);
  Result.SourceIdentifier := pSourceIdentifier;
  AddCondition(Result, pLinkOperator);
end;

function TAqDBSQLComposedConditionDescriptor.AddComparison(const pColumnName: string;
  const pComparison: TAqDBSQLComparison; pComparisonValue: IAqDBSQLValue;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLSimpleComparisonDescriptor;
begin
  Result := AddComparison('', pColumnName, pComparison, pComparisonValue, pLinkOperator);
end;

function TAqDBSQLComposedConditionDescriptor.AddLike(const pColumnName: string; pLikeValue: IAqDBSQLTextConstant;
  const pLinkOperator: TAqDBSQLBooleanOperator): IAqDBSQLLikeDescriptor;
begin
  Result := AddLike('', pColumnName, pLikeValue, pLinkOperator);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pColumnName: string;
  pComparisonValue: string): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  AddComparison(pSourceIdentifier, pColumnName, TAqDBSQLComparison.cpEqual, pComparisonValue,
    TAqDBSQLBooleanOperator.boAnd);
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: string): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals(pSourceIdentifier, pColumnName, TAqDBSQLTextConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals(pSourceIdentifier, pColumnName, TAqDBSQLIntConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: TDateTime): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals(pSourceIdentifier, pColumnName, TAqDBSQLDateTimeConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pColumnName: string;
  pComparisonValue: TDateTime): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals(pSourceIdentifier, pColumnName, TAqDBSQLDateConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pColumnName: string;
  pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreaterOrEqual(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  AddComparison(pSourceIdentifier, pColumnName, TAqDBSQLComparison.cpGreaterEqual, pComparisonValue,
    TAqDBSQLBooleanOperator.boAnd);
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreaterOrEqual(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreaterOrEqual(pSourceIdentifier, pColumnName, TAqDBSQLDateConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreater(
  const pColumnName: string;
  pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreater('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreater(
  const pSourceIdentifier, pColumnName: string;
  pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreater(pSourceIdentifier, pColumnName, TAqDBSQLIntConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreater(
  const pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreater('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreater(
  const pSourceIdentifier, pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  AddComparison(pSourceIdentifier, pColumnName, TAqDBSQLComparison.cpGreaterThan, pComparisonValue,
    TAqDBSQLBooleanOperator.boAnd);
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreater(
  const pColumnName: string;
  pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreater('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreater(
  const pSourceIdentifier, pColumnName: string;
  pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreater(pSourceIdentifier, pColumnName, TAqDBSQLDateConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreater(
  const pColumnName: string;
  pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreater('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreater(
  const pSourceIdentifier, pColumnName: string;
  pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreater(pSourceIdentifier, pColumnName, TAqDBSQLDoubleConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreaterOrEqual(const pColumnName: string;
  pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreaterOrEqual('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreaterOrEqual(const pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreaterOrEqual('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreaterOrEqual(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreaterOrEqual(pSourceIdentifier, pColumnName, TAqDBSQLIntConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreaterOrEqual(const pColumnName: string;
  pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreaterOrEqual('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreaterOrEqual(const pColumnName: string;
  pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreaterOrEqual('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsGreaterOrEqual(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsGreaterOrEqual(pSourceIdentifier, pColumnName, TAqDBSQLDoubleConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsLessOrEqual(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  AddComparison(pSourceIdentifier, pColumnName, TAqDBSQLComparison.cpLessEqual, pComparisonValue,
    TAqDBSQLBooleanOperator.boAnd);
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsLessOrEqual(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsLessOrEqual(pSourceIdentifier, pColumnName, TAqDBSQLDateConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsLessOrEqual(const pColumnName: string;
  pComparisonValue: TDate): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsLessOrEqual('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsNull(const pColumnName: string): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsNull('', pColumnName);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsNull(const pSourceIdentifier, pColumnName: string): IAqDBSQLComposedConditionDescriptor;
begin
  AddIsNull(pSourceIdentifier, pColumnName, TAqDBSQLBooleanOperator.boAnd);
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsLessOrEqual(const pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsLessOrEqual('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnLike(const pSourceIdentifier, pColumnName: string;
  pLikeValue: IAqDBSQLTextConstant): IAqDBSQLComposedConditionDescriptor;
begin
  AddLike(pSourceIdentifier, pColumnName, pLikeValue, TAqDBSQLBooleanOperator.boAnd);
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnLike(const pSourceIdentifier, pColumnName: string;
  pLikeValue: string): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnLike(pSourceIdentifier, pColumnName, TAqDBSQLTextConstant.Create(pLikeValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsLessOrEqual(const pColumnName: string;
  pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsLessOrEqual('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsLessOrEqual(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsLessOrEqual(pSourceIdentifier, pColumnName, TAqDBSQLIntConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsLessOrEqual(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsLessOrEqual(pSourceIdentifier, pColumnName, TAqDBSQLDoubleConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnIsLessOrEqual(const pColumnName: string;
  pComparisonValue: Double): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnIsLessOrEqual('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnLike(const pColumnName: string;
  pLikeValue: string): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnLike('', pColumnName, TAqDBSQLTextConstant.Create(pLikeValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnLike(const pColumnName: string;
  pLikeValue: IAqDBSQLTextConstant): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnLike('', pColumnName, pLikeValue);
end;

constructor TAqDBSQLComposedConditionDescriptor.Create;
begin
  FConditions := TAqList<IAqDBSQLConditionDescriptor>.Create;
  FLinks := TAqList<TAqDBSQLBooleanOperator>.Create;
end;

function TAqDBSQLComposedConditionDescriptor.GetAsComposedConditionDescriptor: IAqDBSQLComposedConditionDescriptor;
begin
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.GetConditionDescriptorType: TAqDBSQLConditionDescriptorType;
begin
  Result := TAqDBSQLConditionDescriptorType.cdComposed;
end;

function TAqDBSQLComposedConditionDescriptor.GetCount: Int32;
begin
  Result := FConditions.Count;
end;

function TAqDBSQLComposedConditionDescriptor.GetItem(const pIndex: Int32): IAqDBSQLConditionDescriptor;
begin
  Result := FConditions.Items[pIndex];
end;

function TAqDBSQLComposedConditionDescriptor.GetLinkOperator(const pIndex: Int32): TAqDBSQLBooleanOperator;
begin
  Result := FLinks[pIndex];
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnEquals(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := OrColumnEquals(pSourceIdentifier, pColumnName, TAqDBSQLIntConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnEquals(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  AddComparison(pSourceIdentifier, pColumnName, TAqDBSQLComparison.cpEqual, pComparisonValue,
    TAqDBSQLBooleanOperator.boOr);
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnEquals(const pColumnName: string;
  pComparisonValue: int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := OrColumnEquals('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnIsNull(const pColumnName: string): IAqDBSQLComposedConditionDescriptor;
begin
  Result := OrColumnIsNull('', pColumnName);
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnIsNull(const pSourceIdentifier, pColumnName: string): IAqDBSQLComposedConditionDescriptor;
begin
  AddIsNull(pSourceIdentifier, pColumnName, TAqDBSQLBooleanOperator.boOr);
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnLike(const pSourceIdentifier, pColumnName: string;
  pLikeValue: IAqDBSQLTextConstant): IAqDBSQLComposedConditionDescriptor;
begin
  AddLike(pSourceIdentifier, pColumnName, pLikeValue, TAqDBSQLBooleanOperator.boOr);
  Result := Self;
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnLike(const pSourceIdentifier, pColumnName: string;
  pLikeValue: string): IAqDBSQLComposedConditionDescriptor;
begin
  Result := OrColumnLike(pSourceIdentifier, pColumnName, TAqDBSQLTextConstant.Create(pLikeValue));
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnLike(const pColumnName: string;
  pLikeValue: string): IAqDBSQLComposedConditionDescriptor;
begin
  Result := OrColumnLike('', pColumnName, pLikeValue);
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnLike(const pColumnName: string;
  pLikeValue: IAqDBSQLTextConstant): IAqDBSQLComposedConditionDescriptor;
begin
  Result := OrColumnLike('', pColumnName, pLikeValue);
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnEquals(const pColumnName: string;
  pComparisonValue: IAqDBSQLValue): IAqDBSQLComposedConditionDescriptor;
begin
  Result := OrColumnEquals('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pColumnName: string;
  pComparisonValue: Int64): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnEquals(const pColumnName: string; pComparisonValue: String): IAqDBSQLComposedConditionDescriptor;
begin
  Result := OrColumnEquals('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.OrColumnEquals(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: String): IAqDBSQLComposedConditionDescriptor;
begin
  Result := OrColumnEquals(pSourceIdentifier, pColumnName, TAqDBSQLTextConstant.Create(pComparisonValue));
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pColumnName: string; pComparisonValue: TGUID): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals('', pColumnName, pComparisonValue);
end;

function TAqDBSQLComposedConditionDescriptor.AndColumnEquals(const pSourceIdentifier, pColumnName: string;
  pComparisonValue: TGUID): IAqDBSQLComposedConditionDescriptor;
begin
  Result := AndColumnEquals(pSourceIdentifier, pColumnName, TAqDBSQLGUIDConstant.Create(pComparisonValue));
end;

{ TAqDBSQLColumnBasedConditionDescriptor }

procedure TAqDBSQLColumnBasedConditionDescriptor.ClearSourceIdentifier;
begin
  FSourceIdentifier.Clear;
end;

constructor TAqDBSQLColumnBasedConditionDescriptor.Create(const pColumnName: string);
begin
  FColumnName := pColumnName;
end;

function TAqDBSQLColumnBasedConditionDescriptor.GetColumnName: string;
begin
  Result := FColumnName;
end;

function TAqDBSQLColumnBasedConditionDescriptor.GetSourceIdentifier: string;
begin
  Result := FSourceIdentifier;
end;

procedure TAqDBSQLColumnBasedConditionDescriptor.SetSourceIdentifier(const pValue: string);
begin
  FSourceIdentifier := pValue;
end;

function TAqDBSQLColumnBasedConditionDescriptor.VerifyIfHasSourceIdentifier: Boolean;
begin
  Result := not FSourceIdentifier.IsEmpty;
end;

{ TAqDBSQLBetweenDescriptor }

constructor TAqDBSQLBetweenDescriptor.Create(const pColumnName: string; pLeftBoundaryValue,
  pRightBoundaryValue: IAqDBSQLConstant);
begin
  inherited Create(pColumnName);

  FLeftBoundaryValue := pLeftBoundaryValue;
  FRightBoundaryValue := pRightBoundaryValue;
end;

function TAqDBSQLBetweenDescriptor.GetAsBetweenDescriptor: IAqDBSQLBetweenDescriptor;
begin
  Result := Self;
end;

function TAqDBSQLBetweenDescriptor.GetConditionDescriptorType: TAqDBSQLConditionDescriptorType;
begin
  Result := TAqDBSQLConditionDescriptorType.cdBetween;
end;

function TAqDBSQLBetweenDescriptor.GetLeftBoundaryValue: IAqDBSQLConstant;
begin
  Result := FLeftBoundaryValue;
end;

function TAqDBSQLBetweenDescriptor.GetRightBoundaryValue: IAqDBSQLConstant;
begin
  Result := FRightBoundaryValue;
end;

{ TAqDBSQLInCondition }

procedure TAqDBSQLInCondition.AddInValue(pValue: IAqDBSQLValue);
begin
  FInValues.Add(pValue);
end;

constructor TAqDBSQLInCondition.Create(pTestableValue: IAqDBSQLValue);
begin
  FTestableValue := pTestableValue;
  FInValues := TAqList<IAqDBSQLValue>.Create;
end;

function TAqDBSQLInCondition.GetAsIn: IAqDBSQLInCondition;
begin
  Result := Self;
end;

function TAqDBSQLInCondition.GetConditionType: TAqDBSQLConditionType;
begin
  Result := TAqDBSQLConditionType.ctIn;
end;

function TAqDBSQLInCondition.GetInValues: IAqReadableList<IAqDBSQLValue>;
begin
  Result := FInValues.GetReadOnlyList;
end;

function TAqDBSQLInCondition.GetTestableValue: IAqDBSQLValue;
begin
  Result := FTestableValue;
end;

procedure TAqDBSQLInCondition.SetTestableValue(pValue: IAqDBSQLValue);
begin
  FTestableValue := pValue;
end;

{ TAqDBSQLInDescriptor }

procedure TAqDBSQLInDescriptor.AddInValue(pValue: IAqDBSQLConstant);
begin
  FInValues.Add(pValue);
end;

constructor TAqDBSQLInDescriptor.Create(const pColumnName: string);
begin
  inherited;

  FInValues := TAqList<IAqDBSQLConstant>.Create;
end;

function TAqDBSQLInDescriptor.GetAsInDescriptor: IAqDBSQLInDescriptor;
begin
  Result := Self;
end;

function TAqDBSQLInDescriptor.GetConditionDescriptorType: TAqDBSQLConditionDescriptorType;
begin
  Result := TAqDBSQLConditionDescriptorType.cdIn;
end;

function TAqDBSQLInDescriptor.GetInValues: IAqReadableList<IAqDBSQLConstant>;
begin
  Result := FInValues.GetReadOnlyList;
end;

{ TAqDBSQLIsNullDescriptor }

function TAqDBSQLIsNullDescriptor.GetAsIsNullDescriptor: IAqDBSQLIsNullDescriptor;
begin
  Result := Self;
end;

function TAqDBSQLIsNullDescriptor.GetConditionDescriptorType: TAqDBSQLConditionDescriptorType;
begin
  Result := TAqDBSQLConditionDescriptorType.cdIsNull;
end;

{ TAqDBSQLIsNotNullDescriptor }

function TAqDBSQLIsNotNullDescriptor.GetAsIsNotNullDescriptor: IAqDBSQLIsNotNullDescriptor;
begin
  Result := Self;
end;

function TAqDBSQLIsNotNullDescriptor.GetConditionDescriptorType: TAqDBSQLConditionDescriptorType;
begin
  Result := TAqDBSQLConditionDescriptorType.cdIsNotNull;
end;

{ TAqDBSQLExistsCondition }

constructor TAqDBSQLExistsCondition.Create(pTable: string);
begin
  FSelect := TAqDBSQLSelect.Create(pTable);
  FSelect.AddColumn('1');
end;

constructor TAqDBSQLExistsCondition.Create(pSource: IAqDBSQLSource);
begin
  FSelect := TAqDBSQLSelect.Create(pSource);
  FSelect.AddColumn('1');
end;

function TAqDBSQLExistsCondition.GetAsExists: IAqDBSQLExistsCondition;
begin
  Result := Self;
end;

function TAqDBSQLExistsCondition.GetConditionType: TAqDBSQLConditionType;
begin
  Result := TAqDBSQLConditionType.ctExists;
end;

function TAqDBSQLExistsCondition.GetSelect: IAqDBSQLSelect;
begin
  Result := FSelect;
end;

{ TAqDBSQLJoinWithComposedCondition }

constructor TAqDBSQLJoinWithComposedCondition.Create(const pType: TAqDBSQLJoinType; pJoinSource: IAqDBSQLSource;
  pCondition: IAqDBSQLCondition);
begin
  Create(pType, pJoinSource);

  FCondition := pCondition;
end;

constructor TAqDBSQLJoinWithComposedCondition.Create(const pType: TAqDBSQLJoinType; pPreviousJoin: IAqDBSQLJoin;
  pJoinSource: IAqDBSQLSource; pCondition: IAqDBSQLCondition);
begin
  Create(pType, pPreviousJoin, pJoinSource);

  FCondition := pCondition;
end;

function TAqDBSQLJoinWithComposedCondition.EqualsTo(pValue: IAqDBSQLValue): IAqDBSQLJoinWithComposedCondition;
var
  lConditions: IAqReadableList<IAqDBSQLCondition>;
begin
  if not Assigned(FCondition) or (FCondition.ConditionType <> TAqDBSQLConditionType.ctComposed) then
  begin
    raise EAqInternal.Create('Unexpected condition in ' + Self.QualifiedClassName);
  end;

  lConditions := FCondition.GetAsComposed.Conditions;

  if (lConditions.Count = 0) or (lConditions.Last.ConditionType <> TAqDBSQLConditionType.ctComparison) then
  begin
    raise EAqInternal.Create('Unexpected condition type in ' + Self.QualifiedClassName);
  end;

  lConditions.Last.GetAsComparison.RightValue := pValue;

  Result := Self;
end;

constructor TAqDBSQLJoinWithComposedCondition.Create(const pType: TAqDBSQLJoinType; pJoinSource,
  pMasterSource: IAqDBSQLSource; pCondition: IAqDBSQLCondition);
begin
  Create(pType, pJoinSource, pMasterSource);

  FCondition := pCondition;
end;

function TAqDBSQLJoinWithComposedCondition.EqualsTo(const pColumnName: string): IAqDBSQLJoinWithComposedCondition;
begin
  Result := EqualsTo(TAqDBSQLColumn.Create(pColumnName, GetMainSource));
end;

function TAqDBSQLJoinWithComposedCondition.GetAsJoinWithComposedCondition: IAqDBSQLJoinWithComposedCondition;
begin
  Result := Self;
end;

function TAqDBSQLJoinWithComposedCondition.GetCondition: IAqDBSQLCondition;
begin
  Result := FCondition;
end;

function TAqDBSQLJoinWithComposedCondition.GetConditionType: TAqDBSQLJoinConditionType;
begin
  Result := TAqDBSQLJoinConditionType.jctComposed;
end;

function TAqDBSQLJoinWithComposedCondition.GetIdentifier: string;
  function GetIdentifierFromComparison(pComparison: IAqDBSQLComparisonCondition): string;
  begin
    if (pComparison.LeftValue.ValueType = TAqDBSQLValueType.vtColumn) and
      (pComparison.Comparison = TAqDBSQLComparison.cpEqual) and
      (pComparison.RightValue.ValueType = TAqDBSQLValueType.vtColumn) then
    begin
      Result := pComparison.LeftValue.GetAsColumn.Expression + '=' + pComparison.RightValue.GetAsColumn.Expression;
    end else begin
      Result := '';
    end;
  end;

  function GetIdentifierFromCondition(pCondition: IAqDBSQLCondition): string;
  begin
    if pCondition.ConditionType = TAqDBSQLConditionType.ctComparison then
    begin
      Result := GetIdentifierFromComparison(pCondition.GetAsComparison);
    end else begin
      RaiseNotPossibleToMountIdentifier;
    end;
  end;

  function GetIdentifierFromComposedCondition(pComposedCondition: IAqDBSQLComposedCondition): string;
  var
    lI: Int32;
    lConditions: IAqReadableList<IAqDBSQLCondition>;
  begin
    lConditions := pComposedCondition.Conditions;

    if lConditions.Count <= 0 then
    begin
      RaiseNotPossibleToMountIdentifier;
    end;

    Result := GetIdentifierFromCondition(lConditions.First);

    for lI := 1 to lConditions.Count - 1 do
    begin
      Result := Result + '|' + GetIdentifierFromCondition(lConditions[lI]);
    end;
  end;
var
  lCondition: string;
begin
  Result := inherited;

  if Assigned(FCondition) then
  begin
    case FCondition.ConditionType of
      ctComparison:
        lCondition := GetIdentifierFromComparison(FCondition.GetAsComparison);
      ctComposed:
        lCondition := GetIdentifierFromComposedCondition(FCondition.GetAsComposed);
    else
      RaiseNotPossibleToMountIdentifier;
    end;
  end;

  Result := Result + '(' + lCondition + ')';
end;

function TAqDBSQLJoinWithComposedCondition.&On(const pColumnName: string): IAqDBSQLJoinWithComposedCondition;
var
  lComposedCondition: IAqDBSQLComposedCondition;
begin
  if Assigned(FCondition) then
  begin
    if FCondition.ConditionType <> TAqDBSQLConditionType.ctComposed then
    begin
      raise EAqInternal.Create('Unexpected condition type in ' + Self.QualifiedClassName);
    end;
    lComposedCondition := FCondition.GetAsComposed;
  end else
  begin
    lComposedCondition := TAqDBSQLComposedCondition.Create;
    FCondition := lComposedCondition;
  end;

  lComposedCondition.AddAnd(TAqDBSQLComparisonCondition.Create(
    TAqDBSQLColumn.Create(pColumnName, GetSource), TAqDBSQLComparison.cpEqual, nil));
  Result := Self;
end;

{ TAqDBSQLJoinWithCustomCondition }

constructor TAqDBSQLJoinWithCustomCondition.Create(const pType: TAqDBSQLJoinType; pPreviousJoin: IAqDBSQLJoin;
  pJoinSource: IAqDBSQLSource; const pCustomCondition: string);
begin
  Create(pType, pPreviousJoin, pJoinSource);

  FCustomCondition := pCustomCondition;
end;

constructor TAqDBSQLJoinWithCustomCondition.Create(const pType: TAqDBSQLJoinType;
  pJoinSource, pMasterSource: IAqDBSQLSource; const pCustomCondition: string);
begin
  Create(pType, pJoinSource, pMasterSource);

  FCustomCondition := pCustomCondition;
end;

constructor TAqDBSQLJoinWithCustomCondition.Create(const pType: TAqDBSQLJoinType; pJoinSource: IAqDBSQLSource;
  const pCustomCondition: string);
begin
  Create(pType, pJoinSource);

  FCustomCondition := pCustomCondition;
end;

function TAqDBSQLJoinWithCustomCondition.GetAsJoinWithCustomCondition: IAqDBSQLJoinWithCustomCondition;
begin
  Result := Self;
end;

function TAqDBSQLJoinWithCustomCondition.GetCustomCondition: string;
begin
  Result := FCustomCondition;
end;

function TAqDBSQLJoinWithCustomCondition.GetConditionType: TAqDBSQLJoinConditionType;
begin
  Result := TAqDBSQLJoinConditionType.jctCustom;
end;

function TAqDBSQLJoinWithCustomCondition.GetIdentifier: string;
begin
  Result := inherited + '(' + FCustomCondition.ToUpper + ')';
end;

{ TAqDBSQLGUIDConstant }

function TAqDBSQLGUIDConstant.GetAsGUIDConstant: IAqDBSQLGUIDConstant;
begin
  Result := Self;
end;

function TAqDBSQLGUIDConstant.GetConstantType: TAqDBSQLConstantValueType;
begin
  Result := TAqDBSQLConstantValueType.cvGUID;
end;

end.
