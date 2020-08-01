unit AqDrop.DB.SQL.Intf;

interface

uses
  System.Classes,
  AqDrop.Core.Collections.Intf;

type
  TAqDBSQLCommandType = (ctSelect, ctInsert, ctUpdate, ctDelete);
  TAqDBSQLSourceType = (stTable, stSelect);
  TAqDBSQLValueType = (vtColumn, vtOperation, vtSubselect, vtConstant, vtParameter);
  TAqDBSQLConstantValueType = (cvText, cvInt, cvDouble, cvCurrency, cvDateTime, cvDate, cvTime, cvBoolean, cvUInt, cvGUID);
  TAqDBSQLAggregatorType = (atNone, atCount, atSum, atAvg, atMax, atMin);
  TAqDBSQLConditionType = (ctComparison, ctValueIsNull, ctComposed, ctLike, ctBetween, ctIn, ctExists);
  TAqDBSQLOperator = (opSum, opSubtraction, opMultiplication, opDivision, opDiv, opMod);
  TAqDBSQLComparison = (cpEqual, cpGreaterThan, cpGreaterEqual, cpLessThan, cpLessEqual, cpNotEqual);
  TAqDBSQLConditionDescriptorType = (cdComposed, cdComparison, cdLike, cdBetween, cdIn, cdIsNull, cdIsNotNull);
  TAqDBSQLJoinType = (jtInnerJoin, jtLeftJoin); // please, keep the order of this enumerated from the most restrictive to the least restrictive, this order is used to update the priority of join type in TakeSetup methods
  TAqDBSQLJoinConditionType = (jctComposed, jctCustom);
  TAqDBSQLBooleanOperator = (boAnd, boOr, boXor);
  TAqDBSQLLikeWildCard = (lwcNone, lwcSingleChar, lwcMultipleChars);

  {TODO 3 -oTatu -cMelhoria: criar tipo enumerado para o tipo ordenação de order by (ascendente e descendente) e substituir os booleans que hoje dizem se é ascendente ou não}

  IAqDBSQLAliasable = interface;

  IAqDBSQLColumn = interface;
  IAqDBSQLOperation = interface;
  IAqDBSQLSubselect = interface;
  IAqDBSQLConstant = interface;
  IAqDBSQLParameter = interface;

  IAqDBSQLComparisonCondition = interface;
  IAqDBSQLValueIsNullCondition = interface;
  IAqDBSQLComposedCondition = interface;
  IAqDBSQLLikeCondition = interface;
  IAqDBSQLBetweenCondition = interface;
  IAqDBSQLInCondition = interface;
  IAqDBSQLExistsCondition = interface;

  IAqDBSQLTextConstant = interface;
  IAqDBSQLIntConstant = interface;
  IAqDBSQLUIntConstant = interface;
  IAqDBSQLDoubleConstant = interface;
  IAqDBSQLCurrencyConstant = interface;
  IAqDBSQLDateTimeConstant = interface;
  IAqDBSQLDateConstant = interface;
  IAqDBSQLTimeConstant = interface;
  IAqDBSQLBooleanConstant = interface;
  IAqDBSQLGUIDConstant = interface;

  IAqDBSQLComposedConditionDescriptor = interface;
  IAqDBSQLSimpleComparisonDescriptor = interface;
  IAqDBSQLLikeDescriptor = interface;
  IAqDBSQLBetweenDescriptor = interface;
  IAqDBSQLInDescriptor = interface;
  IAqDBSQLIsNullDescriptor = interface;
  IAqDBSQLIsNotNullDescriptor = interface;

  IAqDBSQLJoin = interface;
  IAqDBSQLJoinWithComposedCondition = interface;
  IAqDBSQLJoinWithCustomCondition = interface;

  IAqDBSQLSource = interface;
  IAqDBSQLTable = interface;
  IAqDBSQLSelect = interface;

  IAqDBSQLCommand = interface;
  IAqDBSQLInsert = interface;
  IAqDBSQLUpdate = interface;
  IAqDBSQLDelete = interface;

  IAqDBSQLAliasable = interface
    ['{E4657747-4933-46BB-97E9-D1883CC710B5}']
    function GetAlias: string;
    function GetIsAliasDefined: Boolean;

    procedure SetAlias(const pAlias: string);

    property Alias: string read GetAlias;
    property IsAliasDefined: Boolean read GetIsAliasDefined;
  end;

  IAqDBSQLValue = interface(IAqDBSQLAliasable)
    ['{FC32DA9C-6B27-45F2-B532-6804FA4AA455}']

    function GetAggregator: TAqDBSQLAggregatorType;

    function GetValueType: TAqDBSQLValueType;
    function GetAsColumn: IAqDBSQLColumn;
    function GetAsOperation: IAqDBSQLOperation;
    function GetAsSubselect: IAqDBSQLSubselect;
    function GetAsConstant: IAqDBSQLConstant;
    function GetAsParameter: IAqDBSQLParameter;

    property ValueType: TAqDBSQLValueType read GetValueType;
    property Aggregator: TAqDBSQLAggregatorType read GetAggregator;
  end;

  IAqDBSQLColumn = interface(IAqDBSQLValue)
    ['{AEE2619F-6157-45C8-B758-AEB3EE523453}']
    function GetExpression: string;
    function GetIsSourceDefined: Boolean;
    function GetSource: IAqDBSQLSource;
    function GetDefaultValue: String;
    function SetDefaultValue(const pValor: String): IAqDBSQLColumn;

    property Expression: string read GetExpression;
    property IsSourceDefined: Boolean read GetIsSourceDefined;
    property Source: IAqDBSQLSource read GetSource;
    property DefaultValue: String read GetDefaultValue;
  end;

  IAqDBSQLOperation = interface(IAqDBSQLValue)
    ['{ADB54B9E-124B-4FBE-9343-9DB8D79B687E}']
    function GetLeftOperand: IAqDBSQLValue;
    function GetOperator: TAqDBSQLOperator;
    function GetRightOperand: IAqDBSQLValue;

    property LeftOperand: IAqDBSQLValue read GetLeftOperand;
    property Operator: TAqDBSQLOperator read GetOperator;
    property RightOperand: IAqDBSQLValue read GetRightOperand;
  end;

  // pode ser que este conjunto de classes seja desnecessário
  IAqDBSQLConstant = interface(IAqDBSQLValue)
    ['{D285A005-1E04-4195-8812-61A608469947}']
    function GetConstantType: TAqDBSQLConstantValueType;

    property ConstantType: TAqDBSQLConstantValueType read GetConstantType;

    function GetAsTextConstant: IAqDBSQLTextConstant;
    function GetAsIntConstant: IAqDBSQLIntConstant;
    function GetAsDoubleConstant: IAqDBSQLDoubleConstant;
    function GetAsCurrencyConstant: IAqDBSQLCurrencyConstant;
    function GetAsDateTimeConstant: IAqDBSQLDateTimeConstant;
    function GetAsDateConstant: IAqDBSQLDateConstant;
    function GetAsTimeConstant: IAqDBSQLTimeConstant;
    function GetAsBooleanConstant: IAqDBSQLBooleanConstant;
    function GetAsUIntConstant: IAqDBSQLUIntConstant;
    function GetAsGUIDConstant: IAqDBSQLGUIDConstant;
  end;

  IAqDBSQLTextConstant = interface(IAqDBSQLConstant)
    ['{F6994A33-3466-45C2-A3A1-18F5FEC8A085}']

    function GetValue: string;
    procedure SetValue(const pValue: string);

    property Value: string read GetValue write SetValue;
  end;

  IAqDBSQLIntConstant = interface(IAqDBSQLConstant)
    ['{295A5BBB-BBF1-4116-AF2D-065AB1ACB319}']

    function GetValue: Int64;
    procedure SetValue(const pValue: Int64);

    property Value: Int64 read GetValue write SetValue;
  end;

  IAqDBSQLUIntConstant = interface(IAqDBSQLConstant)
    ['{B70B8502-A9E6-4785-98A6-B8E7884DD72A}']

    function GetValue: UInt64;
    procedure SetValue(const pValue: UInt64);

    property Value: UInt64 read GetValue write SetValue;
  end;

  IAqDBSQLDoubleConstant = interface(IAqDBSQLConstant)
    ['{5A58062E-E2D2-4D01-A766-6C1D8B5D67FF}']

    function GetValue: Double;
    procedure SetValue(const pValue: Double);

    property Value: Double read GetValue write SetValue;
  end;

  IAqDBSQLCurrencyConstant = interface(IAqDBSQLConstant)
    ['{C67AD516-8976-45C0-8201-0D46787E5DCA}']

    function GetValue: Currency;
    procedure SetValue(const pValue: Currency);

    property Value: Currency read GetValue write SetValue;
  end;

  IAqDBSQLDateTimeConstant = interface(IAqDBSQLConstant)
    ['{B86A810B-2C1B-4CE5-99B5-BC7A1CDA7A7F}']

    function GetValue: TDateTime;
    procedure SetValue(const pValue: TDateTime);

    property Value: TDateTime read GetValue write SetValue;
  end;

  IAqDBSQLDateConstant = interface(IAqDBSQLConstant)
    ['{6FCC3B86-E7D0-4B29-B1B5-F2B2617EC687}']

    function GetValue: TDate;
    procedure SetValue(const pValue: TDate);

    property Value: TDate read GetValue write SetValue;
  end;

  IAqDBSQLTimeConstant = interface(IAqDBSQLConstant)
    ['{E01C3405-6619-45DB-969D-26C564AE2636}']

    function GetValue: TTime;
    procedure SetValue(const pValue: TTime);

    property Value: TTime read GetValue write SetValue;
  end;

  IAqDBSQLBooleanConstant = interface(IAqDBSQLConstant)
    ['{920397AF-DBFE-4AA1-B304-9FF3CAD61ED0}']

    function GetValue: Boolean;
    procedure SetValue(const pValue: Boolean);

    property Value: Boolean read GetValue write SetValue;
  end;

  IAqDBSQLGUIDConstant = interface(IAqDBSQLConstant)
    ['{85AD6162-B8BF-412F-93E4-446194106044}']

    function GetValue: TGUID;
    procedure SetValue(const pValue: TGUID);

    property Value: TGUID read GetValue write SetValue;
  end;

  IAqDBSQLSubselect = interface(IAqDBSQLValue)
    ['{77EB53C3-9B6F-4D3A-9FDD-758564209645}']
    function GetSelect: IAqDBSQLSelect;

    property Select: IAqDBSQLSelect read GetSelect;
  end;

  IAqDBSQLParameter = interface(IAqDBSQLValue)
    ['{B38B76A6-74EF-466F-92C9-0664CC5C6AEA}']
    function GetName: string;

    property Name: string read GetName;
  end;

  IAqDBSQLSource = interface(IAqDBSQLAliasable)
    ['{8890C50B-B2ED-4F5C-986E-6CE217DF639C}']
    function GetSourceType: TAqDBSQLSourceType;

    function GetAsTable: IAqDBSQLTable;
    function GetAsSelect: IAqDBSQLSelect;

    property SourceType: TAqDBSQLSourceType read GetSourceType;
  end;

  IAqDBSQLTable = interface(IAqDBSQLSource)
    ['{52EB5137-5D3E-4B2E-8CC1-556F63933205}']
    function GetName: string;

    property Name: string read GetName;
  end;

  IAqDBSQLCondition = interface
    ['{29E8EE3A-8CF5-404F-8A23-F2BEAB43F79D}']

    function VerifyIfIsNegated: Boolean;
    function GetConditionType: TAqDBSQLConditionType;

    function GetAsComparison: IAqDBSQLComparisonCondition;
    function GetAsValueIsNull: IAqDBSQLValueIsNullCondition;
    function GetAsComposed: IAqDBSQLComposedCondition;
    function GetAsLike: IAqDBSQLLikeCondition;
    function GetAsBetween: IAqDBSQLBetweenCondition;
    function GetAsIn: IAqDBSQLInCondition;
    function GetAsExists: IAqDBSQLExistsCondition;

    function Negate: IAqDBSQLCondition;

    property ConditionType: TAqDBSQLConditionType read GetConditionType;
    property IsNegated: Boolean read VerifyIfIsNegated;
  end;

  IAqDBSQLComparisonCondition = interface(IAqDBSQLCondition)
    ['{2448EC86-D178-422B-B283-7F677AD1CE95}']

    function GetLeftValue: IAqDBSQLValue;
    function GetComparison: TAqDBSQLComparison;
    function GetRightValue: IAqDBSQLValue;

    procedure SetLeftValue(pValue: IAqDBSQLValue);
    procedure SetRightValue(pValue: IAqDBSQLValue);
    procedure SetComparison(const pComparison: TAqDBSQLComparison);

    property LeftValue: IAqDBSQLValue read GetLeftValue write SetLeftValue;
    property Comparison: TAqDBSQLComparison read GetComparison write SetComparison;
    property RightValue: IAqDBSQLValue read GetRightValue write SetRightValue;
  end;

  IAqDBSQLLikeCondition = interface(IAqDBSQLCondition)
    ['{7D45BD3A-8A54-4516-A3EB-AB63392BD624}']

    function GetLeftValue: IAqDBSQLValue;
    function GetRightValue: IAqDBSQLTextConstant;
    function GetLeftWildCard: TAqDBSQLLikeWildCard;
    function GetRightWildCard: TAqDBSQLLikeWildCard;

    procedure SetLeftValue(pValue: IAqDBSQLValue);
    procedure SetRightValue(pValue: IAqDBSQLTextConstant);
    procedure SetLeftWildCard(pValue: TAqDBSQLLikeWildCard);
    procedure SetRightWildCard(pValue: TAqDBSQLLikeWildCard);

    property LeftValue: IAqDBSQLValue read GetLeftValue write SetLeftValue;
    property RightValue: IAqDBSQLTextConstant read GetRightValue write SetRightValue;
    property LeftWildCard: TAqDBSQLLikeWildCard read GetLeftWildCard write SetLeftWildCard;
    property RightWildCard: TAqDBSQLLikeWildCard read GetRightWildCard write SetRightWildCard;
  end;

  IAqDBSQLInCondition = interface(IAqDBSQLCondition)
    ['{FCF291F9-6FD0-4614-9823-5AEEB257CDCE}']

    function GetTestableValue: IAqDBSQLValue;
    function GetInValues: IAqReadableList<IAqDBSQLValue>;

    procedure SetTestableValue(pValue: IAqDBSQLValue);
    procedure AddInValue(pValue: IAqDBSQLValue);

    property TestableValue: IAqDBSQLValue read GetTestableValue write SetTestableValue;
    property InValues: IAqReadableList<IAqDBSQLValue> read GetInValues;
  end;

  IAqDBSQLExistsCondition = interface(IAqDBSQLCondition)
    ['{09F76451-6F68-4D60-A5A0-312B8401D943}']

    function GetSelect: IAqDBSQLSelect;

    property Select: IAqDBSQLSelect read GetSelect;
  end;

  IAqDBSQLValueIsNullCondition = interface(IAqDBSQLCondition)
    ['{095FEB07-4D62-48EE-AAD2-839BB91101FB}']

    function GetValue: IAqDBSQLValue;

    property Value: IAqDBSQLValue read GetValue;
  end;

  IAqDBSQLComposedCondition = interface(IAqDBSQLCondition)
    ['{3FF25D29-ECDF-4C9C-8C1A-23E4EE52CF65}']

    function GetConditions: IAqReadableList<IAqDBSQLCondition>;
    function GetLinkOperators: IAqReadableList<TAqDBSQLBooleanOperator>;
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

    {TODO 3 -oTatu -cMelhoria: Criar métodos para sintaxe fluente com not equal}

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

    property Conditions: IAqReadableList<IAqDBSQLCondition> read GetConditions;
    property LinkOperators: IAqReadableList<TAqDBSQLBooleanOperator> read GetLinkOperators;
    property IsInitialized: Boolean read GetIsInitialized;
  end;

  IAqDBSQLBetweenCondition = interface(IAqDBSQLCondition)
    function GetValue: IAqDBSQLValue;
    function GetLeftBoundary: IAqDBSQLValue;
    function GetRightBoundary: IAqDBSQLValue;

    property Value: IAqDBSQLValue read GetValue;
    property LeftBoundary: IAqDBSQLValue read GetLeftBoundary;
    property RightBoundary: IAqDBSQLValue read GetRightBoundary;
  end;

  IAqDBSQLJoin = interface
    ['{A39F1E2D-A0B9-487B-816C-5C2E4738D162}']
    function GetSource: IAqDBSQLSource;
    function GetJoinType: TAqDBSQLJoinType;
    function GetConditionType: TAqDBSQLJoinConditionType;
    function GetHasPreviousJoin: Boolean;
    function GetPreviousJoin: IAqDBSQLJoin;
    function GetIdentifier: string;

    function GetAsJoinWithComposedCondition: IAqDBSQLJoinWithComposedCondition;
    function GetAsJoinWithCustomCondition: IAqDBSQLJoinWithCustomCondition;

    procedure UpdateJoinTypeWithHighestPriority(const pJoinType: TAqDBSQLJoinType);

    property JoinType: TAqDBSQLJoinType read GetJoinType;
    property ConditionType: TAqDBSQLJoinConditionType read GetConditionType;
    property Source: IAqDBSQLSource read GetSource;
    property HasPreviousJoin: Boolean read GetHasPreviousJoin;
    property PreviousJoin: IAqDBSQLJoin read GetPreviousJoin;
    property Identifier: string read GetIdentifier;
  end;

  IAqDBSQLJoinWithComposedCondition = interface(IAqDBSQLJoin)
    ['{BF4441B2-95F6-4894-B750-672854DBA6F2}']

    function GetCondition: IAqDBSQLCondition;

    function &On(const pColumnName: string): IAqDBSQLJoinWithComposedCondition;
    function EqualsTo(pValue: IAqDBSQLValue): IAqDBSQLJoinWithComposedCondition; overload;
    function EqualsTo(const pColumnName: string): IAqDBSQLJoinWithComposedCondition; overload;

    property Condition: IAqDBSQLCondition read GetCondition;
  end;

  IAqDBSQLJoinWithCustomCondition = interface(IAqDBSQLJoin)
    ['{B3BC588C-7C24-4B65-8D3C-5E99FFC276D1}']

    function GetCustomCondition: string;

    property CustomCondition: string read GetCustomCondition;
  end;

  IAqDBSQLOrderByItem = interface
    ['{CBBDA2D1-FF3B-4C65-942A-D030AE76A572}']
    function GetValue: IAqDBSQLValue;
    function GetIsAscending: Boolean;

    property Value: IAqDBSQLValue read GetValue;
    property Ascending: Boolean read GetIsAscending;
  end;

  IAqDBSQLConditionDescriptor = interface
    ['{250DBFFA-35B7-4A49-AA27-D91D66540E9D}']

    function GetConditionDescriptorType: TAqDBSQLConditionDescriptorType;
    function GetAsComposedConditionDescriptor: IAqDBSQLComposedConditionDescriptor;
    function GetAsSimpleComparisonDescriptor: IAqDBSQLSimpleComparisonDescriptor;
    function GetAsLikeDescriptor: IAqDBSQLLikeDescriptor;
    function GetAsBetweenDescriptor: IAqDBSQLBetweenDescriptor;
    function GetAsInDescriptor: IAqDBSQLInDescriptor;
    function GetAsIsNullDescriptor: IAqDBSQLIsNullDescriptor;
    function GetAsIsNotNullDescriptor: IAqDBSQLIsNotNullDescriptor;

    function VerifyIfIsNegated: Boolean;
    function Negate: IAqDBSQLConditionDescriptor;

    property ConditionDescriptorType: TAqDBSQLConditionDescriptorType read GetConditionDescriptorType;
    property IsNegated: Boolean read VerifyIfIsNegated;
  end;

  IAqDBSQLComposedConditionDescriptor = interface(IAqDBSQLConditionDescriptor)
    ['{8B034557-AC4D-451E-9EEB-84E9184B71F4}']

    function GetCount: Int32;
    function GetItem(const pIndex: Int32): IAqDBSQLConditionDescriptor;
    function GetLinkOperator(const pIndex: Int32): TAqDBSQLBooleanOperator;

    {TODO: criar mais métodos para simplificar a entrada desses parâmetros, ao estilo AndColumnEqual, AndColumnGreaterThan, OrColumnEqual}
    {TODO: criar também sobrecargas que recebam constantes como entrada dos valores}
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

    property Count: Int32 read GetCount;
    property Items[const pIndex: Int32]: IAqDBSQLConditionDescriptor read GetItem; default;
    property LinkOperators[const pIndex: Int32]: TAqDBSQLBooleanOperator read GetLinkOperator;
  end;

  IAqDBSQLColumnBasedConditionDescriptor = interface(IAqDBSQLConditionDescriptor)
    ['{395E544B-FDFF-47EB-AC18-C1FB5D2F9518}']

    function GetColumnName: string;
    function VerifyIfHasSourceIdentifier: Boolean;
    function GetSourceIdentifier: string;
    procedure SetSourceIdentifier(const pValue: string);
    procedure ClearSourceIdentifier;

    property ColumnName: string read GetColumnName;
    property HasSourceIdentifier: Boolean read VerifyIfHasSourceIdentifier;
    property SourceIdentifier: string read GetSourceIdentifier write SetSourceIdentifier;
  end;

  IAqDBSQLSimpleComparisonDescriptor = interface(IAqDBSQLColumnBasedConditionDescriptor)
    ['{2315D81A-A8B7-4259-BD2D-6BCF1ABBEA7C}']

    function GetComparison: TAqDBSQLComparison;
    function GetComparisonValue: IAqDBSQLValue;

    property Comparison: TAqDBSQLComparison read GetComparison;
    property ComparisonValue: IAqDBSQLValue read GetComparisonValue;
  end;

  IAqDBSQLLikeDescriptor = interface(IAqDBSQLColumnBasedConditionDescriptor)
    ['{F20BC556-A260-42F3-83F2-A0AF632D1AD5}']

    function GetLikeValue: IAqDBSQLTextConstant;

    property LikeValue: IAqDBSQLTextConstant read GetLikeValue;
  end;

  IAqDBSQLBetweenDescriptor = interface(IAqDBSQLColumnBasedConditionDescriptor)
    ['{15F8337B-6D42-401C-897D-BA3E9CC2EC54}']

    function GetLeftBoundaryValue: IAqDBSQLConstant;
    function GetRightBoundaryValue: IAqDBSQLConstant;

    property LeftBoundaryValue: IAqDBSQLConstant read GetLeftBoundaryValue;
    property RightBoundaryValue: IAqDBSQLConstant read GetRightBoundaryValue;
  end;

  IAqDBSQLInDescriptor = interface(IAqDBSQLColumnBasedConditionDescriptor)
    ['{59243A55-7933-46E8-B9FA-18B202EA6832}']

    function GetInValues: IAqReadableList<IAqDBSQLConstant>;
    procedure AddInValue(pValue: IAqDBSQLConstant);

    property InValues: IAqReadableList<IAqDBSQLConstant> read GetInValues;
  end;

  IAqDBSQLIsNullDescriptor = interface(IAqDBSQLColumnBasedConditionDescriptor)
    ['{02EE7989-EA01-4EBB-BB41-C350C21B020F}']
  end;

  IAqDBSQLIsNotNullDescriptor = interface(IAqDBSQLColumnBasedConditionDescriptor)
    ['{CEB70C07-49BC-4CE5-80AB-7483BB3B649B}']
  end;

  IAqDBSQLJoinParameters = interface
    ['{24F72250-8128-4E50-9A1D-B2F5573D7A3E}']

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

    property MainSourceJoin: IAqDBSQLJoinParameters read GetMainSourceJoin;
    property HasCustomCondition: Boolean read VerifyIfHasCustomCondition;
    property CustomCondition: string read GetCustomCondition;
    property MainColumns: TStrings read GetMainColumns;
    property JoinTable: string read GetJoinTable;
    property JoinTableAlias: string read GetJoinTableAlias;

    property JoinColumns: TStrings read GetJoinColumns;

    property Identifier: string read GetIdentifier;

    property JoinType: TAqDBSQLJoinType read GetJoinType;
  end;

  IAqDBSQLOrderByDescriptor = interface
    ['{EBE10923-E6A5-4D0B-9E9E-8599AD1B9C96}']

    function VerifyIfHasSourceIdentifier: Boolean;
    function GetSourceIdentifier: string;
    function GetColumnName: string;
    function GetIsAscending: Boolean;
    function GetColumnShouldBeReturnedAsResult: Boolean;
    function GetGeneratedColumn: IAqDBSQLColumn;
    procedure SetGeneratedColumn(pColumn: IAqDBSQLColumn);

    property HasSourceIdentifier: Boolean read VerifyIfHasSourceIdentifier;
    property SourceIdentifier: string read GetSourceIdentifier;
    property ColumnName: string read GetColumnName;
    property Ascending: Boolean read GetIsAscending;
    property ColumnShouldBeReturnedAsResult: Boolean read GetColumnShouldBeReturnedAsResult;
    property GeneratedColumm: IAqDBSQLColumn read GetGeneratedColumn;
  end;

  IAqDBSQLSelectSetup = interface
    ['{9CC87F0D-8C33-4DCB-8511-41A48CC14505}']

    function GetIsCustomConditionDefied: Boolean;
    function GetCustomCondition: IAqDBSQLComposedCondition;

    function GetHasJoinsParameters: Boolean;
    function GetJoinsParameters: IAqReadableList<IAqDBSQLJoinParameters>;

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

    function GetIsDistinguished: Boolean;
    function Distinct: IAqDBSQLSelectSetup;

    property IsCustomConditionDefied: Boolean read GetIsCustomConditionDefied;
    property CustomCondition: IAqDBSQLComposedCondition read GetCustomCondition;
    property HasJoinsParameters: Boolean read GetHasJoinsParameters;
    property JoinsParameters: IAqReadableList<IAqDBSQLJoinParameters> read GetJoinsParameters;
    property HasConditionDescriptors: Boolean read GetHasConditionDescriptors;
    property ConditionDescriptors: IAqDBSQLComposedConditionDescriptor read GetConditionDescriptors;
    property HasOrderBy: Boolean read GetHasOrderby;
    property OrderByList: IAqReadableList<IAqDBSQLOrderByDescriptor> read GetOrderByList;
    property IsDistinguished: Boolean read GetIsDistinguished;
  end;

  IAqDBSQLSelect = interface(IAqDBSQLSource)
    ['{05EED8D5-FD87-4157-89D8-F295B921FC4E}']
    function GetColumns: IAqReadableList<IAqDBSQLValue>;
    function GetColumnByExpression(const pExpression: string): IAqDBSQLColumn;
    function GetSource: IAqDBSQLSource;

    function GetHasJoins: Boolean;
    function GetJoins: IAqReadableList<IAqDBSQLJoin>;

    function GetIsConditionDefined: Boolean;
    function GetCondition: IAqDBSQLCondition;
    procedure SetCondition(pValue: IAqDBSQLCondition);
    function CustomizeCondition(pNewCondition: IAqDBSQLCondition = nil): IAqDBSQLComposedCondition;

    function GetIsLimitDefined: Boolean;
    function GetLimit: UInt32;
    procedure SetLimit(const pValue: UInt32);
    procedure ClearLimit;

    function GetIsOffsetDefined: Boolean;
    function GetOffset: UInt32;
    procedure SetOffset(const pValue: UInt32);
    procedure ClearOffset;

    function GetIsDistinguished: Boolean;
    function Distinct: IAqDBSQLSelect;

    function GetIsGroupByDefined: Boolean;
    function GetGroupBy: IAqReadableList<IAqDBSQLValue>;
    function AddGroupBy(pValue: IAqDBSQLValue): Int32; overload;
    function AddGroupBy(pExpression: string): Int32; overload;
    function AddGroupBy(pExpression: string; pSource: IAqDBSQLSource): Int32; overload;

    function GetIsOrderByDefined: Boolean;
    function GetOrderBy: IAqReadableList<IAqDBSQLOrderByItem>;
    function AddOrderBy(pValue: IAqDBSQLValue; const pAscending: Boolean = True): Int32; overload;
    function AddOrderBy(const pColumnName: string; const pAscending: Boolean = True): Int32; overload;

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

    procedure Encapsulate;

    property Columns: IAqReadableList<IAqDBSQLValue> read GetColumns;
    property Source: IAqDBSQLSource read GetSource;

    property HasJoins: Boolean read GetHasJoins;
    property Joins: IAqReadableList<IAqDBSQLJoin> read GetJoins;

    property IsConditionDefined: Boolean read GetIsConditionDefined;
    property Condition: IAqDBSQLCondition read GetCondition write SetCondition;

    property IsLimitDefined: Boolean read GetIsLimitDefined;
    property Limit: UInt32 read GetLimit write SetLimit;

    property IsOffsetDefined: Boolean read GetIsOffsetDefined;
    property Offset: UInt32 read GetOffset write SetOffset;

    property IsOrderByDefined: Boolean read GetIsOrderByDefined;
    property OrderBy: IAqReadableList<IAqDBSQLOrderByItem> read GetOrderBy;

    property IsGroupByDefined: Boolean read GetIsGroupByDefined;
    property GroupBy: IAqReadableList<IAqDBSQLValue> read GetGroupBy;

    property IsDistinguished: Boolean read GetIsDistinguished;
  end;

  IAqDBSQLAssignment = interface
    ['{714E4AA7-EE36-476D-BFFF-6CEAF20C1B89}']

    function GetColumn: IAqDBSQLColumn;
    function GetValue: IAqDBSQLValue;

    property Column: IAqDBSQLColumn read GetColumn;
    property Value: IAqDBSQLValue read GetValue;
  end;

  IAqDBSQLCommand = interface
    ['{B9C3C25D-A47B-4FF3-AF08-88FAF40B37A7}']
    function GetCommandType: TAqDBSQLCommandType;

    function GetAsSelect: IAqDBSQLSelect;
    function GetAsInsert: IAqDBSQLInsert;
    function GetAsUpdate: IAqDBSQLUpdate;
    function GetAsDelete: IAqDBSQLDelete;

    property CommandType: TAqDBSQLCommandType read GetCommandType;
  end;

  IAqDBSQLInsert = interface(IAqDBSQLCommand)
    ['{A8E24816-1545-4291-B598-FC7872CBB6B7}']

    function GetTable: IAqDBSQLTable;
    function GetAssignments: IAqReadableList<IAqDBSQLAssignment>;

    function AddAssignment(pAssignment: IAqDBSQLAssignment): Int32; overload;
    function AddAssignment(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue): IAqDBSQLAssignment; overload;

    property Table: IAqDBSQLTable read GetTable;
    property Assignments: IAqReadableList<IAqDBSQLAssignment> read GetAssignments;
  end;

  IAqDBSQLUpdate = interface(IAqDBSQLCommand)
    ['{A8E24816-1545-4291-B598-FC7872CBB6B7}']

    function GetTable: IAqDBSQLTable;
    function GetAssignments: IAqReadableList<IAqDBSQLAssignment>;

    function GetIsConditionDefined: Boolean;
    function GetCondition: IAqDBSQLCondition;
    procedure SetCondition(pValue: IAqDBSQLCondition);

    function AddAssignment(pAssignment: IAqDBSQLAssignment): Int32; overload;
    function AddAssignment(pColumn: IAqDBSQLColumn; pValue: IAqDBSQLValue): IAqDBSQLAssignment; overload;

    function CustomizeCondition(pNewCondition: IAqDBSQLCondition = nil): IAqDBSQLComposedCondition;

    property Table: IAqDBSQLTable read GetTable;
    property Assignments: IAqReadableList<IAqDBSQLAssignment> read GetAssignments;
    property IsConditionDefined: Boolean read GetIsConditionDefined;
    property Condition: IAqDBSQLCondition read GetCondition write SetCondition;
  end;

  IAqDBSQLDelete = interface(IAqDBSQLCommand)
    ['{5CECF01F-FF67-43C6-895E-93E224150D71}']

    function GetTable: IAqDBSQLTable;

    function GetIsConditionDefined: Boolean;
    function GetCondition: IAqDBSQLCondition;
    procedure SetCondition(pValue: IAqDBSQLCondition);

    function CustomizeCondition(pNewCondition: IAqDBSQLCondition = nil): IAqDBSQLComposedCondition;

    property Table: IAqDBSQLTable read GetTable;

    property IsConditionDefined: Boolean read GetIsConditionDefined;
    property Condition: IAqDBSQLCondition read GetCondition write SetCondition;
  end;

implementation

end.
