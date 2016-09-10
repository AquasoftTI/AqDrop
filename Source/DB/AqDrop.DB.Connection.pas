unit AqDrop.DB.Connection;

interface

uses
  System.Classes,
  System.SyncObjs,
  AqDrop.Core.Manager,
  AqDrop.DB.SQL.Intf,
  AqDrop.Core.AnonymousMethods,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Collections,
  AqDrop.DB.Types,
  AqDrop.DB.SQL;

type
  TAqDBAutoIncrementType = (aiAutoIncrement, aiGenerator);

  TAqDBMapper = class
  strict protected
    function SolveOperator(const pOperator: TAqDBSQLOperator): string; virtual;
    function SolveDisambiguation(pColumn: IAqDBSQLColumn): string; virtual;
    function SolveAlias(pAliasable: IAqDBSQLAliasable): string; virtual;
    function SolveAggregator(pValue: IAqDBSQLValue): string; virtual;
    function SolveValue(pValue: IAqDBSQLValue; const pUseAlias: Boolean): string; virtual;
    function SolveValueType(pValue: IAqDBSQLValue): string; virtual;
    function SolveColumn(pColumn: IAqDBSQLColumn): string; virtual;
    function SolveOperation(pOperation: IAqDBSQLOperation): string; virtual;
    function SolveSubselectValue(pColumn: IAqDBSQLSubselect): string; virtual;
    function SolveConstant(pConstant: IAqDBSQLConstant): string; virtual;
    function SolveParameter(pParameter: IAqDBSQLParameter): string; virtual;
    function SolveTextConstant(pConstant: IAqDBSQLTextConstant): string; virtual;
    function SolveNumericConstant(pConstant: IAqDBSQLNumericConstant): string; virtual;
    function SolveDateTimeConstant(pConstant: IAqDBSQLDateTimeConstant): string; virtual;
    function SolveDateConstant(pConstant: IAqDBSQLDateConstant): string; virtual;
    function SolveTimeConstant(pConstant: IAqDBSQLTimeConstant): string; virtual;
    function SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string; virtual;
    function SolveColumns(pColumnsList: IAqReadList<IAqDBSQLValue>): string; virtual;
    function SolveSource(pSource: IAqDBSQLSource): string; virtual;
    function SolveFrom(pSource: IAqDBSQLSource): string; virtual;
    function SolveTable(pTable: IAqDBSQLTable): string; virtual;
    function SolveSubselect(pSelect: IAqDBSQLSelect): string; virtual;
    function SolveSelectBody(pSelect: IAqDBSQLSelect): string; virtual;
    function SolveJoins(pSelect: IAqDBSQLSelect): string; virtual;
    function SolveJoin(pJoin: IAqDBSQLJoin): string; virtual;
    function SolveCondition(pCondition: IAqDBSQLCondition): string; virtual;
    function SolveOrderBy(pSelect: IAqDBSQLSelect): string; virtual;
    function SolveLimit(pSelect: IAqDBSQLSelect): string; virtual;
    function SolveComparisonCondition(pComparisonCondition: IAqDBSQLComparisonCondition): string; virtual;
    function SolveValueIsNullCondition(pValueIsNullCondition: IAqDBSQLValueIsNullCondition): string; virtual;
    function SolveComposedCondition(pComposedCondition: IAqDBSQLComposedCondition): string; virtual;
    function SolveBetweenCondition(pBetweenCondition: IAqDBSQLBetweenCondition): string; virtual;
    function SolveComparison(const pComparison: TAqDBSQLComparison): string; virtual;
    function SolveBooleanOperator(const pBooleanOperator: TAqDBSQLBooleanOperator): string; virtual;
  public
    function SolveSelect(pSelect: IAqDBSQLSelect): string; virtual;
    function SolveInsert(pInsert: IAqDBSQLInsert): string; virtual;
    function SolveUpdate(pUpdate: IAqDBSQLUpdate): string; virtual;
    function SolveDelete(pDelete: IAqDBSQLDelete): string; virtual;
    function SolveCommand(pCommand: IAqDBSQLCommand): string; virtual;

    function GetGeneratorName(const pTableName: string): string; virtual;
  end;

  TAqDBConnectionClass = class of TAqDBConnection;
  TAqDBMapperClass = class of TAqDBMapper;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Abstract class for connections with SGBDs.
  ///   PT-BR:
  ///     Classe abstrata base para conexões com SGBDs.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqDBConnection = class abstract(TAqManager<TObject>)
  strict private
    FMapper: TAqDBMapper;

    procedure CheckConnectionActive;

    function PrepareCommand(const pPreparingFunction: TAqAnonymousFunction<TAqID>): TAqID; overload;
    function OpenQuery(const pOpeningFunction: TAqAnonymousFunction<IAqDBReader>): IAqDBReader; overload;
    function ExecuteCommand(const pExecutionFunction: TAqAnonymousFunction<Int64>): Int64; overload;

    class var FConnections: TAqList<TAqDBConnection>;
  strict protected
    procedure DoStartTransaction; virtual; abstract;
    procedure DoCommitTransaction; virtual; abstract;
    procedure DoRollbackTransaction; virtual; abstract;

    function DoPrepareCommand(const pSQL: string): TAqID; overload; virtual; abstract;
    function DoPrepareCommand(const pSQLCommand: IAqDBSQLCommand): TAqID; overload; virtual;

    procedure DoUnprepareCommand(const pCommandID: TAqID); virtual; abstract;

    function DoExecuteCommand(const pSQL: string;
      const pParametersHandler: TAqDBParametersHandlerMethod): Int64; overload; virtual; abstract;
    function DoExecuteCommand(const pSQLCommand: IAqDBSQLCommand;
      const pParametersHandler: TAqDBParametersHandlerMethod): Int64; overload; virtual;
    function DoExecuteCommand(const pCommandID: TAqID;
      const pParametersHandler: TAqDBParametersHandlerMethod): Int64; overload; virtual; abstract;

    function DoOpenQuery(const pSQL: string;
      const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader; overload; virtual; abstract;
    function DoOpenQuery(const pSQLCommand: IAqDBSQLSelect;
      const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader; overload; virtual;
    function DoOpenQuery(const pCommandID: TAqID;
      const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader; overload; virtual; abstract;

    function GetActive: Boolean; virtual; abstract;
    procedure SetActive(const pValue: Boolean); virtual;
    function GetInTransaction: Boolean; virtual; abstract;

    function GetAutoIncrementType: TAqDBAutoIncrementType; virtual;

    procedure DoConnect; virtual; abstract;
    procedure DoDisconnect; virtual; abstract;

    class function GetDefaultMapper: TAqDBMapperClass; virtual;
  protected
    procedure SetMapper(const pMapper: TAqDBMapper); virtual;
  public
    class constructor Create;
    class destructor Destroy;

    /// <summary>
    ///   EN-US:
    ///     Class copnstructor.
    ///   PT-BR:
    ///     Construtor da classe.
    /// </summary>
    constructor Create; virtual;
    /// <summary>
    ///   EN-US:
    ///     Class destructor.
    ///   PT-BR:
    ///     Destrutor da classe.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   EN-US:
    ///     Opens the connection.
    ///   PT-BR:
    ///     Abre a conexão.
    /// </summary>
    procedure Connect; virtual;
    /// <summary>
    ///   EN-US:
    ///     Closes the connection.
    ///   PT-BR:
    ///     Fecha a conexão.
    /// </summary>
    procedure Disconnect; virtual;

    procedure StartTransaction; virtual;
    procedure CommitTransaction; virtual;
    procedure RollbackTransaction; virtual;

    function PrepareCommand(const pSQL: string): TAqID; overload; virtual;
    function PrepareCommand(const pSQLCommand: IAqDBSQLCommand): TAqID; overload; virtual;

    procedure UnprepareCommand(const pCommandID: TAqID); virtual;

    /// <summary>
    ///   EN-US:
    ///     Executes a command.
    ///   PT-BR:
    ///     Executa um comando.
    /// </summary>
    /// <param name="pSQL">
    ///   EN-US:
    ///     SQL instruction to be executed.
    ///   PT-BR:
    ///     Instrução SQL a ser executada.
    /// </param>
    /// <param name="pParametersHandler">
    ///   EN-US:
    ///     Anonymous method to handle the parameters values of the command.
    ///   PT-BR:
    ///     Método anônimo para escrita dos valores de entrada dos parâmetros.
    /// </param>
    /// <returns>
    ///   EN-US:
    ///     Returns the affected rows count.
    ///   PT-BR:
    ///     Retorna a quantidade de registros afetados.
    /// </returns>
    function ExecuteCommand(const pSQL: string;
      const pParametersHandler: TAqDBParametersHandlerMethod = nil): Int64; overload; virtual;
    function ExecuteCommand(const pSQLCommand: IAqDBSQLCommand;
      const pParametersHandler: TAqDBParametersHandlerMethod = nil): Int64; overload; virtual;
    function ExecuteCommand(const pCommandID: TAqID;
      const pParametersHandler: TAqDBParametersHandlerMethod = nil): Int64; overload; virtual;

    function OpenQuery(const pSQL: string;
      const pParametersHandler: TAqDBParametersHandlerMethod = nil): IAqDBReader; overload;
    function OpenQuery(const pSQLCommand: IAqDBSQLSelect;
      const pParametersHandler: TAqDBParametersHandlerMethod = nil): IAqDBReader; overload;
    function OpenQuery(const pCommandID: TAqID;
      const pParametersHandler: TAqDBParametersHandlerMethod = nil): IAqDBReader; overload;

    function GetAutoIncrement(const pGenerator: string = ''): Int64; virtual; abstract;

    property Mapper: TAqDBMapper read FMapper write SetMapper;
    property Active: Boolean read GetActive write SetActive;
    property InTransaction: Boolean read GetInTransaction;
    property AutoIncrementType: TAqDBAutoIncrementType read GetAutoIncrementType;
  end;

  TAqDBPooledConnection<TBaseConnection: TAqDBConnection> = class(TAqDBConnection)
  strict protected type
    TAqDBContext = class
    strict private
      FMasterConnection: TAqDBPooledConnection<TBaseConnection>;
      FLockerThread: TThreadID;
      FConnection: TBaseConnection;
      FPreparedQueries: TAqDictionary<TAqID, TAqID>;
      FCalls: UInt32;
      FLastUsedAt: TDateTime;

      function GetIsLocked: Boolean;
    public
      constructor Create(const pMasterConnections: TAqDBPooledConnection<TBaseConnection>;
        const pBaseConection: TBaseConnection);
      destructor Destroy; override;

      procedure LockConnection;
      procedure ReleaseConnection;

      function GetCommandID(const pMasterCommandID: TAqID): TAqID;

      property Connection: TBaseConnection read FConnection;
      property LockerThread: TThreadID read FLockerThread;
      property Locked: Boolean read GetIsLocked;
      property PreparedQueries: TAqDictionary<TAqID, TAqID> read FPreparedQueries;
      property LastUsedAt: TDateTime read FLastUsedAt;
    end;
  strict private type
    TAqDBFlushContextsThread = class(TThread)
    strict private
      FAutoFlushContextsTime: UInt32;
      FPool: TAqList<TAqDBContext>;

      procedure SetAutoFlushContextsTime(const pValue: UInt32);
    protected
      procedure Execute; override;
    public
      constructor Create(const pPool: TAqList<TAqDBContext>);

      property AutoFlushContextsTime: UInt32 read FAutoFlushContextsTime write SetAutoFlushContextsTime;
    end;
  strict private
    FPool: TAqList<TAqDBContext>;
    FConnectionBuilder: TAqAnonymousFunction<TBaseConnection>;
    FPreparedQueries: TAqIDDictionary<string>;
    FFlushContextsThread: TAqDBFlushContextsThread;

    procedure SolvePoolAndExecute(const pMethod: TAqMethodGenericParameter<TAqDBContext>);
    function GetActiveConnections: Int32;
    function GetAutoFlushContextsTime: UInt32;
    procedure SetAutoFlushContextsTime(const pValue: UInt32);
    procedure FreeFlushContextThread;
  strict protected
    procedure DoStartTransaction; override;
    procedure DoCommitTransaction; override;
    procedure DoRollbackTransaction; override;

    function DoPrepareCommand(const pSQL: string): TAqID; override;
    function DoPrepareCommand(const pSQLCommand: IAqDBSQLCommand): TAqID; override;

    procedure DoUnprepareCommand(const pCommandID: TAqID); override;

    function DoExecuteCommand(const pSQL: string;
      const pTratadorParametros: TAqDBParametersHandlerMethod): Int64; override;
    function DoExecuteCommand(const pSQLCommand: IAqDBSQLCommand;
      const pTratadorParametros: TAqDBParametersHandlerMethod): Int64; override;
    function DoExecuteCommand(const pCommandID: TAqID;
      const pTratadorParametros: TAqDBParametersHandlerMethod): Int64; override;

    function DoOpenQuery(const pSQL: string;
      const pTratadorParametros: TAqDBParametersHandlerMethod): IAqDBReader; override;
    function DoOpenQuery(const pSQLCommand: IAqDBSQLSelect;
      const pTratadorParametros: TAqDBParametersHandlerMethod): IAqDBReader; override;
    function DoOpenQuery(const pCommandID: TAqID;
      const pTratadorParametros: TAqDBParametersHandlerMethod): IAqDBReader; override;

    function GetActive: Boolean; override;

    function CreateNewContext: TAqDBContext; virtual;

    procedure DoConnect; override;
    procedure DoDisconnect; override;

    function GetInTransaction: Boolean; override;
    function GetAutoIncrementType: TAqDBAutoIncrementType; override;

    class function GetDefaultMapper: TAqDBMapperClass; override;
  protected
    procedure SetMapper(const pMapeador: TAqDBMapper); override;

    property PreparedQueries: TAqIDDictionary<string> read FPreparedQueries;
  public
    constructor Create(const pConnectionBuilder: TAqAnonymousFunction<TBaseConnection>); reintroduce;
    destructor Destroy; override;

    function GetAutoIncrement(const pGeneratorName: string = ''): Int64; override;

    property ActiveConnections: Int32 read GetActiveConnections;
    property AutoFlushContextsTime: UInt32 read GetAutoFlushContextsTime write SetAutoFlushContextsTime;
  end;

implementation

uses
  System.SysUtils,
  System.DateUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers;

{ TAqDBConnection }

function TAqDBConnection.OpenQuery(const pSQL: string;
  const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader;
begin
  Result := OpenQuery(
    function: IAqDBReader
    begin
      Result := DoOpenQuery(pSQL, pParametersHandler);
    end);
end;

procedure TAqDBConnection.CheckConnectionActive;
begin
  if not Active then
  begin
    raise EAqInternal.Create('Connection is not active.');
  end;
end;

function TAqDBConnection.OpenQuery(const pCommandID: TAqID;
  const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader;
begin
  Result := OpenQuery(
    function: IAqDBReader
    begin
      Result := DoOpenQuery(pCommandID, pParametersHandler);
    end);
end;

function TAqDBConnection.OpenQuery(const pSQLCommand: IAqDBSQLSelect;
  const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader;
begin
  Result := OpenQuery(
    function: IAqDBReader
    begin
      Result := DoOpenQuery(pSQLCommand, pParametersHandler);
    end);
end;

function TAqDBConnection.OpenQuery(const pOpeningFunction: TAqAnonymousFunction<IAqDBReader>): IAqDBReader;
begin
  try
    CheckConnectionActive;

    Result := pOpeningFunction;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to open the query.'));
    end;
  end;
end;

procedure TAqDBConnection.Connect;
begin
  if not Active then
  begin
    SetActive(True);
  end;
end;

procedure TAqDBConnection.StartTransaction;
begin
  try
    CheckConnectionActive;

    DoStartTransaction;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to start the transaction.'));
    end;
  end;
end;

procedure TAqDBConnection.CommitTransaction;
begin
  try
    CheckConnectionActive;

    DoCommitTransaction;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to commit the transaction.'));
    end;
  end;
end;

constructor TAqDBConnection.Create;
var
  lMapperClass: TAqDBMapperClass;
begin
  inherited;

  lMapperClass := GetDefaultMapper;

  if Assigned(lMapperClass) then
  begin
    SetMapper(lMapperClass.Create);
  end;

  FConnections.Add(Self);
end;

class constructor TAqDBConnection.Create;
begin
  FConnections := TAqList<TAqDBConnection>.Create
end;

procedure TAqDBConnection.Disconnect;
begin
  if Active then
  begin
    SetActive(False);
  end;
end;

procedure TAqDBConnection.UnprepareCommand(const pCommandID: TAqID);
begin
  DoUnprepareCommand(pCommandID);
end;

destructor TAqDBConnection.Destroy;
var
  lI: Int32;
begin
  FMapper.Free;

  lI := FConnections.IndexOf(Self);

  if lI >= 0 then
  begin
    FConnections.Delete(lI);
  end;

  inherited;
end;

function TAqDBConnection.ExecuteCommand(const pExecutionFunction: TAqAnonymousFunction<Int64>): Int64;
begin
  Result := 0;

  try
    CheckConnectionActive;

    Result := pExecutionFunction;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to execute the command.'));
    end;
  end;
end;

function TAqDBConnection.ExecuteCommand(const pSQL: string;
  const pParametersHandler: TAqDBParametersHandlerMethod): Int64;
begin
  Result := ExecuteCommand(
    function: Int64
    begin
      Result := DoExecuteCommand(pSQL, pParametersHandler);
    end);
end;

function TAqDBConnection.GetAutoIncrementType: TAqDBAutoIncrementType;
begin
  Result := TAqDBAutoIncrementType.aiAutoIncrement;
end;

class function TAqDBConnection.GetDefaultMapper: TAqDBMapperClass;
begin
  Result := TAqDBMapper;
end;

function TAqDBConnection.PrepareCommand(const pSQLCommand: IAqDBSQLCommand): TAqID;
begin
  Result := PrepareCommand(
    function: TAqID
    begin
      Result := DoPrepareCommand(pSQLCommand);
    end);
end;

function TAqDBConnection.PrepareCommand(const pPreparingFunction: TAqAnonymousFunction<TAqID>): TAqID;
begin
  Result := 0;

  try
    CheckConnectionActive;

    Result := pPreparingFunction;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to prepare the command.'));
    end;
  end;
end;

function TAqDBConnection.DoOpenQuery(const pSQLCommand: IAqDBSQLSelect;
  const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader;
begin
  Result := DoOpenQuery(FMapper.SolveSelect(pSQLCommand), pParametersHandler);
end;

function TAqDBConnection.DoExecuteCommand(const pSQLCommand: IAqDBSQLCommand;
  const pParametersHandler: TAqDBParametersHandlerMethod): Int64;
begin
  Result := DoExecuteCommand(FMapper.SolveCommand(pSQLCommand), pParametersHandler);
end;

function TAqDBConnection.DoPrepareCommand(const pSQLCommand: IAqDBSQLCommand): TAqID;
begin
  Result := DoPrepareCommand(FMapper.SolveCommand(pSQLCommand));
end;

procedure TAqDBConnection.RollbackTransaction;
begin
  try
    CheckConnectionActive;

    DoRollbackTransaction;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to rollback the transaction.'));
    end;
  end;
end;

function TAqDBConnection.PrepareCommand(const pSQL: string): TAqID;
begin
  Result := PrepareCommand(
    function: TAqID
    begin
      Result := DoPrepareCommand(pSQL);
    end);
end;

procedure TAqDBConnection.SetMapper(const pMapper: TAqDBMapper);
begin
  FreeAndNil(FMapper);
  FMapper := pMapper;
end;

procedure TAqDBConnection.SetActive(const pValue: Boolean);
begin
  inherited;

  if pValue xor Active then
  begin
    if pValue then
    begin
      DoConnect;
    end else begin
      DoDisconnect;
    end;
  end;
end;

class destructor TAqDBConnection.Destroy;
begin
  while FConnections.Count > 0 do
  begin
    FConnections.Last.Free;
  end;
  FConnections.Free;
end;

function TAqDBConnection.ExecuteCommand(const pCommandID: TAqID;
  const pParametersHandler: TAqDBParametersHandlerMethod): Int64;
begin
  Result := ExecuteCommand(
    function: Int64
    begin
      Result := DoExecuteCommand(pCommandID, pParametersHandler);
    end);
end;

function TAqDBConnection.ExecuteCommand(const pSQLCommand: IAqDBSQLCommand;
  const pParametersHandler: TAqDBParametersHandlerMethod): Int64;
begin
  Result := ExecuteCommand(
    function: Int64
    begin
      Result := DoExecuteCommand(pSQLCommand, pParametersHandler);
    end);
end;

{ TAqDBMapper }

function TAqDBMapper.GetGeneratorName(const pTableName: string): string;
begin
  Result := Format('GEN_%S_ID', [pTableName]);
end;

function TAqDBMapper.SolveAggregator(pValue: IAqDBSQLValue): string;
var
  lAggregatorMask: string;
begin
  case pValue.Aggregator of
    TAqDBSQLAggregatorType.atNone:
      lAggregatorMask := '%s';
    TAqDBSQLAggregatorType.atCount:
      lAggregatorMask := 'count(%s)';
    TAqDBSQLAggregatorType.atSum:
      lAggregatorMask := 'sum(%s)';
    TAqDBSQLAggregatorType.atAvg:
      lAggregatorMask := 'avg(%s)';
    TAqDBSQLAggregatorType.atMax:
      lAggregatorMask := 'max(%s)';
    TAqDBSQLAggregatorType.atMin:
      lAggregatorMask := 'min(%s)';
  else
    raise EAqInternal.Create('Aggragator not expected.');
  end;

  Result := Format(lAggregatorMask, [SolveValueType(pValue)]);
end;

function TAqDBMapper.SolveAlias(pAliasable: IAqDBSQLAliasable): string;
begin
  if pAliasable.IsAliasDefined then
  begin
    Result := pAliasable.Alias;
  end else begin
    Result := '';
  end;
end;

function TAqDBMapper.SolveBetweenCondition(pBetweenCondition: IAqDBSQLBetweenCondition): string;
begin
  Result := SolveValue(pBetweenCondition.Value, False) + ' between ' +
    SolveValue(pBetweenCondition.RangeBegin, False) + ' and ' + SolveValue(pBetweenCondition.RangeEnd, False);
end;

function TAqDBMapper.SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string;
begin
  if pConstant.Value then
  begin
    Result := 'True'.Quote;
  end else begin
    Result := 'False'.Quote;
  end;
end;

function TAqDBMapper.SolveBooleanOperator(const pBooleanOperator: TAqDBSQLBooleanOperator): string;
begin
  case pBooleanOperator of
    TAqDBSQLBooleanOperator.boAnd:
      Result := 'and';
    TAqDBSQLBooleanOperator.boOr:
      Result := 'or';
    TAqDBSQLBooleanOperator.boXor:
      Result := 'xor';
  else
    raise EAqInternal.Create('Unexpected Boolean Operator.');
  end;
end;

function TAqDBMapper.SolveValue(pValue: IAqDBSQLValue; const pUseAlias: Boolean): string;
begin
  Result := SolveAggregator(pValue);

  if pUseAlias and pValue.IsAliasDefined then
  begin
    Result := Result + ' as ' + SolveAlias(pValue);
  end;
end;

function TAqDBMapper.SolveValueIsNullCondition(pValueIsNullCondition: IAqDBSQLValueIsNullCondition): string;
begin
  Result := SolveValue(pValueIsNullCondition.Value, False) + ' is null';
end;

function TAqDBMapper.SolveOperation(pOperation: IAqDBSQLOperation): string;
begin
  Result := '(' + SolveValue(pOperation.LeftOperand, False) + ' ' + SolveOperator(pOperation.Operator) + ' ' +
    SolveValue(pOperation.RightOperand, False) + ')';
end;

function TAqDBMapper.SolveColumn(pColumn: IAqDBSQLColumn): string;
begin
  Result := SolveDisambiguation(pColumn) + pColumn.Expression;
end;

function TAqDBMapper.SolveColumns(pColumnsList: IAqReadList<IAqDBSQLValue>): string;
var
  lColumn: IAqDBSQLValue;
  lColumnsText: TStringList;
begin
  lColumnsText := TStringList.Create;

  try
    if pColumnsList.Count = 0 then
    begin
      lColumnsText.Add('*');
    end else begin
      for lColumn in pColumnsList do
      begin
        lColumnsText.Add(SolveValue(lColumn, True));
      end;
    end;

    lColumnsText.StrictDelimiter := True;
    lColumnsText.Delimiter := ',';
    Result := lColumnsText.DelimitedText;
  finally
    lColumnsText.Free;
  end;
end;

function TAqDBMapper.SolveSubselectValue(pColumn: IAqDBSQLSubselect): string;
begin
  Result := SolveSubselect(pColumn.Select);
end;

function TAqDBMapper.SolveCommand(pCommand: IAqDBSQLCommand): string;
begin
  case pCommand.CommandType of
    TAqDBSQLCommandType.ctSelect:
      Result := SolveSelect(pCommand.GetAsSelect);
    TAqDBSQLCommandType.ctInsert:
      Result := SolveInsert(pCommand.GetAsInsert);
    TAqDBSQLCommandType.ctUpdate:
      Result := SolveUpdate(pCommand.GetAsUpdate);
    TAqDBSQLCommandType.ctDelete:
      Result := SolveDelete(pCommand.GetAsDelete);
  else
    raise EAqInternal.Create('Command type not supoorted.');
  end;
end;

function TAqDBMapper.SolveComparison(const pComparison: TAqDBSQLComparison): string;
begin
  case pComparison of
    TAqDBSQLComparison.cpEqual:
      Result := '=';
    TAqDBSQLComparison.cpGreaterThan:
      Result := '>';
    TAqDBSQLComparison.cpGreaterEqual:
      Result := '>=';
    TAqDBSQLComparison.cpLessThan:
      Result := '<';
    TAqDBSQLComparison.cpLessEqual:
      Result := '<=';
  else
    raise EAqInternal.Create('Unexpected Comparison Type.');
  end;
end;

function TAqDBMapper.SolveComparisonCondition(pComparisonCondition: IAqDBSQLComparisonCondition): string;
begin
  Result := SolveValue(pComparisonCondition.LeftValue, False) + ' ' +
    SolveComparison(pComparisonCondition.Comparison) + ' ' + SolveValue(pComparisonCondition.RightValue, False);
end;

function TAqDBMapper.SolveComposedCondition(pComposedCondition: IAqDBSQLComposedCondition): string;
var
  lI: Int32;
begin
  Result := '(' + SolveCondition(pComposedCondition.Conditions.First);

  for lI := 1 to pComposedCondition.Conditions.Count - 1 do
  begin
    Result := ' ' + SolveBooleanOperator(pComposedCondition.LinkOperators[lI - 1]) + ' ' +
      SolveCondition(pComposedCondition.Conditions[lI]);
  end;

  Result := Result + ')';
end;

function TAqDBMapper.SolveCondition(pCondition: IAqDBSQLCondition): string;
begin
  case pCondition.ConditionType of
    TAqDBSQLConditionType.ctComparison:
      Result := SolveComparisonCondition(pCondition.GetAsComparison);
    TAqDBSQLConditionType.ctValueIsNull:
      Result := SolveValueIsNullCondition(pCondition.GetAsValueIsNull);
    TAqDBSQLConditionType.ctComposed:
      Result := SolveComposedCondition(pCondition.GetAsComposed);
    TAqDBSQLConditionType.ctBetween:
      Result := SolveBetweenCondition(pCondition.GetAsBetween);
  else
    raise EAqInternal.Create('Unexpected condition type.');
  end;
end;

function TAqDBMapper.SolveConstant(pConstant: IAqDBSQLConstant): string;
begin
  case pConstant.ConstantType of
    TAqDBSQLConstantValueType.cvText:
      Result := SolveTextConstant(pConstant.GetAsTextConstant);
    TAqDBSQLConstantValueType.cvNumeric:
      Result := SolveNumericConstant(pConstant.GetAsNumericConstant);
    TAqDBSQLConstantValueType.cvDateTime:
      Result := SolveDateTimeConstant(pConstant.GetAsDateTimeConstant);
  else
    raise EAqInternal.Create('Constant type not expected.');
  end;
end;

function TAqDBMapper.SolveDateConstant(pConstant: IAqDBSQLDateConstant): string;
begin
  Result := pConstant.Value.Format('yyyy.mm.dd').Quote;
end;

function TAqDBMapper.SolveDateTimeConstant(pConstant: IAqDBSQLDateTimeConstant): string;
begin
  Result := pConstant.Value.Format('yyyy.mm.dd hh:mm:ss:zzz').Quote;
end;

function TAqDBMapper.SolveDelete(pDelete: IAqDBSQLDelete): string;
begin
  Result := 'delete from ' + SolveTable(pDelete.Table);

  if pDelete.IsConditionDefined then
  begin
    Result := Result + ' where ' + SolveCondition(pDelete.Condition);
  end;
end;

function TAqDBMapper.SolveDisambiguation(pColumn: IAqDBSQLColumn): string;
begin
  if pColumn.IsSourceDefined then
  begin
    if pColumn.Source.IsAliasDefined then
    begin
      Result := SolveAlias(pColumn.Source) + '.';
    end else if pColumn.Source.SourceType = stTable then
    begin
      Result := pColumn.Source.GetAsTable.Name + '.';
    end else begin
      raise EAqInternal.Create('Column source doesn''t have a valid desambiguation.');
    end;
  end else begin
    Result := '';
  end;
end;

function TAqDBMapper.SolveFrom(pSource: IAqDBSQLSource): string;
begin
  Result := 'from ' + SolveSource(pSource);
end;

function TAqDBMapper.SolveInsert(pInsert: IAqDBSQLInsert): string;
var
  lColumns: TStringList;
  lValues: TStringList;
  lAssignment: IAqDBSQLAssignment;
begin
  Result := 'insert into ' + SolveTable(pInsert.Table);

  if pInsert.Assignments.Count = 0 then
  begin
    raise EAqInternal.Create('Insert has no assignments.');
  end;

  lColumns := TStringList.Create;

  try
    lValues := TStringList.Create;

    try
      for lAssignment in pInsert.Assignments do
      begin
        lColumns.Add(SolveColumn(lAssignment.Column));
        lValues.Add(SolveValue(lAssignment.Value, False));
      end;

      lColumns.StrictDelimiter := True;
      lColumns.Delimiter := ',';
      lValues.StrictDelimiter := True;
      lValues.Delimiter := ',';

      Result := Result + ' (' + lColumns.DelimitedText + ') values (' + lValues.DelimitedText + ')';
    finally
      lValues.Free;
    end;
  finally
    lColumns.Free;
  end;
end;

function TAqDBMapper.SolveJoin(pJoin: IAqDBSQLJoin): string;
begin
  case pJoin.JoinType of
    TAqDBSQLJoinType.jtInnerJoin:
      Result := 'inner join ';
    TAqDBSQLJoinType.jtLeftJoin:
      Result := 'left join ';
  else
    raise EAqInternal.Create('Unexpected Join Type.');
  end;

  Result := Result + SolveSource(pJoin.Source) + ' on ' + SolveCondition(pJoin.Condition);
end;

function TAqDBMapper.SolveJoins(pSelect: IAqDBSQLSelect): string;
var
  lJoin: IAqDBSQLJoin;
begin
  Result := '';

  if pSelect.HasJoins then
  begin
    for lJoin in pSelect.Joins do
    begin
      Result := Result + SolveJoin(lJoin) + ' ';
    end;

    Result := ' ' + Result.Trim;
  end;
end;

function TAqDBMapper.SolveLimit(pSelect: IAqDBSQLSelect): string;
begin
  Result := '';
end;

function TAqDBMapper.SolveNumericConstant(pConstant: IAqDBSQLNumericConstant): string;
begin
  Result := pConstant.Value.ToString;
end;

function TAqDBMapper.SolveOperator(const pOperator: TAqDBSQLOperator): string;
begin
  case pOperator of
    TAqDBSQLOperator.opSum:
      Result := '+';
    TAqDBSQLOperator.opSubtraction:
      Result := '-';
    TAqDBSQLOperator.opMultiplication:
      Result := '*';
    TAqDBSQLOperator.opDivision:
      Result := '/';
  else
    raise EAqInternal.Create('Operator not expected.');
  end;
end;

function TAqDBMapper.SolveOrderBy(pSelect: IAqDBSQLSelect): string;
var
  lValues: TStringList;
  lValue: IAqDBSQLValue;
begin
  if pSelect.IsOrderByDefined then
  begin
    lValues := TStringList.Create;

    try
      for lValue in pSelect.OrderBy do
      begin
        lValues.Add(SolveValue(lValue, False))
      end;

      lValues.StrictDelimiter := True;
      lValues.Delimiter := ',';

      Result := ' order by ' + lValues.DelimitedText;
    finally
      lValues.Free;
    end;
  end;
end;

function TAqDBMapper.SolveParameter(pParameter: IAqDBSQLParameter): string;
begin
  Result := ':' + pParameter.Name;
end;

function TAqDBMapper.SolveSource(pSource: IAqDBSQLSource): string;
begin
  case pSource.SourceType of
    stTable:
      Result := SolveTable(pSource.GetAsTable);
    stSelect:
      Result := SolveSubselect(pSource.GetAsSelect);
  else
    raise EAqInternal.Create('Unexpectes source type.');
  end;
end;

function TAqDBMapper.SolveSelect(pSelect: IAqDBSQLSelect): string;
begin
  Result := 'select ' + SolveSelectBody(pSelect);
end;

function TAqDBMapper.SolveSelectBody(pSelect: IAqDBSQLSelect): string;
begin
  Result := SolveColumns(pSelect.Columns) + ' ' + SolveFrom(pSelect.Source) + SolveJoins(pSelect);

  if pSelect.IsConditionDefined then
  begin
    Result := Result + ' where ' + SolveCondition(pSelect.Condition);
  end;

  Result := Result + SolveOrderBy(pSelect);
end;

function TAqDBMapper.SolveSubselect(pSelect: IAqDBSQLSelect): string;
begin
  if not pSelect.IsAliasDefined then
  begin
    raise EAqInternal.Create('It''s not possible to generate a Subselect without an alias.');
  end;

  Result := '(' + SolveSelect(pSelect) + ') as ' + SolveAlias(pSelect);
end;

function TAqDBMapper.SolveTable(pTable: IAqDBSQLTable): string;
begin
  Result := pTable.Name;

  if pTable.IsAliasDefined then
  begin
    Result := Result + ' as ' + SolveAlias(pTable);
  end;
end;

function TAqDBMapper.SolveTextConstant(pConstant: IAqDBSQLTextConstant): string;
begin
  Result := pConstant.Value.Quote;
end;

function TAqDBMapper.SolveTimeConstant(pConstant: IAqDBSQLTimeConstant): string;
begin
  Result := pConstant.Value.Format('hh:mm:ss:zzz').Quote;
end;

function TAqDBMapper.SolveUpdate(pUpdate: IAqDBSQLUpdate): string;
var
  lAssignments: TStringList;
  lAssignment: IAqDBSQLAssignment;
begin
  Result := 'update ' + SolveTable(pUpdate.Table) + ' set ';

  if pUpdate.Assignments.Count = 0 then
  begin
    raise EAqInternal.Create('Update has no assignments.');
  end;

  lAssignments := TStringList.Create;

  try
    for lAssignment in pUpdate.Assignments do
    begin
      lAssignments.Add(SolveColumn(lAssignment.Column) + ' = ' + SolveValue(lAssignment.Value, False));
    end;

    lAssignments.StrictDelimiter := True;
    lAssignments.Delimiter := ',';
    Result := Result + lAssignments.DelimitedText;

    if pUpdate.IsConditionDefined then
    begin
      Result := Result + ' where ' + SolveCondition(pUpdate.Condition);
    end;
  finally
    lAssignments.Free;
  end;
end;

function TAqDBMapper.SolveValueType(pValue: IAqDBSQLValue): string;
begin
  case pValue.ValueType of
    TAqDBSQLValueType.vtColumn:
      Result := SolveColumn(pValue.GetAsColumn);
    TAqDBSQLValueType.vtOperation:
      Result := SolveOperation(pValue.GetAsOperation);
    TAqDBSQLValueType.vtSubselect:
      Result := SolveSubselectValue(pValue.GetAsSubselect);
    TAqDBSQLValueType.vtConstant:
      Result := SolveConstant(pValue.GetAsConstant);
    TAqDBSQLValueType.vtParameter:
      Result := SolveParameter(pValue.GetAsParameter);
  else
    raise EAqInternal.Create('Value type not expected.');
  end;
end;

{ TAqDBPooledConnection<TBaseConnection> }

constructor TAqDBPooledConnection<TBaseConnection>.Create(
  const pConnectionBuilder: TAqAnonymousFunction<TBaseConnection>);
var
  lBaseConnection: TAqDBConnection;
begin
  FConnectionBuilder := pConnectionBuilder;
  lBaseConnection := nil;
  try
    inherited Create;

    FPreparedQueries := TAqIDDictionary<string>.Create(False);
    FPool := TAqList<TAqDBContext>.Create(True, True);

    lBaseConnection := pConnectionBuilder();
    FPool.Add(TAqDBContext.Create(Self, lBaseConnection));
  except
    lBaseConnection.Free;
    raise;
  end;

  AutoFlushContextsTime := 10 * SecsPerMin;
end;

function TAqDBPooledConnection<TBaseConnection>.CreateNewContext: TAqDBContext;
var
  lConnection: TAqDBConnection;
begin
  FPool.Lock;

  try
    Result := nil;
    try
      lConnection := FConnectionBuilder();
      try
        lConnection.Active := Active;
      except
        lConnection.Free;
        raise;
      end;
      Result := TAqDBContext.Create(Self, lConnection);
      FPool.Add(Result);
    except
      Result.Free;
      raise;
    end;
  finally
    FPool.Release;
  end;
end;

destructor TAqDBPooledConnection<TBaseConnection>.Destroy;
begin
  FreeFlushContextThread;
  FPool.Free;
  FPreparedQueries.Free;

  inherited;
end;

class function TAqDBPooledConnection<TBaseConnection>.GetDefaultMapper: TAqDBMapperClass;
begin
  Result := nil;
end;

function TAqDBPooledConnection<TBaseConnection>.GetActive: Boolean;
begin
  FPool.Lock;

  try
    Result := FPool.First.Connection.Active;
  finally
    FPool.Release;
  end;
end;

function TAqDBPooledConnection<TBaseConnection>.GetActiveConnections: Int32;
begin
  FPool.Lock;

  try
    Result := FPool.Count;
  finally
    FPool.Release;
  end;
end;

function TAqDBPooledConnection<TBaseConnection>.GetAutoFlushContextsTime: UInt32;
begin
  if Assigned(FFlushContextsThread) then
  begin
    Result := 0;
  end else begin
    Result := FFlushContextsThread.AutoFlushContextsTime;
  end;
end;

function TAqDBPooledConnection<TBaseConnection>.GetAutoIncrement(const pGeneratorName: string): Int64;
var
  lResult: Int64;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      lResult := pContext.Connection.GetAutoIncrement(pGeneratorName);
    end);

  Result := lResult;
end;

function TAqDBPooledConnection<TBaseConnection>.GetAutoIncrementType: TAqDBAutoIncrementType;
begin
  FPool.Lock;

  try
    Result := FPool.First.Connection.AutoIncrementType;
  finally
    FPool.Release;
  end;
end;

function TAqDBPooledConnection<TBaseConnection>.GetInTransaction: Boolean;
var
  lResult: Boolean;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      lResult := pContext.Connection.InTransaction;
    end);
end;

function TAqDBPooledConnection<TBaseConnection>.DoOpenQuery(const pSQLCommand: IAqDBSQLSelect;
  const pTratadorParametros: TAqDBParametersHandlerMethod): IAqDBReader;
var
  lResult: IAqDBReader;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      lResult := pContext.Connection.OpenQuery(pSQLCommand, pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBPooledConnection<TBaseConnection>.DoOpenQuery(const pCommandID: TAqID;
  const pTratadorParametros: TAqDBParametersHandlerMethod): IAqDBReader;
var
  lResult: IAqDBReader;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      lResult := pContext.Connection.OpenQuery(pContext.GetCommandID(pCommandID), pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBPooledConnection<TBaseConnection>.DoOpenQuery(const pSQL: string;
  const pTratadorParametros: TAqDBParametersHandlerMethod): IAqDBReader;
var
  lResult: IAqDBReader;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      lResult := pContext.Connection.OpenQuery(pSQL, pTratadorParametros);
    end);

  Result := lResult;
end;

procedure TAqDBPooledConnection<TBaseConnection>.DoStartTransaction;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      pContext.Connection.StartTransaction;
    end);
end;

procedure TAqDBPooledConnection<TBaseConnection>.DoConnect;
var
  lContext: TAqDBContext;
begin
  FPool.Lock;

  try
    for lContext in FPool do
    begin
      lContext.Connection.Active := True;
    end;
  finally
    FPool.Release;
  end;
end;

procedure TAqDBPooledConnection<TBaseConnection>.DoCommitTransaction;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      pContext.Connection.CommitTransaction;
    end);
end;

procedure TAqDBPooledConnection<TBaseConnection>.DoDisconnect;
begin
  FPool.Lock;

  try
    FPool.First.Connection.Active := False;

    while FPool.Count > 1 do
    begin
      FPool.Delete(FPool.Count - 1);
    end;
  finally
    FPool.Release;
  end;
end;

procedure TAqDBPooledConnection<TBaseConnection>.DoUnprepareCommand(const pCommandID: TAqID);
var
  lContext: TAqDBContext;
  lContextCommandID: TAqID;
begin
  FPool.Lock;

  try
    for lContext in FPool do
    begin
      if lContext.PreparedQueries.TryGetValue(pCommandID, lContextCommandID) then
      begin
        lContext.Connection.UnprepareCommand(lContextCommandID);
        lContext.PreparedQueries.Remove(pCommandID);
      end;
    end;

    FPreparedQueries.Remove(pCommandID);
  finally
    FPool.Release;
  end;
end;

procedure TAqDBPooledConnection<TBaseConnection>.FreeFlushContextThread;
begin
  FFlushContextsThread.Terminate;
  FFlushContextsThread.WaitFor;
  FreeAndNil(FFlushContextsThread);
end;

function TAqDBPooledConnection<TBaseConnection>.DoExecuteCommand(const pSQLCommand: IAqDBSQLCommand;
  const pTratadorParametros: TAqDBParametersHandlerMethod): Int64;
var
  lResult: Int64;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      lResult := pContext.Connection.ExecuteCommand(pSQLCommand, pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBPooledConnection<TBaseConnection>.DoExecuteCommand(const pCommandID: TAqID;
  const pTratadorParametros: TAqDBParametersHandlerMethod): Int64;
var
  lResult: Int64;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      lResult := pContext.Connection.ExecuteCommand(pContext.GetCommandID(pCommandID), pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBPooledConnection<TBaseConnection>.DoExecuteCommand(const pSQL: string;
  const pTratadorParametros: TAqDBParametersHandlerMethod): Int64;
var
  lResult: Int64;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      lResult := pContext.Connection.ExecuteCommand(pSQL, pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBPooledConnection<TBaseConnection>.DoPrepareCommand(const pSQLCommand: IAqDBSQLCommand): TAqID;
begin
  Result := DoPrepareCommand(FPool.First.Connection.Mapper.SolveCommand(pSQLCommand));
end;

function TAqDBPooledConnection<TBaseConnection>.DoPrepareCommand(const pSQL: string): TAqID;
begin
  Result := FPreparedQueries.Add(pSQL);
end;

procedure TAqDBPooledConnection<TBaseConnection>.DoRollbackTransaction;
begin
  SolvePoolAndExecute(
    procedure(const pContext: TAqDBContext)
    begin
      pContext.Connection.RollbackTransaction;
    end);
end;

procedure TAqDBPooledConnection<TBaseConnection>.SolvePoolAndExecute(
  const pMethod: TAqMethodGenericParameter<TAqDBContext>);
var
  lI: Int32;
  lLockedContext: TAqDBContext;
  lAvailableContext: TAqDBContext;
  lThreadID: TThreadID;
begin
  FPool.Lock;

  try
    lI := FPool.Count;
    lLockedContext := nil;
    lAvailableContext := nil;
    lThreadID := TThread.CurrentThread.ThreadID;

    while not Assigned(lLockedContext) and (lI > 0) do
    begin
      Dec(lI);
      if FPool[lI].Locked and (FPool[lI].LockerThread = lThreadID) then
      begin
        lLockedContext := FPool[lI];
      end else if not FPool[lI].Locked then
      begin
        lAvailableContext := FPool[lI];
      end;
    end;

    if not Assigned(lLockedContext) then
    begin
      if Assigned(lAvailableContext) then
      begin
        lLockedContext := lAvailableContext;
      end else begin
        lLockedContext := CreateNewContext;
      end;
    end;

    lLockedContext.LockConnection;
  finally
    FPool.Release;
  end;

  try
    pMethod(lLockedContext);
  finally
    FPool.Lock;

    try
      lLockedContext.ReleaseConnection;
    finally
      FPool.Release;
    end;
  end;
end;

procedure TAqDBPooledConnection<TBaseConnection>.SetAutoFlushContextsTime(const pValue: UInt32);
begin
  if pValue = 0 then
  begin
    if Assigned(FFlushContextsThread) then
    begin
      FreeFlushContextThread;
    end;
  end else begin
    if not Assigned(FFlushContextsThread) then
    begin
      FFlushContextsThread := TAqDBFlushContextsThread.Create(FPool);
    end;

    FFlushContextsThread.AutoFlushContextsTime := pValue;
  end;
end;

procedure TAqDBPooledConnection<TBaseConnection>.SetMapper(const pMapeador: TAqDBMapper);
var
  lContext: TAqDBContext;
begin
  FPool.Lock;
  try
    for lContext in FPool do
    begin
      lContext.Connection.SetMapper(pMapeador);
    end;
  finally
    FPool.Release;
  end;
end;

{ TAqDBPooledConnection<TBaseConnection>.TAqDBContext }

constructor TAqDBPooledConnection<TBaseConnection>.TAqDBContext.Create(
  const pMasterConnections: TAqDBPooledConnection<TBaseConnection>; const pBaseConection: TBaseConnection);
begin
  FMasterConnection := pMasterConnections;
  FConnection := pBaseConection;
  FPreparedQueries := TAqDictionary<TAqID, TAqID>.Create;
end;

destructor TAqDBPooledConnection<TBaseConnection>.TAqDBContext.Destroy;
begin
  FConnection.Free;
  FPreparedQueries.Free;

  inherited;
end;

function TAqDBPooledConnection<TBaseConnection>.TAqDBContext.GetCommandID(const pMasterCommandID: TAqID): TAqID;
var
  lSQL: string;
begin
  if not FPreparedQueries.TryGetValue(pMasterCommandID, Result) then
  begin
    if not FMasterConnection.PreparedQueries.TryGetValue(pMasterCommandID, lSQL) then
    begin
      raise EAqInternal.CreateFmt('Command from ID %d not found.', [pMasterCommandID]);
    end;

    Result := FConnection.PrepareCommand(lSQL);

    try
      FPreparedQueries.Add(pMasterCommandID, Result);
    except
      FConnection.UnprepareCommand(Result);
      raise;
    end;
  end;
end;

function TAqDBPooledConnection<TBaseConnection>.TAqDBContext.GetIsLocked: Boolean;
begin
  Result := FLockerThread <> 0;
end;

procedure TAqDBPooledConnection<TBaseConnection>.TAqDBContext.ReleaseConnection;
begin
  if FCalls > 0 then
  begin
    Dec(FCalls);
    if not FConnection.InTransaction and (FCalls = 0) then
    begin
      FLockerThread := 0;
      FLastUsedAt := Now;
    end;
  end;
end;

procedure TAqDBPooledConnection<TBaseConnection>.TAqDBContext.LockConnection;
begin
  if (FLockerThread <> 0) and (FLockerThread <> TThread.CurrentThread.ThreadID) then
  begin
    raise EAqInternal.Create('This context is already locked to another thread.');
  end;

  FLockerThread := TThread.CurrentThread.ThreadID;
  Inc(FCalls);
end;

{ TAqDBPooledConnection<TBaseConnection>.TAqDBFlushContextsThread }

constructor TAqDBPooledConnection<TBaseConnection>.TAqDBFlushContextsThread.Create(
  const pPool: TAqList<TAqDBContext>);
begin
  inherited Create(False);
  FPool := pPool;
end;

procedure TAqDBPooledConnection<TBaseConnection>.TAqDBFlushContextsThread.Execute;
var
  lNextAttempt: TDateTime;
  lI: Int32;
  lContext: TAqDBContext;
  lDateTimeCut: TDateTime;
begin
  lNextAttempt := 0;

  while not Terminated do
  begin
    if lNextAttempt <= Now then
    begin
      lDateTimeCut := Now.IncSecond(-FAutoFlushContextsTime);
      FPool.Lock;

      try
        lI := 0;

        while not Terminated and (lI < FPool.Count - 1) do
        begin
          lContext := FPool[lI];
          if lContext.Locked or (lContext.LastUsedAt > lDateTimeCut) then
          begin
            Inc(lI);
          end else begin
            FPool.Delete(lI);
          end;
        end;
      finally
        FPool.Release;
      end;

      lNextAttempt := Now.IncMinute;
    end;
    Sleep(10);
  end;
end;

procedure TAqDBPooledConnection<TBaseConnection>.TAqDBFlushContextsThread.SetAutoFlushContextsTime(
  const pValue: UInt32);
begin
  FPool.Lock;

  try
    FAutoFlushContextsTime := pValue;
  finally
    FPool.Release;
  end;
end;

end.
