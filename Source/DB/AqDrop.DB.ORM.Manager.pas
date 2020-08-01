unit AqDrop.DB.ORM.Manager;

interface

uses
  System.SysUtils,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Observers.Intf,
  AqDrop.DB.Types,
  AqDrop.DB.Connection,
  AqDrop.DB.SQL.Intf,
  AqDrop.DB.Adapter,
  AqDrop.DB.ORM.Reader;

type
  TAqDBORMManager = class;

  TAqDBORMManagerClient = class
  strict private
    [weak]
    FORMManager: TAqDBORMManager;
  private
    class function CreateNew(const pORMManager: TAqDBORMManager): TAqDBORMManagerClient;
  strict protected
    procedure StartTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
  public
    constructor Create(const pORMManager: TAqDBORMManager); virtual;

    property ORMManager: TAqDBORMManager read FORMManager;
  end;

  TAqDBORMManager = class
  strict private
    FConnection: TAqDBConnection;
    FClients: IAqDictionary<string, TAqDBORMManagerClient>;
    FOnNewClient: IAqObservable<TAqDBORMManagerClient>;

    procedure FillParametersWithObjectValues(pParameters: IAqDBParameters; const pObject: TObject);

    function GetAdapter: TAqDBAdapter;
    function GetSQLSolver: TAqDBSQLSolver;

    procedure OpenAndMapObjects(const pORM: TAqDBORM; const pSelect: IAqDBSQLSelect; const pNewObjectFunction: TFunc<TObject>;
      const pOnReadData: TProc<IAqDBReader> = nil; const pParametersHandler: TAqDBParametersHandlerMethod = nil); overload;
    procedure OpenAndMapObjects(const pORM: TAqDBORM; const pSelect: string; const pNewObjectFunction: TFunc<TObject>;
      const pOnReadData: TProc<IAqDBReader> = nil; const pParametersHandler: TAqDBParametersHandlerMethod = nil); overload;

    procedure DoAndSaveDetails(const pMethod: TProc; const pMaster: TObject);
    procedure DoAdd(pInsert: IAqDBSQLInsert; const pObject: TObject);
    procedure DoUpdate(pUpdate: IAqDBSQLUpdate; const pObject: TObject);
    procedure DoPost(const pObject: TObject; const pFreeObject: Boolean = False);

    procedure ReloadObject(const pObject: TObject);

    class var FDefault: TAqDBORMManager;
  strict protected
    property Adapter: TAqDBAdapter read GetAdapter;
    property SQLSolver: TAqDBSQLSolver read GetSQLSolver;
  public
    constructor Create(const pConnection: TAqDBConnection);
    destructor Destroy; override;

    function BuildBaseSelect(const pORM: TAqDBORM): IAqDBSQLSelect; overload;
    function BuildBaseSelect(const pClass: TClass): IAqDBSQLSelect; overload;
    function BuildSelect(const pORM: TAqDBORM): IAqDBSQLSelect; overload;
    function BuildSelect(const pClass: TClass): IAqDBSQLSelect; overload;

    function BuildBaseInserts(const pORM: TAqDBORM): IAqResultList<IAqDBSQLInsert>; overload;
    function BuildBaseInserts(const pClass: TClass): IAqResultList<IAqDBSQLInsert>; overload;
    function BuildInserts(const pORM: TAqDBORM): IAqResultList<IAqDBSQLInsert>; overload;
    function BuildInserts(const pClass: TClass): IAqResultList<IAqDBSQLInsert>; overload;

    function BuildBaseUpdates(const pORM: TAqDBORM): IAqResultList<IAqDBSQLUpdate>; overload;
    function BuildBaseUpdates(const pClass: TClass): IAqResultList<IAqDBSQLUpdate>; overload;
    function BuildUpdates(const pORM: TAqDBORM): IAqResultList<IAqDBSQLUpdate>; overload;
    function BuildUpdates(const pClass: TClass): IAqResultList<IAqDBSQLUpdate>; overload;

    function BuildBaseDeletes(const pORM: TAqDBORM): IAqResultList<IAqDBSQLDelete>; overload;
    function BuildBaseDeletes(const pClass: TClass): IAqResultList<IAqDBSQLDelete>; overload;
    function BuildDeletes(const pORM: TAqDBORM): IAqResultList<IAqDBSQLDelete>; overload;
    function BuildDeletes(const pClass: TClass): IAqResultList<IAqDBSQLDelete>; overload;

    function CreateFilter: IAqDBSQLComposedCondition;

    function Get<T: class, constructor>(out pResultList: IAqResultList<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;
    function Get<T: class>(out pResultList: IAqResultList<T>; const pNewItemMethod: TFunc<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;

    function Get<T: class, constructor>(pSelect: IAqDBSQLSelect; out pResultList: IAqResultList<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;
    function Get<T: class>(pSelect: IAqDBSQLSelect; out pResultList: IAqResultList<T>;
      const pNewItemMethod: TFunc<T>; const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;

    function Get<T: class, constructor>(const pSelect: string; out pResultList: IAqResultList<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;
    function Get<T: class>(const pSelect: string; out pResultList: IAqResultList<T>;
      const pNewItemMethod: TFunc<T>; const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;

    function Get<T: class, constructor>(pFilter: IAqDBSQLComposedCondition; out pResultList: IAqResultList<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;
    function Get<T: class>(pFilter: IAqDBSQLComposedCondition; out pResultList: IAqResultList<T>;
      const pNewItemMethod: TFunc<T>; const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;

    function Get<T: class, constructor>(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
      out pResultList: IAqResultList<T>; const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;
    function Get<T: class>(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
      out pResultList: IAqResultList<T>; const pNewItemMethod: TFunc<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;

    function Get<T: class, constructor>(const pOnReadData: TProc<IAqDBReader> = nil):IAqResultList<T>; overload;
    function Get<T: class>(const pNewItemMethod: TFunc<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;

    function Get<T: class, constructor>(pSelect: IAqDBSQLSelect;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;
    function Get<T: class>(pSelect: IAqDBSQLSelect; const pNewItemMethod: TFunc<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;

    function Get<T: class, constructor>(const pSelect: string;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;
    function Get<T: class>(const pSelect: string; const pNewItemMethod: TFunc<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;

    function Get<T: class, constructor>(pFilter: IAqDBSQLComposedCondition;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;
    function Get<T: class>(pFilter: IAqDBSQLComposedCondition; const pNewItemMethod: TFunc<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;

    function Get<T: class, constructor>(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;
    function Get<T: class>(const pCustomizationMethod: TProc<IAqDBSQLSelect>; const pNewItemMethod: TFunc<T>;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;

    function GetByID<T: class, constructor>(const pID: Int64; out pResult: T): Boolean; overload;
    function GetByID<T: class>(const pID: Int64; out pResult: T; const pNewItemMethod: TFunc<T>): Boolean; overload;

    function GetByID<T: class, constructor>(const pID: Int64): T; overload;
    function GetByID<T: class>(const pID: Int64; const pNewItemMethod: TFunc<T>): T; overload;

    procedure Add(const pObject: TObject; const pFreeObject: Boolean = False); overload;
    procedure Add(const pInserts: IAqReadableList<IAqDBSQLInsert>; const pObject: TObject); overload;
    procedure Add(const pInsert: IAqDBSQLInsert; const pObject: TObject); overload;
    procedure Add<T: class>(const pCustomizationMethod: TProc<IAqDBSQLInsert>); overload;

    procedure Update(const pObject: TObject; const pFreeObject: Boolean = False); overload;
    procedure Update(const pUpdates: IAqReadableList<IAqDBSQLUpdate>; const pObject: TObject); overload;
    procedure Update(const pUpdate: IAqDBSQLUpdate; const pObject: TObject); overload;
    procedure Update<T: class>(const pCustomizationMethod: TProc<IAqDBSQLUpdate>); overload;

    procedure Delete(const pObject: TObject; const pFreeObject: Boolean = True); overload;
    procedure Delete(pDeletes: IAqReadableList<IAqDBSQLDelete>; const pObject: TObject); overload;
    procedure Delete(const pDelete: IAqDBSQLDelete; const pObject: TObject); overload;
    procedure Delete<T: class>(const pCustomizationMethod: TProc<IAqDBSQLDelete>); overload;

    procedure Post(const pObject: TObject; const pFreeObject: Boolean = False);

    procedure LoadDetails(const pMaster: TObject; const pDetailORM: TAqDBORM; const pNewDetailFunction: TFunc<TObject>);

    function ExecuteWithObject(const pSQLCommand: string; const pObject: TObject): Int64;

    function GetClient<T: TAqDBORMManagerClient>: T;

    property Connection: TAqDBConnection read FConnection;
    property OnNewClient: IAqObservable<TAqDBORMManagerClient> read FOnNewClient;

    class property Default: TAqDBORMManager read FDefault write FDefault;
  end;


implementation

uses
  System.Rtti,
  AqDrop.Core.Types,
  AqDrop.Core.RequirementTests,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Observers,
  AqDrop.Core.Collections,
  AqDrop.Core.Helpers.Rtti,
  AqDrop.Core.Helpers.TRttiType,
  AqDrop.DB.ORM.Attributes,
  AqDrop.DB.SQL;

{ TAqDBORMManager }

constructor TAqDBORMManager.Create(const pConnection: TAqDBConnection);
begin
  FConnection := pConnection;
  FConnection.AddDependent(Self);
  FClients := TAqDictionary<string, TAqDBORMManagerClient>.Create(
    [TAqKeyValueOwnership.kvoValue],
    TAqLockerType.lktMultiReaderExclusiveWriter);
  FOnNewClient := TAqObservationChannel<TAqDBORMManagerClient>.Create;
end;

function TAqDBORMManager.CreateFilter: IAqDBSQLComposedCondition;
begin
  Result := TAqDBSQLComposedCondition.Create;
end;

procedure TAqDBORMManager.Delete(pDeletes: IAqReadableList<IAqDBSQLDelete>; const pObject: TObject);
var
  lDelete: IAqDBSQLDelete;
begin
  FConnection.StartTransaction;

  try
    for lDelete in pDeletes do
    begin
      Delete(lDelete, pObject);
    end;

    FConnection.CommitTransaction;
  except
    FConnection.RollbackTransaction;
    raise;
  end;
end;

procedure TAqDBORMManager.Delete(const pDelete: IAqDBSQLDelete; const pObject: TObject);
begin
  ExecuteWithObject(SQLSolver.SolveDelete(pDelete), pObject);
end;

procedure TAqDBORMManager.Delete<T>(const pCustomizationMethod: TProc<IAqDBSQLDelete>);
var
  lDeletes: IAqResultList<IAqDBSQLDelete>;
  lDelete: IAqDBSQLDelete;
  lFilter: IAqDBSQLComposedCondition;
begin
  lDeletes := BuildBaseDeletes(T);

  FConnection.StartTransaction;

  try
    for lDelete in lDeletes do
    begin
      pCustomizationMethod(lDelete);
      FConnection.ExecuteCommand(lDelete);
    end;

    FConnection.CommitTransaction;
  except
    on E: Exception do
    begin
      FConnection.RollbackTransaction;
      E.RaiseOuterException(EAqInternal.Create('Impossible to execute the custom delete.'));
    end;
  end;
end;

destructor TAqDBORMManager.Destroy;
begin
  FConnection.RemoveDependent(Self);

  inherited;
end;

procedure TAqDBORMManager.DoAdd(pInsert: IAqDBSQLInsert; const pObject: TObject);
var
  lORM: TAqDBORM;
  lHasAutoIncrementColumn: Boolean;
  lTable: TAqDBORMTable;
  lAutoIncrementColumn: TAqDBORMColumn;
  lGeneratorName: string;
  lOldIDValue: Int64;

  procedure RegisterRevertIDObservers;
  var
    lDestructionObservable: IAqDestructionObservable;
    [weak] lDestructionObservableClosure: IAqDestructionObservable;
    lIDOnRollback: TAqID;
    lIDDestructionObserver: TAqID;
  begin
    if Supports(pObject, IAqDestructionObservable, lDestructionObservable) then
    begin
      lDestructionObservableClosure := lDestructionObservable;
      lIDOnRollback := FConnection.RegisterDoOnRollback(
        procedure
        begin
          lDestructionObservableClosure.UnregisterDestructionObserver(lIDDestructionObserver);
          lAutoIncrementColumn.SetObjectValue(pObject, TValue.From<Int64>(lOldIDValue));
        end);

      lIDDestructionObserver := lDestructionObservableClosure.RegisterDestructionObserver(
        procedure(pSender: TObject)
        begin
          FConnection.UnregisterDoOnRollback(lIDOnRollback);
        end);
    end;
  end;
begin
  lOldIDValue := 0;

  lORM := TAqDBORMReader.Instance.GetORM(pObject.ClassType);

  lHasAutoIncrementColumn := lORM.GetTable(pInsert.Table.Name, lTable) and
    lTable.HasAutoIncrementColumn(lAutoIncrementColumn);

  FConnection.StartTransaction;

  try
    if lHasAutoIncrementColumn then
    begin
      lOldIDValue := lAutoIncrementColumn.GetValue(pObject).AsInt64;

      if Adapter.AutoIncrementType = TAqDBAutoIncrementType.aiGenerator then
      begin
        if Assigned(lAutoIncrementColumn.Attribute) and (lAutoIncrementColumn.Attribute is AqAutoIncrementColumn) and
          AqAutoIncrementColumn(lAutoIncrementColumn.Attribute).IsGeneratorDefined then
        begin
          lGeneratorName := AqAutoIncrementColumn(lAutoIncrementColumn.Attribute).GeneratorName;
        end else begin
          lGeneratorName := SQLSolver.SolveGeneratorName(lTable.Name, lAutoIncrementColumn.Name);
        end;

        RegisterRevertIDObservers;

        lAutoIncrementColumn.SetObjectValue(pObject, TValue.From<Int64>(
          FConnection.GetAutoIncrementValue(lGeneratorName)));
      end;
    end;

    ExecuteWithObject(SQLSolver.SolveInsert(pInsert), pObject);

    if lHasAutoIncrementColumn and (Adapter.AutoIncrementType = TAqDBAutoIncrementType.aiAutoIncrement) then
    begin
      RegisterRevertIDObservers;

      lAutoIncrementColumn.SetObjectValue(pObject, TValue.From<Int64>(
        FConnection.GetAutoIncrementValue));
    end;

    FConnection.CommitTransaction;
  except
    FConnection.RollbackTransaction;
    raise;
  end;
end;

procedure TAqDBORMManager.DoAndSaveDetails(const pMethod: TProc; const pMaster: TObject);
var
  lORM: TAqDBORM;
  lHasDetails: Boolean;
  lDetail: IAqDBORMDetail;
  lDetailItems: IAqReadableList<TObject>;
  lObject: TObject;
  lDetailKeys: IAqReadableList<TAqDBORMColumn>;
  lMasterKeys: IAqReadableList<TAqDBORMColumn>;
  lI: Int32;
  lDeleteCommands: IAqResultList<IAqDBSQLDelete>;
  lDeleteCommand: IAqDBSQLDelete;
  lCondition: IAqDBSQLComposedCondition;
  lKeysCondition: IAqDBSQLComposedCondition;
  lKeyCondition: IAqDBSQLComposedCondition;
  lPKs: IAqReadableList<TAqDBORMColumn>;
begin
{TODO 3 -oTatu -cMelhoria: verificar como unificar esse método com o método de delete, a difenrença principal é que esse método aqui executa o save de details depois, o delete deleta details antes}
  lORM := TAqDBORMReader.Instance.GetORM(pMaster.ClassType);
  lHasDetails := lORM.HasDetails;
  if lHasDetails then
  begin
    FConnection.StartTransaction;
  end;

  try
    pMethod();

    if lHasDetails then
    begin
      for lDetail in lORM.Details do
      begin
        if lDetail.VerifyIfDetailsAreLoaded(pMaster) then
        begin
          if lDetail.ManagedDeletedItens then
          begin
            for lObject in lDetail.GetDeletedItens(pMaster) do
            begin
              Delete(lObject, False);
            end;
          end;

          lDetailItems := lDetail.GetItems(pMaster);

          lDetailKeys := lDetail.ORM.DetailKeys;
          lMasterKeys := lORM.PrimaryKeys;

          for lObject in lDetailItems do
          begin
{TODO 3 -oTatu -cMelhoria: hoje está com o post em cada detail, mas se a origem for um add, dá pra otimizar e chamar o add também aqui, ou seja, teria que ser dinâmico}
            for lI := 0 to lDetailKeys.Count - 1 do
            begin
              lDetailKeys[lI].SetObjectValue(lObject, lMasterKeys[lI].GetValue(pMaster));
            end;

            DoPost(lObject, False);
          end;

          if not lDetail.ManagedDeletedItens then
          begin
            lDeleteCommands := BuildBaseDeletes(lDetail.ORM);
            Assert(lDeleteCommands.Count = 1); {TODO 1 -oTatu -cPB: verificar como o sistema de exclusão vai funcionar com múltiplas tabelas detalhes, no caso de especialização}

            lDeleteCommand := lDeleteCommands.First;
            lCondition := lDeleteCommand.CustomizeCondition;

            for lI := 0 to lDetailKeys.Count - 1 do
            begin
              lCondition.AddColumnEqual(
                TAqDBSQLColumn.Create(lDetailKeys[lI].Name, lDeleteCommand.Table),
                TAqDBSQLValue.FromValue(lMasterKeys[lI].GetValue(pMaster), lMasterKeys[lI].&Type));
            end;

            if lDetailItems.Count > 0 then
            begin
              lPKs := lDetail.ORM.PrimaryKeys;
              lKeysCondition := CreateFilter;

              for lObject in lDetailItems do
              begin
                lKeyCondition := CreateFilter;

                for lI := 0 to lPKs.Count - 1 do
                begin
                  lKeyCondition.AddColumnEqual(
                    TAqDBSQLColumn.Create(lPKs[lI].Name, lDeleteCommand.Table),
                    TAqDBSQLValue.FromValue(lPKs[lI].GetValue(lObject), lPKs[lI].&Type));
                end;

                lKeysCondition.AddOr(lKeyCondition);
              end;

              lKeysCondition.Negate;
              lCondition.AddAnd(lKeysCondition);
            end;

            FConnection.ExecuteCommand(lDeleteCommand);
          end;
        end;
      end;
    end;

    if lHasDetails then
    begin
      FConnection.CommitTransaction;
    end;
  except
    on E: Exception do
    begin
      if lHasDetails then
      begin
        FConnection.RollbackTransaction;
      end;
      raise;
    end;
  end;
end;

procedure TAqDBORMManager.DoPost(const pObject: TObject; const pFreeObject: Boolean);
begin
  DoAndSaveDetails(
    procedure
    var
      lInserts: IAqResultList<IAqDBSQLInsert>;
      lUpdates: IAqResultList<IAqDBSQLUpdate>;
      lI: Int32;
      lSelect: IAqDBSQLSelect;
      lReader: IAqDBReader;
      lORM: TAqDBORM;
      lSpecialization: TAqDBORMTable<AqSpecialization>;
      lLink: TAqDBLink;
      lTableName: string;
      lMasterKey: TAqDBORMColumn;
      lForeignKey: TAqDBORMColumn;
    begin
{$IFNDEF AUTOREFCOUNT}
      try
{$ENDIF}
        lORM := TAqDBORMReader.Instance.GetORM(pObject.ClassType);

        lInserts := BuildInserts(pObject.ClassType);
        lUpdates := BuildUpdates(pObject.ClassType);

        if lInserts.Count <> lUpdates.Count then
        begin
          raise EAqInternal.Create('Count of Inserts and Updates of ' + pObject.ClassName + ' doesn''t match.');
        end;

        FConnection.StartTransaction;

        try
          for lI := 0 to lUpdates.Count - 1 do
          begin
            lSelect := TAqDBSQLSelect.Create(lUpdates[lI].Table.Name);
            lSelect.AddColumn(TAqDBSQLIntConstant.Create(1));
            lSelect.Condition := lUpdates[lI].Condition;
            lSelect.Limit := 1;

            lReader := FConnection.OpenQuery(lSelect,
              procedure(pParameters: IAqDBParameters)
              begin
                FillParametersWithObjectValues(pParameters, pObject);
              end);

            if lReader.Next then
            begin
              DoUpdate(lUpdates[lI], pObject);
            end else begin
              DoAdd(lInserts[lI], pObject);

              lTableName := lInserts[lI].Table.Name;
              if lORM.GetSpecializationUnderTable(lTableName, lSpecialization) then
              begin
                for lLink in lSpecialization.Attribute.Links do
                begin
                  if lORM.GetColumn(lTableName, lLink.MasterKey, lMasterKey) and
                    lORM.GetColumn(lSpecialization.Name, lLink.ForeignKey, lForeignKey) then
                  begin
                    lForeignKey.SetObjectValue(pObject, lMasterKey.GetValue(pObject));
                  end;
                end;
              end;
            end;
          end;

          FConnection.CommitTransaction;
        except
          FConnection.RollbackTransaction;
          raise;
        end;
{$IFNDEF AUTOREFCOUNT}
      finally
        if pFreeObject then
        begin
          pObject.Free;
        end;
      end;
{$ENDIF}
    end, pObject);
end;

procedure TAqDBORMManager.DoUpdate(pUpdate: IAqDBSQLUpdate; const pObject: TObject);
begin
  ExecuteWithObject(SQLSolver.SolveUpdate(pUpdate), pObject);
end;

procedure TAqDBORMManager.Delete(const pObject: TObject; const pFreeObject: Boolean);
var
  lORM: TAqDBORM;
  lDetail: IAqDBORMDetail;
  lObject: TObject;
  lHasDetails: Boolean;
begin
  lORM := TAqDBORMReader.Instance.GetORM(pObject.ClassType);
  lHasDetails := lORM.HasDetails;
  if lHasDetails then
  begin
    FConnection.StartTransaction;
  end;

  try
    if lHasDetails then
    begin
      for lDetail in lORM.Details do
      begin
        for lObject in lDetail.GetDeletedItens(pObject) do
        begin
          Delete(lObject, False);
        end;

        for lObject in lDetail.GetItems(pObject) do
        begin
          Delete(lObject, False);
        end;
      end;
    end;

    Delete(BuildDeletes(pObject.ClassType), pObject);

    if lHasDetails then
    begin
      FConnection.CommitTransaction;
    end;
  except
    on E: Exception do
    begin
      if lHasDetails then
      begin
        FConnection.RollbackTransaction;
      end;
      raise;
    end;
  end;

{$IFNDEF AUTOREFCOUNT}
  if pFreeObject then
  begin
    pObject.Free;
  end;
{$ENDIF}
end;

procedure TAqDBORMManager.FillParametersWithObjectValues(pParameters: IAqDBParameters; const pObject: TObject);
var
  lI: Int32;
  lColumn: TAqDBORMColumn;
  lORM: TAqDBORM;
begin
  lORM := TAqDBORMReader.Instance.GetORM(pObject.ClassType);

  for lI := 0 to pParameters.Count - 1 do
  begin
    if lORM.GetColumn(pParameters[lI].Name, lColumn) then
    begin
      lColumn.SetDBValue(pObject, pParameters[lI]);
    end;
  end;
end;

function TAqDBORMManager.Get<T>(out pResultList: IAqResultList<T>; const pOnReadData: TProc<IAqDBReader>): Boolean;
begin
  Result := Get<T>(BuildSelect(T), pResultList, pOnReadData);
end;

function TAqDBORMManager.Get<T>(pSelect: IAqDBSQLSelect; out pResultList: IAqResultList<T>;
  const pOnReadData: TProc<IAqDBReader> = nil): Boolean;
begin
  Result := Get<T>(SQLSolver.SolveSelect(pSelect), pResultList, pOnReadData);
end;

function TAqDBORMManager.Get<T>(const pSelect: string; out pResultList: IAqResultList<T>;
  const pOnReadData: TProc<IAqDBReader> = nil): Boolean;
var
  lList: TAqResultList<T>;
begin
  Result := Get<T>(pSelect, pResultList,
    function: T
    begin
      Result := T.Create;
    end, pOnReadData);
end;

procedure TAqDBORMManager.Add(const pObject: TObject; const pFreeObject: Boolean);
begin
  DoAndSaveDetails(
    procedure
    begin
      Add(BuildInserts(pObject.ClassType), pObject);
    end, pObject);

{$IFNDEF AUTOREFCOUNT}
  if pFreeObject then
  begin
    pObject.Free;
  end;
{$ENDIF}
end;

procedure TAqDBORMManager.Post(const pObject: TObject; const pFreeObject: Boolean = False);
begin
  DoPost(pObject, pFreeObject);

  if not pFreeObject then
  begin
    ReloadObject(pObject);
  end;
end;

procedure TAqDBORMManager.ReloadObject(const pObject: TObject);
var
  lClassType: TRttiType;
  lORM: TAqDBORM;
  lDeletes: IAqResultList<IAqDBSQLDelete>;
  lSelect: IAqDBSQLSelect;
  lDetail: IAqDBORMDetail;
begin
  lClassType := TAqRtti.&Implementation.GetType(pObject.ClassType);

  if lClassType.HasAttributeInTheHierarchy<AqAutoReload> then
  begin
    lORM := TAqDBORMReader.Instance.GetORM(pObject.ClassType);
    if lORM.HasDetails then
    begin
      for lDetail in lORM.Details do
      begin
        lDetail.Unload(pObject);
      end;
    end;

    lDeletes := BuildDeletes(pObject.ClassType);
    TAqRequirement.Test(Assigned(lDeletes) and (lDeletes.Count > 0), 'Impossible to reload the object.');

    lSelect := BuildSelect(lORM);
    lSelect.CustomizeCondition(lDeletes.Last.Condition);

    OpenAndMapObjects(lORM, lSelect,
      function: TObject
      begin
        Result := pObject;
      end, nil,
      procedure(pParameters: IAqDBParameters)
      begin
        FillParametersWithObjectValues(pParameters, pObject);
      end);
  end;
end;

procedure TAqDBORMManager.Update(const pUpdates: IAqReadableList<IAqDBSQLUpdate>; const pObject: TObject);
var
  lUpdate: IAqDBSQLUpdate;
begin
  FConnection.StartTransaction;

  try
    for lUpdate in pUpdates do
    begin
      Update(lUpdate, pObject);
    end;
    FConnection.CommitTransaction;
  except
    FConnection.RollbackTransaction;
    raise;
  end;

  ReloadObject(pObject);
end;

procedure TAqDBORMManager.Update(const pUpdate: IAqDBSQLUpdate; const pObject: TObject);
begin
  DoUpdate(pUpdate, pObject);
  ReloadObject(pObject);
end;

procedure TAqDBORMManager.Update<T>(const pCustomizationMethod: TProc<IAqDBSQLUpdate>);
var
  lUpdates: IAqResultList<IAqDBSQLUpdate>;
  lUpdate: IAqDBSQLUpdate;
begin
  lUpdates := BuildBaseUpdates(T);

  FConnection.StartTransaction;

  try
    for lUpdate in lUpdates do
    begin
      pCustomizationMethod(lUpdate);
      FConnection.ExecuteCommand(lUpdate);
    end;
  except
    FConnection.RollbackTransaction;
    raise EAqInternal.Create('Impossible to execute the custom update.');
  end;
end;

procedure TAqDBORMManager.Update(const pObject: TObject; const pFreeObject: Boolean);
begin
  DoAndSaveDetails(
    procedure
    begin
      Update(BuildUpdates(pObject.ClassType), pObject);
    end, pObject);

{$IFNDEF AUTOREFCOUNT}
  if pFreeObject then
  begin
    pObject.Free;
  end;
{$ENDIF}
end;

procedure TAqDBORMManager.Add(const pInsert: IAqDBSQLInsert; const pObject: TObject);
begin
  DoAdd(pInsert, pObject);
  ReloadObject(pObject);
end;

procedure TAqDBORMManager.Add<T>(const pCustomizationMethod: TProc<IAqDBSQLInsert>);
var
  lInserts: IAqResultList<IAqDBSQLInsert>;
  lInsert: IAqDBSQLInsert;
begin
  lInserts := BuildBaseInserts(T);

  FConnection.StartTransaction;

  try
    for lInsert in lInserts do
    begin
      pCustomizationMethod(lInsert);
      FConnection.ExecuteCommand(lInsert);
    end;
  except
    FConnection.RollbackTransaction;
    raise EAqInternal.Create('Impossible to execute the custom insert.');
  end;
end;

procedure TAqDBORMManager.Add(const pInserts: IAqReadableList<IAqDBSQLInsert>; const pObject: TObject);
var
  lInsert: IAqDBSQLInsert;
begin
  FConnection.StartTransaction;

  try
    for lInsert in pInserts do
    begin
      Add(lInsert, pObject);
    end;
    FConnection.CommitTransaction;
  except
    FConnection.RollbackTransaction;
    raise;
  end;

  ReloadObject(pObject);
end;

function TAqDBORMManager.BuildBaseDeletes(const pORM: TAqDBORM): IAqResultList<IAqDBSQLDelete>;
var
  lDeletes: TAqResultList<IAqDBSQLDelete>;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
begin
  lDeletes := TAqResultList<IAqDBSQLDelete>.Create;

  try
    lDeletes.Add(TAqDBSQLDelete.Create(pORM.MainTable.Name));

    if pORM.HasSpecializations then
    begin
      for lSpecialization in pORM.Specializations do
      begin
        lDeletes.Insert(0, TAqDBSQLDelete.Create(lSpecialization.Name));
      end;
    end;
  except
    lDeletes.Free;
    raise;
  end;

  Result := lDeletes;
end;

function TAqDBORMManager.BuildBaseInserts(const pORM: TAqDBORM): IAqResultList<IAqDBSQLInsert>;
var
  lInserts: TAqResultList<IAqDBSQLInsert>;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
begin
  lInserts := TAqResultList<IAqDBSQLInsert>.Create;

  try
    lInserts.Add(TAqDBSQLInsert.Create(pORM.MainTable.Name));

    if pORM.HasSpecializations then
    begin
      for lSpecialization in pORM.Specializations do
      begin
        lInserts.Add(TAqDBSQLInsert.Create(lSpecialization.Name));
      end;
    end;
  except
    lInserts.Free;
    raise;
  end;

  Result := lInserts;
end;

function TAqDBORMManager.BuildBaseSelect(const pClass: TClass): IAqDBSQLSelect;
begin
  Result := BuildBaseSelect(TAqDBORMReader.Instance.GetORM(pClass));
end;

function TAqDBORMManager.BuildBaseUpdates(const pClass: TClass): IAqResultList<IAqDBSQLUpdate>;
begin
  Result := BuildBaseUpdates(TAqDBORMReader.Instance.GetORM(pClass));
end;

function TAqDBORMManager.BuildBaseSelect(const pORM: TAqDBORM): IAqDBSQLSelect;
var
  lSelect: TAqDBSQLSelect;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
  lCondition: TAqDBSQLComposedCondition;
  lLink: TAqDBLink;
  lMasterSource: TAqDBSQLSource;
  lSpecializationSource: TAqDBSQLSource;

  procedure AddLinkCondition(const pCondition: TAqDBSQLCondition);
  begin
    if not Assigned(lCondition) then
    begin
      lCondition := TAqDBSQLComposedCondition.Create(pCondition);
    end else begin
      lCondition.AddCondition(TAqDBSQLBooleanOperator.boAnd, pCondition);
    end;
  end;
begin
  lSelect := nil;
  try
    lMasterSource := TAqDBSQLTable.Create(pORM.MainTable.Name);
    lSelect := TAqDBSQLSelect.Create(lMasterSource);

    if pORM.HasSpecializations then
    begin
      for lSpecialization in pORM.Specializations do
      begin
        if lSpecialization.Attribute.Links.Count = 0 then
        begin
          raise EAqInternal.Create('The specialization has no links.');
        end;

        lSpecializationSource := TAqDBSQLTable.Create(lSpecialization.Name);
        lCondition := nil;

        for lLink in lSpecialization.Attribute.Links do
        begin
          AddLinkCondition(TAqDBSQLComparisonCondition.Create(
            TAqDBSQLColumn.Create(lLink.MasterKey, lMasterSource),
            TAqDBSQLComparison.cpEqual,
            TAqDBSQLColumn.Create(lLink.ForeignKey, lSpecializationSource)));
        end;

        lSelect.AddJoin(TAqDBSQLJoinType.jtInnerJoin, lSpecializationSource, lCondition);

        lMasterSource := lSpecializationSource;
      end;
    end;
  except
    on E: Exception do
    begin
      lSelect.Free;
      E.RaiseOuterException(EAqInternal.CreateFmt('It wasn''t possible to build the select for the %s class.',
        [pORM.ORMClass.QualifiedClassName]));
    end;
  end;

  Result := lSelect;
end;

function TAqDBORMManager.BuildBaseUpdates(const pORM: TAqDBORM): IAqResultList<IAqDBSQLUpdate>;
var
  lUpdates: TAqResultList<IAqDBSQLUpdate>;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
begin
  lUpdates := TAqResultList<IAqDBSQLUpdate>.Create;

  try
    lUpdates.Add(TAqDBSQLUpdate.Create(pORM.MainTable.Name));

    if pORM.HasSpecializations then
    begin
      for lSpecialization in pORM.Specializations do
      begin
        lUpdates.Add(TAqDBSQLUpdate.Create(lSpecialization.Name));
      end;
    end;
  except
    lUpdates.Free;
    raise;
  end;

  Result := lUpdates;
end;

function TAqDBORMManager.BuildDeletes(const pORM: TAqDBORM): IAqResultList<IAqDBSQLDelete>;
var
  lDeletes: TAqResultList<IAqDBSQLDelete>;
  lPKs: IAqList<TAqDBORMColumn>;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
  lFirstCondition: TAqDBSQLComparisonCondition;
  lComposedCondition: TAqDBSQLComposedCondition;

  function CreateCondition(const pColumnName: string; pSourceTable: IAqDBSQLTable): TAqDBSQLComparisonCondition;
  begin
    Result := TAqDBSQLComparisonCondition.Create(TAqDBSQLColumn.Create(pColumnName, pSourceTable),
      TAqDBSQLComparison.cpEqual, TAqDBSQLParameter.Create(pColumnName));
  end;

  procedure AddCondition(const pColumnName: string; pSourceTable: IAqDBSQLTable);
  begin
    if not Assigned(lFirstCondition) then
    begin
      lFirstCondition := CreateCondition(pColumnName, pSourceTable);
    end else begin
      if not Assigned(lComposedCondition) then
      begin
        lComposedCondition := TAqDBSQLComposedCondition.Create(lFirstCondition);
      end;

      lComposedCondition.AddCondition(TAqDBSQLBooleanOperator.boAnd, CreateCondition(pColumnName, pSourceTable));
    end;
  end;

  procedure AddDelete(pTable: TAqDBORMTable<AqTable>);
  var
    lColumn: TAqDBORMColumn;
    lDelete: IAqDBSQLDelete;
  begin
    lFirstCondition := nil;
    lComposedCondition := nil;

    lDelete := TAqDBSQLDelete.Create(pTable.Name);

    if TAqDBTableMappingProperty.tmpInheritPKs in pTable.Attribute.MappingProperties then
    begin
      for lColumn in lPKs do
      begin
        AddCondition(lColumn.Name, lDelete.Table);
      end;
    end;

    for lColumn in pTable.Columns do
    begin
      if Assigned(lColumn.Attribute) and (lColumn.Attribute.PrimaryKey) then
      begin
        AddCondition(lColumn.Name, lDelete.Table);
        lPKs.Add(lColumn);
      end;
    end;

    if Assigned(lComposedCondition) then
    begin
      lDelete.Condition := lComposedCondition;
    end else if Assigned(lFirstCondition) then
    begin
      lDelete.Condition := lFirstCondition;
    end;

    lDeletes.Insert(0, lDelete);
  end;
begin
  lDeletes := TAqResultList<IAqDBSQLDelete>.Create;

  try
    lPKs := TAqList<TAqDBORMColumn>.Create;

    AddDelete(pORM.MainTable);

    if pORM.HasSpecializations then
    begin
      for lSpecialization in pORM.Specializations do
      begin
        AddDelete(TAqDBORMTable<AqTable>(lSpecialization));
      end;
    end;
  except
    lDeletes.Free;
    raise;
  end;

  Result := lDeletes;
end;

function TAqDBORMManager.BuildInserts(const pORM: TAqDBORM): IAqResultList<IAqDBSQLInsert>;
var
  lInserts: TAqResultList<IAqDBSQLInsert>;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
  lPKs: IAqList<TAqDBORMColumn>;
  lAutoIncrementType: TAqDBAutoIncrementType;

  procedure AddInsert(const pTable: TAqDBORMTable<AqTable>);
  var
    lInsert: IAqDBSQLInsert;
    lColumn: TAqDBORMColumn;
  begin
    lInsert := TAqDBSQLInsert.Create(pTable.Name);

    if TAqDBTableMappingProperty.tmpInheritPKs in pTable.Attribute.MappingProperties then
    begin
      for lColumn in lPKs do
      begin
        lInsert.AddAssignment(TAqDBSQLColumn.Create(lColumn.Name), TAqDBSQLParameter.Create(lColumn.Name));
      end;
    end;

    for lColumn in pTable.Columns do
    begin
      if Assigned(lColumn.Attribute) and (lColumn.Attribute.PrimaryKey) then
      begin
        lPKs.Add(lColumn);
      end;

      if (lAutoIncrementType = TAqDBAutoIncrementType.aiGenerator) or not Assigned(lColumn.Attribute) or not
        lColumn.Attribute.AutoIncrement then
      begin
        lInsert.AddAssignment(TAqDBSQLColumn.Create(lColumn.Name), TAqDBSQLParameter.Create(lColumn.Name));
      end;
    end;

    lInserts.Add(lInsert);
  end;
begin
  lInserts := TAqResultList<IAqDBSQLInsert>.Create;

  try
    lAutoIncrementType := Adapter.AutoIncrementType;
    lPKs := TAqList<TAqDBORMColumn>.Create;

    AddInsert(pORM.MainTable);

    if pORM.HasSpecializations then
    begin
      for lSpecialization in pORM.Specializations do
      begin
        AddInsert(TAqDBORMTable<AqTable>(lSpecialization));
      end;
    end;
  except
    lInserts.Free;
    raise;
  end;

  Result := lInserts;
end;

function TAqDBORMManager.BuildSelect(const pClass: TClass): IAqDBSQLSelect;
begin
  Result := BuildSelect(TAqDBORMReader.Instance.GetORM(pClass));
end;

function TAqDBORMManager.BuildUpdates(const pClass: TClass): IAqResultList<IAqDBSQLUpdate>;
begin
  Result := BuildUpdates(TAqDBORMReader.Instance.GetORM(pClass));
end;

function TAqDBORMManager.BuildSelect(const pORM: TAqDBORM): IAqDBSQLSelect;
var
  lI: Int32;

  procedure AddColumns(const pORMTable: TAqDBORMTable; const pSource: IAqDBSQLSource);
  var
    lColumn: TAqDBORMColumn;
  begin
    for lColumn in pORMTable.Columns do
    begin
      Result.AddColumn(lColumn.Name, lColumn.Alias, pSource);
    end;
  end;
begin
  Result := BuildBaseSelect(pORM);

  AddColumns(pORM.MainTable, Result.Source);

  if pORM.HasSpecializations then
  begin
    for lI := 0 to pORM.Specializations.Count - 1 do
    begin
      AddColumns(pORM.Specializations[lI], Result.Joins[lI].Source);
    end;
  end;
end;

function TAqDBORMManager.BuildUpdates(const pORM: TAqDBORM): IAqResultList<IAqDBSQLUpdate>;
var
  lUpdates: TAqResultList<IAqDBSQLUpdate>;
  lPKs: IAqList<TAqDBORMColumn>;
  lSpecialization: TAqDBORMTable<AqSpecialization>;
  lFirstCondition: TAqDBSQLComparisonCondition;
  lComposedCondition: TAqDBSQLComposedCondition;

  function CreateCondition(const pColumnName: string): TAqDBSQLComparisonCondition;
  begin
    Result := TAqDBSQLComparisonCondition.Create(TAqDBSQLColumn.Create(pColumnName),
      TAqDBSQLComparison.cpEqual, TAqDBSQLParameter.Create(pColumnName));
  end;

  procedure AddCondition(const pColumnName: string);
  begin
    if not Assigned(lFirstCondition) then
    begin
      lFirstCondition := CreateCondition(pColumnName);
    end else begin
      if not Assigned(lComposedCondition) then
      begin
        lComposedCondition := TAqDBSQLComposedCondition.Create(lFirstCondition);
      end;

      lComposedCondition.AddCondition(TAqDBSQLBooleanOperator.boAnd, CreateCondition(pColumnName));
    end;
  end;

  procedure AddUpdate(pTable: TAqDBORMTable<AqTable>);
  var
    lColumn: TAqDBORMColumn;
    lUpdate: IAqDBSQLUpdate;
  begin
    lFirstCondition := nil;
    lComposedCondition := nil;

    lUpdate := TAqDBSQLUpdate.Create(pTable.Name);

    if TAqDBTableMappingProperty.tmpInheritPKs in pTable.Attribute.MappingProperties then
    begin
      for lColumn in lPKs do
      begin
        AddCondition(lColumn.Name);
      end;
    end;

    for lColumn in pTable.Columns do
    begin
      if Assigned(lColumn.Attribute) and (lColumn.Attribute.PrimaryKey) then
      begin
        AddCondition(lColumn.Name);
        lPKs.Add(lColumn);
      end else begin
        lUpdate.AddAssignment(TAqDBSQLColumn.Create(lColumn.Name), TAqDBSQLParameter.Create(lColumn.Name));
      end;
    end;

    if Assigned(lComposedCondition) then
    begin
      lUpdate.Condition := lComposedCondition;
    end else if Assigned(lFirstCondition) then
    begin
      lUpdate.Condition := lFirstCondition;
    end;

    lUpdates.Add(lUpdate);
  end;
begin
  lUpdates := TAqResultList<IAqDBSQLUpdate>.Create;

  try
    lPKs := TAqList<TAqDBORMColumn>.Create;

    AddUpdate(pORM.MainTable);

    if pORM.HasSpecializations then
    begin
      for lSpecialization in pORM.Specializations do
      begin
        AddUpdate(TAqDBORMTable<AqTable>(lSpecialization));
      end;
    end;
  except
    lUpdates.Free;
    raise;
  end;

  Result := lUpdates;
end;

function TAqDBORMManager.ExecuteWithObject(const pSQLCommand: string; const pObject: TObject): Int64;
begin
  if Assigned(pObject) then
  begin
    Result := FConnection.ExecuteCommand(pSQLCommand,
      procedure(pParameters: IAqDBParameters)
      begin
        FillParametersWithObjectValues(pParameters, pObject);
      end);
  end else begin
    Result := FConnection.ExecuteCommand(pSQLCommand);
  end;
end;

function TAqDBORMManager.Get<T>(pSelect: IAqDBSQLSelect; const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(pSelect, Result, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.Get<T>(const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(Result, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.Get<T>(pFilter: IAqDBSQLComposedCondition; out pResultList: IAqResultList<T>;
  const pOnReadData: TProc<IAqDBReader>): Boolean;
var
  lSelect: IAqDBSQLSelect;
begin
  lSelect := BuildSelect(T);
  lSelect.CustomizeCondition(pFilter);
  Result := Get<T>(lSelect, pResultList, pOnReadData);
end;

function TAqDBORMManager.Get<T>(const pSelect: string; const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(pSelect, Result, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.Get<T>(pFilter: IAqDBSQLComposedCondition;
  const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(pFilter, Result, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.GetByID<T>(const pID: Int64): T;
begin
  if not GetByID<T>(pID, Result) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.GetClient<T>: T;
var
  lClient: TAqDBORMManagerClient;
begin
  FClients.BeginWrite;

  try
    if not FClients.TryGetValue(T.QualifiedClassName, lClient) then
    begin
      lClient := T.CreateNew(Self);
      FClients.Add(T.QualifiedClassName, lClient);

      FOnNewClient.Notify(lClient);
    end;

    Result := T(lClient);
  finally
    FClients.EndWrite;
  end;
end;

function TAqDBORMManager.GetSQLSolver: TAqDBSQLSolver;
begin
  Result := nil;

  try
    Result := Adapter.SQLSolver;

    if not Assigned(Result) then
    begin
      raise EAqInternal.Create('The manager''s adapter has no SQL solver.');
    end;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to obtain the SQL solver.'));
    end;
  end;
end;

procedure TAqDBORMManager.LoadDetails(const pMaster: TObject; const pDetailORM: TAqDBORM;
  const pNewDetailFunction: TFunc<TObject>);
var
  lDetailSelect: IAqDBSQLSelect;
  lMasterKeys: IAqReadableList<TAqDBORMColumn>;
  lDetailKeys: IAqReadableList<TAqDBORMColumn>;
  lCondition: IAqDBSQLComposedCondition;
  lI: Int32;
begin
  lDetailSelect := BuildSelect(pDetailORM);

  lMasterKeys := TAqDBORMReader.Instance.GetORM(pMaster.ClassType).PrimaryKeys;
  lDetailKeys := pDetailORM.DetailKeys;

  lCondition := lDetailSelect.CustomizeCondition;

  for lI := 0 to lMasterKeys.Count - 1 do
  begin
    lCondition.AddColumnEqual(
      TAqDBSQLColumn.Create(lDetailKeys[lI].Name, lDetailSelect.Source),
      TAqDBSQLValue.FromValue(lMasterKeys[lI].GetValue(pMaster), lMasterKeys[lI].&Type));
  end;

  OpenAndMapObjects(pDetailORM, lDetailSelect, pNewDetailFunction);
end;

procedure TAqDBORMManager.OpenAndMapObjects(const pORM: TAqDBORM; const pSelect: IAqDBSQLSelect;
  const pNewObjectFunction: TFunc<TObject>; const pOnReadData: TProc<IAqDBReader>; const pParametersHandler: TAqDBParametersHandlerMethod);
begin
  OpenAndMapObjects(pORM, SQLSolver.SolveSelect(pSelect), pNewObjectFunction, pOnReadData, pParametersHandler);
end;

procedure TAqDBORMManager.OpenAndMapObjects(const pORM: TAqDBORM; const pSelect: string;
  const pNewObjectFunction: TFunc<TObject>; const pOnReadData: TProc<IAqDBReader>; const pParametersHandler: TAqDBParametersHandlerMethod);
var
  lReader: IAqDBReader;
  lObject: TObject;
  lI: Int32;
  lColumn: TAqDBORMColumn;
  lDetail: IAqDBORMDetail;
begin
  lReader := FConnection.OpenQuery(pSelect, pParametersHandler);

  while lReader.Next do
  begin
    lObject := pNewObjectFunction();

    for lI := 0 to lReader.Count - 1 do
    begin
      if pORM.GetColumn(lReader[lI].Name, lColumn) then
      begin
        try
          lColumn.SetObjectValue(lObject, lReader[lI]);
        except
          on E: Exception do
          begin
            E.RaiseOuterException(EAqInternal.Create('The ' + lColumn.Name + ' column could not be loaded.'));
          end;
        end;
      end;
    end;

    if pORM.HasDetails then
    begin
      for lDetail in pORM.Details do
      begin
        if not lDetail.LazyLoadingAvailable then
        begin
          LoadDetails(lObject, lDetail.ORM,
            function: TObject
            begin
              Result := lDetail.AddItem(lObject);
            end);
        end;
      end;
    end;

    if Assigned(pOnReadData) then
    begin
      pOnReadData(lReader);
    end;
  end;
end;

function TAqDBORMManager.GetByID<T>(const pID: Int64; out pResult: T): Boolean;
var
  lResultList: IAqResultList<T>;
begin
  Result := Get<T>(CreateFilter.AddColumnEqual(TAqDBORMReader.Instance.GetORM(T).UniqueKey.Name, pID), lResultList);
  if Result then
  begin
    pResult := lResultList.Extract;
  end;
end;

function TAqDBORMManager.Get<T>(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
  out pResultList: IAqResultList<T>; const pOnReadData: TProc<IAqDBReader>): Boolean;
var
  lSelect: IAqDBSQLSelect;
begin
  lSelect := BuildSelect(T);

  if Assigned(pCustomizationMethod) then
  begin
    pCustomizationMethod(lSelect);
  end;

  Result := Get<T>(lSelect, pResultList, pOnReadData);
end;

function TAqDBORMManager.Get<T>(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
  const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(pCustomizationMethod, Result, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.Get<T>(const pSelect: string; const pNewItemMethod: TFunc<T>;
  const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(pSelect, Result, pNewItemMethod, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.Get<T>(pSelect: IAqDBSQLSelect; const pNewItemMethod: TFunc<T>;
  const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(pSelect, Result, pNewItemMethod, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.Get<T>(const pNewItemMethod: TFunc<T>;
  const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(Result, pNewItemMethod, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.Get<T>(const pCustomizationMethod: TProc<IAqDBSQLSelect>; out pResultList: IAqResultList<T>;
  const pNewItemMethod: TFunc<T>; const pOnReadData: TProc<IAqDBReader>): Boolean;
var
  lSelect: IAqDBSQLSelect;
begin
  lSelect := BuildSelect(T);

  if Assigned(pCustomizationMethod) then
  begin
    pCustomizationMethod(lSelect);
  end;

  Result := Get<T>(lSelect, pResultList, pNewItemMethod, pOnReadData);
end;

function TAqDBORMManager.Get<T>(pFilter: IAqDBSQLComposedCondition; out pResultList: IAqResultList<T>;
  const pNewItemMethod: TFunc<T>; const pOnReadData: TProc<IAqDBReader>): Boolean;
var
  lSelect: IAqDBSQLSelect;
begin
  lSelect := BuildSelect(T);
  lSelect.CustomizeCondition(pFilter);
  Result := Get<T>(lSelect, pResultList, pNewItemMethod, pOnReadData);
end;

function TAqDBORMManager.Get<T>(out pResultList: IAqResultList<T>; const pNewItemMethod: TFunc<T>;
  const pOnReadData: TProc<IAqDBReader>): Boolean;
begin
  Result := Get<T>(BuildSelect(T), pResultList, pNewItemMethod, pOnReadData);
end;

function TAqDBORMManager.Get<T>(const pSelect: string; out pResultList: IAqResultList<T>;
  const pNewItemMethod: TFunc<T>; const pOnReadData: TProc<IAqDBReader>): Boolean;
var
  lList: TAqResultList<T>;
begin
  lList := nil;

  try
    OpenAndMapObjects(TAqDBORMReader.Instance.GetORM(T), pSelect,
      function: TObject
      begin
        if not Assigned(lList) then
        begin
          lList := TAqResultList<T>.Create(True);
        end;

        lList.Add(pNewItemMethod);
        Result := lList.Last;
      end, pOnReadData);
  except
    lList.Free;
    raise;
  end;

  Result := Assigned(lList);
  pResultList := lList;
end;

function TAqDBORMManager.Get<T>(pSelect: IAqDBSQLSelect; out pResultList: IAqResultList<T>;
  const pNewItemMethod: TFunc<T>; const pOnReadData: TProc<IAqDBReader>): Boolean;
begin
  Result := Get<T>(SQLSolver.SolveSelect(pSelect), pResultList, pNewItemMethod, pOnReadData);
end;

function TAqDBORMManager.Get<T>(pFilter: IAqDBSQLComposedCondition; const pNewItemMethod: TFunc<T>;
  const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(pFilter, Result, pNewItemMethod, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.Get<T>(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
  const pNewItemMethod: TFunc<T>; const pOnReadData: TProc<IAqDBReader>): IAqResultList<T>;
begin
  if not Get<T>(pCustomizationMethod, Result, pNewItemMethod, pOnReadData) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.GetAdapter: TAqDBAdapter;
begin
  Result := nil;

  try
    if not Assigned(FConnection) then
    begin
      raise EAqInternal.Create('The ORM manager has no connection associated.');
    end;

    Result := FConnection.Adapter;

    if not Assigned(Result) then
    begin
      raise EAqInternal.Create('The manager''s connection has no adapter.');
    end;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It wasn''t possible to get the Adapter.'));
    end;
  end;
end;

function TAqDBORMManager.GetByID<T>(const pID: Int64; const pNewItemMethod: TFunc<T>): T;
begin
  if not GetByID<T>(pID, Result, pNewItemMethod) then
  begin
    Result := nil;
  end;
end;

function TAqDBORMManager.GetByID<T>(const pID: Int64; out pResult: T; const pNewItemMethod: TFunc<T>): Boolean;
var
  lResultList: IAqResultList<T>;
begin
  Result := Get<T>(CreateFilter.AddColumnEqual(TAqDBORMReader.Instance.GetORM(T).UniqueKey.Name, pID), lResultList,
    pNewItemMethod);
  if Result then
  begin
    pResult := lResultList.Extract;
  end;
end;

function TAqDBORMManager.BuildBaseDeletes(const pClass: TClass): IAqResultList<IAqDBSQLDelete>;
begin
  Result := BuildBaseDeletes(TAqDBORMReader.Instance.GetORM(pClass));
end;

function TAqDBORMManager.BuildBaseInserts(const pClass: TClass): IAqResultList<IAqDBSQLInsert>;
begin
  Result := BuildBaseInserts(TAqDBORMReader.Instance.GetORM(pClass));
end;

function TAqDBORMManager.BuildDeletes(const pClass: TClass): IAqResultList<IAqDBSQLDelete>;
begin
  Result := BuildDeletes(TAqDBORMReader.Instance.GetORM(pClass));
end;

function TAqDBORMManager.BuildInserts(const pClass: TClass): IAqResultList<IAqDBSQLInsert>;
begin
  Result := BuildInserts(TAqDBORMReader.Instance.GetORM(pClass));
end;

{ TAqDBORMManagerClient }

procedure TAqDBORMManagerClient.CommitTransaction;
begin
  FORMManager.Connection.CommitTransaction;
end;

constructor TAqDBORMManagerClient.Create(const pORMManager: TAqDBORMManager);
begin
  if not Assigned(pORMManager) then
  begin
    raise EAqInternal.Create('Não foi possível instanciar ' + Self.QualifiedClassName + ' sem um ORMManager.');
  end;

  FORMManager := pORMManager;
end;

class function TAqDBORMManagerClient.CreateNew(const pORMManager: TAqDBORMManager): TAqDBORMManagerClient;
begin
  Result := Self.Create(pORMManager);
end;

procedure TAqDBORMManagerClient.RollbackTransaction;
begin
  FORMManager.Connection.RollbackTransaction;
end;

procedure TAqDBORMManagerClient.StartTransaction;
begin
  FORMManager.Connection.StartTransaction;
end;

end.
