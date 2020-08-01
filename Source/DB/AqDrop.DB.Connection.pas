unit AqDrop.DB.Connection;

interface

uses
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  AqDrop.Core.Types,
  AqDrop.Core.Manager,
  AqDrop.Core.Collections.Intf,
  AqDrop.DB.Types,
  AqDrop.DB.SQL,
  AqDrop.DB.Adapter,
  AqDrop.DB.SQL.Intf;

type
  TAqDBConnectionClass = class of TAqDBConnection;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Abstract class for connections with SGBDs.
  ///   PT-BR:
  ///     Classe abstrata base para conex�es com SGBDs.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqDBConnection = class abstract(TAqManager<TObject>)
  strict private
    FOnwsAdapter: Boolean;

    FAutoConnect: Boolean;
    FTransactionCalls: UInt32;
    FOnRollbackTasks: IAqIDDictionary<TProc>;
    FAdapter: TAqDBAdapter;
    FReaders: UInt32;
    FOnFirstReaderOpened: TProc<TAqDBConnection>;
    FOnLastReaderClosed: TProc<TAqDBConnection>;

    procedure CheckConnectionActive;

    function PrepareCommand(const pPreparingFunction: TFunc<TAqID>): TAqID; overload;
    function OpenQuery(const pOpeningFunction: TFunc<IAqDBReader>): IAqDBReader; overload;
    function ExecuteCommand(const pExecutionFunction: TFunc<Int64>): Int64; overload;

    class var FConnections: IAqList<TAqDBConnection>;
  private
    class procedure _Initialize;
    class procedure _Finalize;

    property OnFirstReaderOpened: TProc<TAqDBConnection> read FOnFirstReaderOpened write FOnFirstReaderOpened;
    property OnLastReaderClosed: TProc<TAqDBConnection> read FOnLastReaderClosed write FOnLastReaderClosed;
  strict protected
    procedure DoStartTransaction; virtual; abstract;
    procedure DoCommitTransaction; virtual; abstract;
    procedure DoRollbackTransaction; virtual; abstract;

    function DoPrepareCommand(const pSQL: string;
      const pParametersInitializer: TAqDBParametersHandlerMethod): TAqID; overload; virtual; abstract;
    function DoPrepareCommand(const pSQLCommand: IAqDBSQLCommand;
      const pParametersInitializer: TAqDBParametersHandlerMethod): TAqID; overload; virtual;

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
    function GetInTransaction: Boolean;

    procedure DoConnect; virtual; abstract;
    procedure DoDisconnect; virtual; abstract;

    function CreateAdapter: TAqDBAdapter; virtual;

    procedure RaiseImpossibleToConnect(const pEBase: Exception);

    property TransactionCalls: UInt32 read FTransactionCalls;

    class function GetDefaultAdapter: TAqDBAdapterClass; virtual;
    class procedure ReleaseFromConnectionsList(const pConnection: TAqDBConnection);
  protected
    procedure SetAdapter(const pAdapter: TAqDBAdapter); overload; virtual;
    procedure SetAdapter(const pAdapter: TAqDBAdapter; const pOwnsAdapter: Boolean); overload; virtual;
    function ExtractAdapter: TAqDBAdapter;
    procedure IncreaseReaderes;
    procedure DecrementReaders;
  public
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
    ///     Abre a conex�o.
    /// </summary>
    procedure Connect; virtual;
    /// <summary>
    ///   EN-US:
    ///     Closes the connection.
    ///   PT-BR:
    ///     Fecha a conex�o.
    /// </summary>
    procedure Disconnect; virtual;

    procedure StartTransaction; virtual;
    procedure CommitTransaction; virtual;
    procedure RollbackTransaction; virtual;
    function RegisterDoOnRollback(const pMethod: TProc): TAqID; virtual;
    procedure UnregisterDoOnRollback(const pID: TAqID); virtual;
    procedure RollbackAllCalls; virtual;

    function PrepareCommand(const pSQL: string;
      const pParametersInitializer: TAqDBParametersHandlerMethod = nil): TAqID; overload; virtual;
    function PrepareCommand(const pSQLCommand: IAqDBSQLCommand;
      const pParametersInitializer: TAqDBParametersHandlerMethod = nil): TAqID; overload; virtual;

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
    ///     Instru��o SQL a ser executada.
    /// </param>
    /// <param name="pParametersHandler">
    ///   EN-US:
    ///     Anonymous method to handle the parameters values of the command.
    ///   PT-BR:
    ///     M�todo an�nimo para escrita dos valores de entrada dos par�metros.
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

    function GetAutoIncrementValue(const pGenerator: string = ''): Int64; virtual;


    property AutoConnect: Boolean read FAutoConnect write FAutoConnect;
    property Adapter: TAqDBAdapter read FAdapter write SetAdapter;
    property Active: Boolean read GetActive write SetActive;
    property InTransaction: Boolean read GetInTransaction;
  end;

  TAqDBPreparedQuery = class
  strict private
      FSQL: string;
      FParametersInitializer: TAqDBParametersHandlerMethod;
  public
    constructor Create(const pSQL: string; const pParametersInitializer: TAqDBParametersHandlerMethod);

    property SQL: string read FSQL write FSQL;
    property ParametersInitializer: TAqDBParametersHandlerMethod read FParametersInitializer
      write FParametersInitializer;
  end;

  TAqDBConnectionPool<TBaseConnection: TAqDBConnection> = class;

  TAqDBPooledConnection<TBaseConnection: TAqDBConnection> = class
  strict private
    FMasterConnection: TAqDBConnectionPool<TBaseConnection>;
    FLockerThread: TThreadID;
    FConnection: TBaseConnection;
    FPreparedQueries: IAqDictionary<TAqID, TAqID>;
    FCalls: UInt32;
    FLastUsedAt: TDateTime;

    function GetIsLocked: Boolean;
  public
    constructor Create(const pMasterConnections: TAqDBConnectionPool<TBaseConnection>;
      const pBaseConection: TBaseConnection);
    destructor Destroy; override;

    procedure LockConnection;
    procedure ReleaseConnection;

    function GetCommandID(const pMasterCommandID: TAqID): TAqID;

    property Connection: TBaseConnection read FConnection;
    property LockerThread: TThreadID read FLockerThread;
    property Locked: Boolean read GetIsLocked;
    property PreparedQueries: IAqDictionary<TAqID, TAqID> read FPreparedQueries;
    property LastUsedAt: TDateTime read FLastUsedAt;
  end;

  TAqDBFlushContextsThread<TBaseConnection: TAqDBConnection> = class(TThread)
  strict private
    FAutoFlushContextsTime: UInt32;
    FPool: IAqList<TAqDBPooledConnection<TBaseConnection>>;

    procedure SetAutoFlushContextsTime(const pValue: UInt32);
  protected
    procedure Execute; override;
  public
    constructor Create(const pPool: IAqList<TAqDBPooledConnection<TBaseConnection>>);

    property AutoFlushContextsTime: UInt32 read FAutoFlushContextsTime write SetAutoFlushContextsTime;
  end;

  TAqDBConnectionPool<TBaseConnection: TAqDBConnection> = class(TAqDBConnection)
  strict private
    FPool: IAqList<TAqDBPooledConnection<TBaseConnection>>;
    FConnectionBuilder: TFunc<TBaseConnection>;
    FPreparedQueries: IAqIDDictionary<TAqDBPreparedQuery>;
    FFlushContextsThread: TAqDBFlushContextsThread<TBaseConnection>;

    procedure SolvePoolAndExecute(const pMethod: TProc<TAqDBPooledConnection<TBaseConnection>>);
    function GetActiveConnections: Int32;
    function GetAutoFlushContextsTime: UInt32;
    procedure SetAutoFlushContextsTime(const pValue: UInt32);
    procedure FreeFlushContextThread;
  strict protected
    procedure DoStartTransaction; override;
    procedure DoCommitTransaction; override;
    procedure DoRollbackTransaction; override;

    function DoPrepareCommand(const pSQL: string;
      const pParametersInitializer: TAqDBParametersHandlerMethod): TAqID; override;
    function DoPrepareCommand(const pSQLCommand: IAqDBSQLCommand;
      const pParametersInitializer: TAqDBParametersHandlerMethod): TAqID; override;

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

    function CreateNewContext: TAqDBPooledConnection<TBaseConnection>; virtual;

    procedure DoConnect; override;
    procedure DoDisconnect; override;

    {TODO 3 -oTatu -cIncompleto: reativar}
//    function GetInTransaction: Boolean; override;

    class function GetDefaultAdapter: TAqDBAdapterClass; override;
  protected
    procedure SetAdapter(const pAdapter: TAqDBAdapter); override;

    property PreparedQueries: IAqIDDictionary<TAqDBPreparedQuery> read FPreparedQueries;
    property Pool: IAqList<TAqDBPooledConnection<TBaseConnection>> read FPool;
  public
    constructor Create(const pConnectionBuilder: TFunc<TBaseConnection>); reintroduce; virtual;
    destructor Destroy; override;

    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;
    function RegisterDoOnRollback(const pMethod: TProc): TAqID; override;
    procedure UnregisterDoOnRollback(const pID: TAqID); override;
    procedure RollbackAllCalls; override;

    property ActiveConnections: Int32 read GetActiveConnections;
    property AutoFlushContextsTime: UInt32 read GetAutoFlushContextsTime write SetAutoFlushContextsTime;
  end;

implementation

uses
  System.DateUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.Core.Collections;

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
    if not FAutoConnect then
    begin
      raise EAqInternal.Create('Connection is not active.');
    end;

    Connect;
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

function TAqDBConnection.OpenQuery(const pOpeningFunction: TFunc<IAqDBReader>): IAqDBReader;
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

    if FTransactionCalls = 0 then
    begin
      DoStartTransaction;
    end;

    Inc(FTransactionCalls);
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

    if FTransactionCalls = 0 then
    begin
      raise EAqInternal.Create('There is no transaction to commit.');
    end;

    Dec(FTransactionCalls);

    if FTransactionCalls = 0 then
    begin
      DoCommitTransaction;

      if Assigned(FOnRollbackTasks) then
      begin
        FOnRollbackTasks.Clear;
      end;
    end;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to commit the transaction.'));
    end;
  end;
end;

constructor TAqDBConnection.Create;
begin
  inherited;

  SetAdapter(CreateAdapter);

  FConnections.ExecuteLockedForWriting(
    procedure
    begin
      FConnections.Add(Self);
    end);
end;

function TAqDBConnection.CreateAdapter: TAqDBAdapter;
var
  lAdapterClass: TAqDBAdapterClass;
begin
  lAdapterClass := GetDefaultAdapter;

  if Assigned(lAdapterClass) then
  begin
    Result := lAdapterClass.Create;
  end else begin
    Result := nil;
  end;
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

procedure TAqDBConnection.UnregisterDoOnRollback(const pID: TAqID);
begin
  if Assigned(FOnRollbackTasks) then
  begin
    FOnRollbackTasks.Remove(pID);
  end;
end;

class procedure TAqDBConnection._Finalize;
begin
{$IFNDEF AUTOREFCOUNT}
  while FConnections.Count > 0 do
  begin
    FConnections.Last.Free;
  end;
{$ENDIF}
end;

class procedure TAqDBConnection._Initialize;
begin
  FConnections := TAqList<TAqDBConnection>.Create(TAqLockerType.lktMultiReaderExclusiveWriter);
end;

procedure TAqDBConnection.DecrementReaders;
begin
  if FReaders > 0 then
  begin
    Dec(FReaders);

    if Assigned(FOnLastReaderClosed) and (FReaders = 0) then
    begin
      FOnLastReaderClosed(Self);
    end;
  end;
end;

destructor TAqDBConnection.Destroy;
begin
  if FOnwsAdapter then
  begin
    FAdapter.Free;
  end;

  ReleaseFromConnectionsList(Self);

  inherited;
end;

function TAqDBConnection.ExecuteCommand(const pExecutionFunction: TFunc<Int64>): Int64;
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

function TAqDBConnection.GetAutoIncrementValue(const pGenerator: string): Int64;
var
  lReader: IAqDBReader;
  lQuery: string;
begin
  lQuery := Adapter.SQLSolver.GetAutoIncrementQuery(pGenerator);

  if lQuery.IsEmpty then
  begin
    Result := 0;
  end else begin
    lReader := OpenQuery(lQuery);

    if not lReader.Next then
    begin
      raise EAqInternal.Create('It wasn''t possible to get the generator value.');
    end;

    Result := lReader.Values[0].AsInt64;
  end;
end;

class function TAqDBConnection.GetDefaultAdapter: TAqDBAdapterClass;
begin
  Result := TAqDBAdapter;
end;

function TAqDBConnection.GetInTransaction: Boolean;
begin
  Result := FTransactionCalls > 0;
end;

procedure TAqDBConnection.IncreaseReaderes;
begin
  if Assigned(FOnFirstReaderOpened) and (FReaders = 0) then
  begin
    FOnFirstReaderOpened(Self);
  end;

  Inc(FReaders);
end;

function TAqDBConnection.PrepareCommand(const pSQLCommand: IAqDBSQLCommand;
  const pParametersInitializer: TAqDBParametersHandlerMethod = nil): TAqID;
begin
  Result := PrepareCommand(
    function: TAqID
    begin
      Result := DoPrepareCommand(pSQLCommand, pParametersInitializer);
    end);
end;

function TAqDBConnection.PrepareCommand(const pPreparingFunction: TFunc<TAqID>): TAqID;
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
  Result := DoOpenQuery(FAdapter.SQLSolver.SolveSelect(pSQLCommand), pParametersHandler);
end;

function TAqDBConnection.DoExecuteCommand(const pSQLCommand: IAqDBSQLCommand;
  const pParametersHandler: TAqDBParametersHandlerMethod): Int64;
begin
  Result := DoExecuteCommand(FAdapter.SQLSolver.SolveCommand(pSQLCommand), pParametersHandler);
end;

function TAqDBConnection.DoPrepareCommand(const pSQLCommand: IAqDBSQLCommand;
  const pParametersInitializer: TAqDBParametersHandlerMethod): TAqID;
begin
  Result := DoPrepareCommand(FAdapter.SQLSolver.SolveCommand(pSQLCommand), pParametersInitializer);
end;

procedure TAqDBConnection.RaiseImpossibleToConnect(const pEBase: Exception);
begin
  pEBase.RaiseOuterException(EAqFriendly.Create('It wasn''t possible to stablish a connection to the DB.'));
end;

class procedure TAqDBConnection.ReleaseFromConnectionsList(const pConnection: TAqDBConnection);
begin
  FConnections.ExecuteLockedForWriting(
    procedure
    var
      lI: Int32;
    begin
      lI := FConnections.IndexOf(pConnection);

      if lI >= 0 then
      begin
        FConnections.Delete(lI);
      end;
    end);
end;

procedure TAqDBConnection.RollbackAllCalls;
begin
  while FTransactionCalls > 0 do
  begin
    RollbackTransaction;
  end;
end;

procedure TAqDBConnection.RollbackTransaction;
var
  lTask: TProc;
begin
  try
    CheckConnectionActive;

    if FTransactionCalls = 0 then
    begin
      raise EAqInternal.Create('There are no transaction to revert.');
    end;

    Dec(FTransactionCalls);

    if FTransactionCalls = 0 then
    begin
      if Assigned(FOnRollbackTasks) and (FOnRollbackTasks.Count > 0) then
      begin
        for lTask in FOnRollbackTasks.Values do
        begin
          lTask();
        end;

        FOnRollbackTasks.Clear;
      end;

      DoRollbackTransaction;
    end;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to rollback the transaction.'));
    end;
  end;
end;

function TAqDBConnection.PrepareCommand(const pSQL: string;
  const pParametersInitializer: TAqDBParametersHandlerMethod = nil): TAqID;
begin
  Result := PrepareCommand(
    function: TAqID
    begin
      Result := DoPrepareCommand(pSQL, pParametersInitializer);
    end);
end;

procedure TAqDBConnection.SetAdapter(const pAdapter: TAqDBAdapter);
begin
  SetAdapter(pAdapter, True);
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

procedure TAqDBConnection.SetAdapter(const pAdapter: TAqDBAdapter; const pOwnsAdapter: Boolean);
begin
  if FOnwsAdapter then
  begin
    FAdapter.Free;
  end;

  FAdapter := pAdapter;
  FOnwsAdapter := pOwnsAdapter;
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

function TAqDBConnection.ExtractAdapter: TAqDBAdapter;
begin
  Result := FAdapter;
  FAdapter := nil;
  FOnwsAdapter := False;
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


function TAqDBConnection.RegisterDoOnRollback(const pMethod: TProc): TAqID;
begin
  if not Assigned(FOnRollbackTasks) then
  begin
    FOnRollbackTasks := TAqIDDictionary<TProc>.Create;
  end;

  Result := FOnRollbackTasks.Add(pMethod);
end;

{ TAqDBConnectionPool<TBaseConnection> }

procedure TAqDBConnectionPool<TBaseConnection>.CommitTransaction;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      pContext.Connection.CommitTransaction;
    end);
end;

constructor TAqDBConnectionPool<TBaseConnection>.Create(const pConnectionBuilder: TFunc<TBaseConnection>);
var
  lBaseContext: TAqDBPooledConnection<TBaseConnection>;
begin
  FConnectionBuilder := pConnectionBuilder;

  FPreparedQueries := TAqIDDictionary<TAqDBPreparedQuery>.Create(True);
  FPool := TAqList<TAqDBPooledConnection<TBaseConnection>>.Create(True, TAqLockerType.lktMultiReaderExclusiveWriter);

  inherited Create;

  lBaseContext := CreateNewContext;

  if not Assigned(Adapter) then
  begin
    SetAdapter(lBaseContext.Connection.ExtractAdapter);
  end;

  AutoFlushContextsTime := 3 * SecsPerMin;
end;

function TAqDBConnectionPool<TBaseConnection>.CreateNewContext: TAqDBPooledConnection<TBaseConnection>;
var
  lConnection: TAqDBConnection;
begin
  FPool.BeginWrite;

  try
    Result := nil;
    try
      lConnection := FConnectionBuilder();
      try
        lConnection.Connect;

        if Assigned(Adapter) then
        begin
          lConnection.SetAdapter(Adapter, False);
        end;
      except
        lConnection.Free;
        raise;
      end;
      Result := TAqDBPooledConnection<TBaseConnection>.Create(Self, lConnection);
      ReleaseFromConnectionsList(lConnection);

      FPool.Add(Result);
    except
      Result.Free;
      raise;
    end;
  finally
    FPool.EndWrite;
  end;
end;

destructor TAqDBConnectionPool<TBaseConnection>.Destroy;
begin
  FreeFlushContextThread;

  inherited;
end;

class function TAqDBConnectionPool<TBaseConnection>.GetDefaultAdapter: TAqDBAdapterClass;
begin
  Result := nil;
end;

procedure TAqDBConnectionPool<TBaseConnection>.RollbackAllCalls;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      pContext.Connection.RollbackAllCalls;
    end);
end;

procedure TAqDBConnectionPool<TBaseConnection>.RollbackTransaction;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      pContext.Connection.RollbackTransaction;
    end);
end;

function TAqDBConnectionPool<TBaseConnection>.GetActive: Boolean;
begin
  FPool.BeginRead;

  try
    Result := FPool.First.Connection.Active;
  finally
    FPool.EndRead;
  end;
end;

function TAqDBConnectionPool<TBaseConnection>.GetActiveConnections: Int32;
begin
  FPool.BeginRead;

  try
    Result := FPool.Count;
  finally
    FPool.EndRead;
  end;
end;

function TAqDBConnectionPool<TBaseConnection>.GetAutoFlushContextsTime: UInt32;
begin
  if Assigned(FFlushContextsThread) then
  begin
    Result := 0;
  end else begin
    Result := FFlushContextsThread.AutoFlushContextsTime;
  end;
end;

//function TAqDBConnectionPool<TBaseConnection>.GetInTransaction: Boolean;
//var
//  lResult: Boolean;
//begin
//  SolvePoolAndExecute(
//    procedure(const pContext: TAqDBPooledConnection)
//    begin
//      lResult := pContext.Connection.InTransaction;
//    end);
//end;

function TAqDBConnectionPool<TBaseConnection>.DoOpenQuery(const pSQLCommand: IAqDBSQLSelect;
  const pTratadorParametros: TAqDBParametersHandlerMethod): IAqDBReader;
var
  lResult: IAqDBReader;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      lResult := pContext.Connection.OpenQuery(pSQLCommand, pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBConnectionPool<TBaseConnection>.RegisterDoOnRollback(const pMethod: TProc): TAqID;
var
  lResult: TAqID;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      lResult :=  pContext.Connection.RegisterDoOnRollback(pMethod);
    end);

  Result := lResult;
end;

function TAqDBConnectionPool<TBaseConnection>.DoOpenQuery(const pCommandID: TAqID;
  const pTratadorParametros: TAqDBParametersHandlerMethod): IAqDBReader;
var
  lResult: IAqDBReader;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      lResult := pContext.Connection.OpenQuery(pContext.GetCommandID(pCommandID), pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBConnectionPool<TBaseConnection>.DoOpenQuery(const pSQL: string;
  const pTratadorParametros: TAqDBParametersHandlerMethod): IAqDBReader;
var
  lResult: IAqDBReader;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      lResult := pContext.Connection.OpenQuery(pSQL, pTratadorParametros);
    end);

  Result := lResult;
end;

procedure TAqDBConnectionPool<TBaseConnection>.DoStartTransaction;
begin
  raise EAqInternal.Create('The fisical transaction methods of this class cannot be called.');
end;

procedure TAqDBConnectionPool<TBaseConnection>.DoConnect;
var
  lContext: TAqDBPooledConnection<TBaseConnection>;
begin
  FPool.BeginRead;

  try
    for lContext in FPool do
    begin
      lContext.Connection.Active := True;
    end;
  finally
    FPool.EndRead;
  end;
end;

procedure TAqDBConnectionPool<TBaseConnection>.DoCommitTransaction;
begin
  raise EAqInternal.Create('The fisical transaction methods of this class cannot be called.');
end;

procedure TAqDBConnectionPool<TBaseConnection>.DoDisconnect;
begin
  FPool.BeginWrite;

  try
    FPool.First.Connection.Active := False;

    while FPool.Count > 1 do
    begin
      FPool.Delete(FPool.Count - 1);
    end;
  finally
    FPool.EndWrite;
  end;
end;

procedure TAqDBConnectionPool<TBaseConnection>.DoUnprepareCommand(const pCommandID: TAqID);
var
  lContext: TAqDBPooledConnection<TBaseConnection>;
  lContextCommandID: TAqID;
begin
  FPool.BeginRead;

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
    FPool.EndRead;
  end;
end;

procedure TAqDBConnectionPool<TBaseConnection>.FreeFlushContextThread;
begin
  if Assigned(FFlushContextsThread) then
  begin
    FFlushContextsThread.Terminate;
    FFlushContextsThread.WaitFor;
    FreeAndNil(FFlushContextsThread);
  end;
end;

function TAqDBConnectionPool<TBaseConnection>.DoExecuteCommand(const pSQLCommand: IAqDBSQLCommand;
  const pTratadorParametros: TAqDBParametersHandlerMethod): Int64;
var
  lResult: Int64;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      lResult := pContext.Connection.ExecuteCommand(pSQLCommand, pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBConnectionPool<TBaseConnection>.DoExecuteCommand(const pCommandID: TAqID;
  const pTratadorParametros: TAqDBParametersHandlerMethod): Int64;
var
  lResult: Int64;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      lResult := pContext.Connection.ExecuteCommand(pContext.GetCommandID(pCommandID), pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBConnectionPool<TBaseConnection>.DoExecuteCommand(const pSQL: string;
  const pTratadorParametros: TAqDBParametersHandlerMethod): Int64;
var
  lResult: Int64;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      lResult := pContext.Connection.ExecuteCommand(pSQL, pTratadorParametros);
    end);

  Result := lResult;
end;

function TAqDBConnectionPool<TBaseConnection>.DoPrepareCommand(const pSQLCommand: IAqDBSQLCommand;
  const pParametersInitializer: TAqDBParametersHandlerMethod): TAqID;
begin
  Result := DoPrepareCommand(FPool.First.Connection.Adapter.SQLSolver.SolveCommand(pSQLCommand),
    pParametersInitializer);
end;

function TAqDBConnectionPool<TBaseConnection>.DoPrepareCommand(const pSQL: string;
  const pParametersInitializer: TAqDBParametersHandlerMethod): TAqID;
begin
  Result := FPreparedQueries.Add(TAqDBPreparedQuery.Create(pSQL, pParametersInitializer));
end;

procedure TAqDBConnectionPool<TBaseConnection>.DoRollbackTransaction;
begin
  raise EAqInternal.Create('The fisical transaction methods of this class cannot be called.');
end;

procedure TAqDBConnectionPool<TBaseConnection>.SolvePoolAndExecute(
  const pMethod: TProc<TAqDBPooledConnection<TBaseConnection>>);
var
  lI: Int32;
  lLockedContext: TAqDBPooledConnection<TBaseConnection>;
  lAvailableContext: TAqDBPooledConnection<TBaseConnection>;
  lThreadID: TThreadID;
begin
  FPool.BeginWrite;

  try
    lI := FPool.Count;
    lLockedContext := nil;
    lAvailableContext := nil;
    lThreadID := TThread.CurrentThread.ThreadID;

    {TODO 3 -oTatu -cMelhoria: colocar contextos locados em um dictionary a parte da lista de contextos dispon�veis.}
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
    FPool.EndWrite;
  end;

  try
    pMethod(lLockedContext);
  finally
    lLockedContext.ReleaseConnection;
  end;
end;

procedure TAqDBConnectionPool<TBaseConnection>.StartTransaction;
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      pContext.Connection.StartTransaction;
    end);
end;

procedure TAqDBConnectionPool<TBaseConnection>.UnregisterDoOnRollback(const pID: TAqID);
begin
  SolvePoolAndExecute(
    procedure(pContext: TAqDBPooledConnection<TBaseConnection>)
    begin
      pContext.Connection.UnregisterDoOnRollback(pID);
    end);
end;

procedure TAqDBConnectionPool<TBaseConnection>.SetAutoFlushContextsTime(const pValue: UInt32);
begin
  if pValue = 0 then
  begin
    FreeFlushContextThread;
  end else begin
    if not Assigned(FFlushContextsThread) then
    begin
      FFlushContextsThread := TAqDBFlushContextsThread<TBaseConnection>.Create(FPool);
    end;

    FFlushContextsThread.AutoFlushContextsTime := pValue;
  end;
end;

procedure TAqDBConnectionPool<TBaseConnection>.SetAdapter(const pAdapter: TAqDBAdapter);
var
  lContext: TAqDBPooledConnection<TBaseConnection>;
begin
  FPool.BeginRead;
  try
    inherited;

    for lContext in FPool do
    begin
      lContext.Connection.SetAdapter(pAdapter, False);
    end;
  finally
    FPool.EndRead;
  end;
end;

{ TAqDBPooledConnection<TBaseConnection> }

constructor TAqDBPooledConnection<TBaseConnection>.Create(
  const pMasterConnections: TAqDBConnectionPool<TBaseConnection>; const pBaseConection: TBaseConnection);
begin
  FMasterConnection := pMasterConnections;
  FConnection := pBaseConection;
  FPreparedQueries := TAqDictionary<TAqID, TAqID>.Create;
  FConnection.OnFirstReaderOpened :=
    procedure(pConnection: TAqDBConnection)
    begin
      Self.LockConnection;
    end;
  FConnection.OnLastReaderClosed :=
    procedure(pConnection: TAqDBConnection)
    begin
      Self.ReleaseConnection;
    end;
end;

destructor TAqDBPooledConnection<TBaseConnection>.Destroy;
begin
  FConnection.Free;

  inherited;
end;

function TAqDBPooledConnection<TBaseConnection>.GetCommandID(const pMasterCommandID: TAqID): TAqID;
var
  lPreparedQuery: TAqDBPreparedQuery;
begin
  if not FPreparedQueries.TryGetValue(pMasterCommandID, Result) then
  begin
    if not FMasterConnection.PreparedQueries.TryGetValue(pMasterCommandID, lPreparedQuery) then
    begin
      raise EAqInternal.CreateFmt('Command from ID %d not found.', [pMasterCommandID]);
    end;

    Result := FConnection.PrepareCommand(lPreparedQuery.SQL, lPreparedQuery.ParametersInitializer);

    try
      FPreparedQueries.Add(pMasterCommandID, Result);
    except
      FConnection.UnprepareCommand(Result);
      raise;
    end;
  end;
end;

function TAqDBPooledConnection<TBaseConnection>.GetIsLocked: Boolean;
begin
  Result := FLockerThread <> 0;
end;

procedure TAqDBPooledConnection<TBaseConnection>.ReleaseConnection;
begin
  Self.FMasterConnection.Pool.BeginWrite;

  try
    if FCalls > 0 then
    begin
      Dec(FCalls);
      if not FConnection.InTransaction and (FCalls = 0) then
      begin
        FLockerThread := 0;
        FLastUsedAt := Now;
      end;
    end;
  finally
    Self.FMasterConnection.Pool.EndWrite;
  end;
end;

procedure TAqDBPooledConnection<TBaseConnection>.LockConnection;
begin
  Self.FMasterConnection.Pool.BeginWrite;

  try
    if (FLockerThread <> 0) and (FLockerThread <> TThread.CurrentThread.ThreadID) then
    begin
      raise EAqInternal.Create('This context is already locked to another thread.');
    end;

    FLockerThread := TThread.CurrentThread.ThreadID;
    Inc(FCalls);
  finally
    Self.FMasterConnection.Pool.EndWrite;
  end;
end;

{ TAqDBFlushContextsThread<TBaseConnection> }

constructor TAqDBFlushContextsThread<TBaseConnection>.Create(
  const pPool: IAqList<TAqDBPooledConnection<TBaseConnection>>);
begin
  inherited Create(False);
  FPool := pPool;
end;

procedure TAqDBFlushContextsThread<TBaseConnection>.Execute;
var
  lNextAttempt: TDateTime;
  lI: Int32;
  lContext: TAqDBPooledConnection<TBaseConnection>;
  lDateTimeCut: TDateTime;
begin
  lNextAttempt := 0;

  while not Terminated do
  begin
    if lNextAttempt <= Now then
    begin
      lDateTimeCut := Now.IncSecond(-FAutoFlushContextsTime);
      FPool.BeginWrite;

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
        FPool.EndWrite;
      end;

      lNextAttempt := Now.IncSecond((FAutoFlushContextsTime div 4) + 1);
    end;
    Sleep(10);
  end;
end;

procedure TAqDBFlushContextsThread<TBaseConnection>.SetAutoFlushContextsTime(
  const pValue: UInt32);
begin
  FPool.BeginRead;

  try
    FAutoFlushContextsTime := pValue;
  finally
    FPool.EndRead;
  end;
end;

{ TAqDBPreparedQuery }

constructor TAqDBPreparedQuery.Create(const pSQL: string;
  const pParametersInitializer: TAqDBParametersHandlerMethod);
begin
  FSQL := pSQL;
  FParametersInitializer := pParametersInitializer;
end;

initialization
  TAqDBConnection._Initialize;

finalization
  TAqDBConnection._Finalize;

end.
