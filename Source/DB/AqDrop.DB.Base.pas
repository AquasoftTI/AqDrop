unit AqDrop.DB.Base;

interface

uses
  System.SysUtils,
  System.Classes,
  AqDrop.Core.Types,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Collections,
  AqDrop.DB.Types,
  AqDrop.DB.Connection,
  AqDrop.DB.ORM.Manager,
  AqDrop.DB.SQL.Intf,
  AqDrop.DB.ORM.Attributes;

type
  TAqDBObjectCacheType = (octNone, octOwnsObjects, octCloned);

const
  octActiveCacheTypes: set of TAqDBObjectCacheType = [octOwnsObjects, octCloned];

type
  TAqDBBaseObject = class;

  TAqDBGenericObjectsManager = class abstract(TAqDBORMManagerClient)
  private
    procedure Save(const pDBObject: TAqDBBaseObject);
    function Delete(const pDBObject: TAqDBBaseObject): Boolean;
    function Discard(const pDBObject: TAqDBBaseObject): Boolean;
  strict protected
    function DoNew: TAqDBBaseObject; virtual; abstract;
    function DoGet(const pID: TAqEntityID): TAqDBBaseObject; virtual; abstract;
    procedure DoSave(const pDBObject: TAqDBBaseObject); virtual; abstract;
    function DoDelete(const pDBObject: TAqDBBaseObject): Boolean; virtual; abstract;
    function DoDiscard(const pDBObject: TAqDBBaseObject): Boolean; virtual; abstract;
  public
    procedure ConfigureCache(const pType: TAqDBObjectCacheType; const pTimeOut: TTime); virtual; abstract;
  end;

  TAqDBBaseObject = class
  strict protected
    procedure InitializeObject; virtual;
    procedure FinalizeObject; virtual;

    function GetORMManager: TAqDBORMManager; virtual; abstract;

    function GetForeignManager<T: TAqDBGenericObjectsManager>: T;

    function GetID: TAqEntityID; virtual; abstract;

    procedure ValidateData; virtual;
  public
    constructor Create;
    destructor Destroy; override;

    property ORMManager: TAqDBORMManager read GetORMManager;

    property ID: TAqEntityID read GetID;
  end;

  TAqDBObject = class(TAqDBBaseObject)
  strict private
    [weak] FObjectsManager: TAqDBGenericObjectsManager;
  private
    class function CreateNew(const pObjectsManager: TAqDBGenericObjectsManager): TAqDBObject;
  strict protected
    function GetORMManager: TAqDBORMManager; override;

    procedure StartTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
  public
    constructor Create(const pObjectsManager: TAqDBGenericObjectsManager);

    procedure Save;
    procedure Delete;
    procedure Discard;

    property ObjectsManager: TAqDBGenericObjectsManager read FObjectsManager;
  end;

  TAqDBObjectAutoID = class(TAqDBObject)
  public
    const ID_COLUMN = 'ID';
  strict private
    [AqAutoIncrementColumn(ID_COLUMN)]
    FID: TAqEntityID;
  strict protected
    function GetID: TAqEntityID; override;
  end;

  TAqDBObjectRegularID = class(TAqDBObject)
  public
    const ID_COLUMN = 'ID';
  strict private
    [AqPrimaryKey(ID_COLUMN)]
    FID: TAqEntityID;
  strict protected
    function GetID: TAqEntityID; override;

    procedure SetID(const pID: TAqEntityID);
  end;

  TAqDBBaseComplementaryCache<Value> = class
  public
    procedure Add(const pObject: Value); virtual; abstract;
    procedure Replace(const pOld, pNew: Value); virtual; abstract;
    procedure Remove(const pObject: Value); virtual; abstract;
  end;

  TAqDBComplementaryCache<Key; Value> = class(TAqDBBaseComplementaryCache<Value>)
  strict private
    FCache: IAqDictionary<Key, Value>;
    FKeyGetter: TFunc<Value, Key>;
  public
    constructor Create(const pKeyGetter: TFunc<Value, Key>);

    procedure Add(const pObject: Value); override;
    procedure Replace(const pOld, pNew: Value); override;
    procedure Remove(const pObject: Value); override;
    function Get(const pKey: Key; out pObject: Value): Boolean;
  end;

  TAqDBComplementaryCacheIndex = type Int32;

  TAqDBObjectCacheContainer<T: TAqDBObject> = class
  strict private
    FObject: T;
    FLastAccess: TAqUnixDateTime;
  public
    constructor Create(const pObject: T);
    destructor Destroy; override;

    function GetObject: T;
    procedure Change(const pObject: T);

    procedure RenewLastAccess;

    function IsExpired(const pTimeOut: TTime): Boolean;

    property LastAccess: TAqUnixDateTime read FLastAccess;
  end;

  TAqDBObjectCache<T: TAqDBObject, constructor> = class
  strict private type
    TMonitorThread = class(TThread)
    strict private
      FCache: IAqDictionary<TAqEntityID, TAqDBObjectCacheContainer<T>>;
      FReleaser: TProc<T>;
      FTimeOut: TTime;

      procedure SetTimeOut(const pTimeOut: TTime);
    protected
      procedure Execute; override;
    public
      constructor Create(const pCache: IAqDictionary<TAqEntityID, TAqDBObjectCacheContainer<T>>;
        const pReleaser: TProc<T>; const pTimeOut: TTime);

      property TimeOut: TTime read FTimeOut write SetTimeOut;
    end;
  strict private
    FType: TAqDBObjectCacheType;
    FObjects: IAqDictionary<TAqEntityID, TAqDBObjectCacheContainer<T>>;
    FComplementaryCaches: IAqList<TAqDBBaseComplementaryCache<T>>;
    FTimeOut: TTime;
    FMonitorThread: TMonitorThread;

    procedure FreeMonitorThread;
    procedure SetTimeOut(const pTimeOut: TTime);
  public
    constructor Create(const pType: TAqDBObjectCacheType);
    destructor Destroy; override;

    procedure Keep(const pObject: T);
    procedure Release(const pObject: T);

    function Keeps(const pObject: T): Boolean;
    function Get(const pID: TAqEntityID; out pObject: T): Boolean;

    function AddComplementaryCache<Key>(const pKeyGetter: TFunc<T, Key>): TAqDBComplementaryCacheIndex;

    function GetFromComplementaryCache<Key>(const pCacheIndex: TAqDBComplementaryCacheIndex;
      const pKey: Key; out pObject: T): Boolean;

    property &Type: TAqDBObjectCacheType read FType;
    property TimeOut: TTime read FTimeOut write SetTimeOut;
  end;

  TAqDBObjectManager<T: TAqDBObject, constructor> = class(TAqDBGenericObjectsManager)
  strict private
    FCache: TAqDBObjectCache<T>;

    procedure AssertObjectInheritance(const pDBObject: TObject);
  strict protected
    function DoGet(const pID: TAqEntityID): TAqDBBaseObject; override;
    function DoNew: TAqDBBaseObject; override;
    procedure DoSave(const pDBObject: TAqDBBaseObject); override;
    function DoDelete(const pDBObject: TAqDBBaseObject): Boolean; override;
    function DoDiscard(const pDBObject: TAqDBBaseObject): Boolean; override;

    procedure AddObject(const pObject: T); virtual;

    procedure InitializeCache; virtual;
    procedure ConfigureComplementaryCaches; virtual;

    property Cache: TAqDBObjectCache<T> read FCache;
  public
    constructor Create(const pORMManager: TAqDBORMManager); override;
    destructor Destroy; override;

    procedure ConfigureCache(const pType: TAqDBObjectCacheType; const pTimeOut: TTime); override; final;

    function Get(const pID: TAqEntityID): T; overload;
    function Get(const pID: TAqEntityID; out pObject: T): Boolean; overload;
    function Get(out pObject: T; const pErrorIfMultipleResults: Boolean = True): Boolean; overload;
    function Get(out pResultList: IAqResultList<T>): Boolean; overload;
    function Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
      out pResultList: IAqResultList<T>; const pOnReadData: TProc<IAqDBReader> = nil): Boolean; overload;
    function Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>; out pObject: T;
      const pErrorIfMultipleResults: Boolean = True): Boolean; overload;
    function Get: IAqResultList<T>; overload;
    function Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
      const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>; overload;

    function New: T;
  end;

implementation

uses
  System.Math,
  System.DateUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.Core.Helpers.TObject,
  AqDrop.DB.SQL,
  AqDrop.DB.ORM.Reader,
  AqDrop.DB.Base.Exceptions;

{ TAqDBObject }

procedure TAqDBObject.CommitTransaction;
begin
  ORMManager.Connection.CommitTransaction;
end;

constructor TAqDBObject.Create(const pObjectsManager: TAqDBGenericObjectsManager);
begin
  inherited Create;

  FObjectsManager := pObjectsManager;
end;

class function TAqDBObject.CreateNew(const pObjectsManager: TAqDBGenericObjectsManager): TAqDBObject;
begin
  Result := Self.Create(pObjectsManager);
end;

procedure TAqDBObject.Delete;
begin
  if not ObjectsManager.Delete(Self) then
  begin
{$IFNDEF AUTOREFCOUNT}
    Free;
{$ENDIF}
  end;
end;

procedure TAqDBObject.Discard;
begin
  if not ObjectsManager.Discard(Self) then
  begin
{$IFNDEF AUTOREFCOUNT}
    Free;
{$ENDIF}
  end;
end;

function TAqDBObject.GetORMManager: TAqDBORMManager;
begin
  Result := FObjectsManager.ORMManager;
end;

procedure TAqDBObject.RollbackTransaction;
begin
  ORMManager.Connection.RollbackTransaction;
end;

procedure TAqDBObject.Save;
begin
  ValidateData;

  ObjectsManager.Save(Self);
end;

procedure TAqDBObject.StartTransaction;
begin
  ORMManager.Connection.StartTransaction;
end;

{ TAqDBObjectManager<T> }

procedure TAqDBObjectManager<T>.AddObject(const pObject: T);
begin
  if Assigned(FCache) then
  begin
    FCache.Keep(pObject);
  end;
end;

procedure TAqDBObjectManager<T>.AssertObjectInheritance(const pDBObject: TObject);
begin
  if not pDBObject.InheritsFrom(T) then
  begin
    raise EAqInternal.Create('Incomptible type when trying to save an object: ' + pDBObject.QualifiedClassName +
      ' x ' + T.QualifiedClassName);
  end;
end;

procedure TAqDBObjectManager<T>.ConfigureCache(const pType: TAqDBObjectCacheType; const pTimeOut: TTime);
begin
  inherited;

  FreeAndNil(FCache);

  if pType in octActiveCacheTypes then
  begin
    FCache := TAqDBObjectCache<T>.Create(pType);
    FCache.TimeOut := pTimeOut;

    ConfigureComplementaryCaches;
  end;
end;

procedure TAqDBObjectManager<T>.ConfigureComplementaryCaches;
begin

end;

constructor TAqDBObjectManager<T>.Create(const pORMManager: TAqDBORMManager);
begin
  inherited;

  InitializeCache;
end;

destructor TAqDBObjectManager<T>.Destroy;
begin
  FCache.Free;

  inherited;
end;

function TAqDBObjectManager<T>.DoDelete(const pDBObject: TAqDBBaseObject): Boolean;
begin
  ORMManager.Delete(pDBObject, False);
  Result := DoDiscard(pDBObject);
end;

function TAqDBObjectManager<T>.DoDiscard(const pDBObject: TAqDBBaseObject): Boolean;
var
  lDBObject: T;
begin
  AssertObjectInheritance(pDBObject);

  lDBObject := T(pDBObject);

  Result := Assigned(FCache) and Cache.Keeps(lDBObject);

  if Result then
  begin
    FCache.Release(lDBObject);
    Result := FCache.&Type = TAqDBObjectCacheType.octOwnsObjects;
  end;
end;

function TAqDBObjectManager<T>.DoGet(const pID: TAqEntityID): TAqDBBaseObject;
begin
  Result := Get(pID);
end;

function TAqDBObjectManager<T>.DoNew: TAqDBBaseObject;
begin
  Result := T.CreateNew(Self);
end;

procedure TAqDBObjectManager<T>.DoSave(const pDBObject: TAqDBBaseObject);
begin
  AssertObjectInheritance(pDBObject);

  ORMManager.Post(pDBObject);

  AddObject(T(pDBObject));
end;

function TAqDBObjectManager<T>.Get(out pResultList: IAqResultList<T>): Boolean;
begin
  Result := Get(nil, pResultList);
end;

function TAqDBObjectManager<T>.Get: IAqResultList<T>;
begin
  if not Get(Result) then
  begin
    Result := nil;
  end;
end;

function TAqDBObjectManager<T>.Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
  const pOnReadData: TProc<IAqDBReader> = nil): IAqResultList<T>;
begin
  if not Get(pCustomizationMethod, Result, pOnReadData) then
  begin
    Result := nil;
  end;
end;

procedure TAqDBObjectManager<T>.InitializeCache;
begin
  ConfigureCache(TaqDBObjectCacheType.octOwnsObjects, TTime.EncodeTime(0, 10, 0, 0))
end;

function TAqDBObjectManager<T>.Get(out pObject: T; const pErrorIfMultipleResults: Boolean): Boolean;
begin
  Result := Get(nil, pObject, pErrorIfMultipleResults);
end;

function TAqDBObjectManager<T>.Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>; out pObject: T;
  const pErrorIfMultipleResults: Boolean): Boolean;
var
  lList: IAqResultList<T>;
begin
  Result := Get(
    procedure(pSelect: IAqDBSQLSelect)
    begin
      pSelect.Limit := IfThen(pErrorIfMultipleResults, 2, 1);

      if Assigned(pCustomizationMethod) then
      begin
        pCustomizationMethod(pSelect);
      end;
    end, lList);

  if Result then
  begin
    if pErrorIfMultipleResults and (lList.Count > 1) then
    begin
      raise EAqInternal.Create('Expected one record, but multiple records were found.');
    end;

    pObject := lList.Extract;
  end;
end;

function TAqDBObjectManager<T>.Get(const pID: TAqEntityID; out pObject: T): Boolean;
var
  lList: IAqResultList<T>;
begin
  Result := Assigned(FCache) and FCache.Get(pID, pObject);

  if not Result then
  begin
    Result := Get(
      procedure(pSelect: IAqDBSQLSelect)
      begin
        pSelect.CustomizeCondition.AddColumnEqual(
          TAqDBSQLColumn.Create(TAqDBORMReader.Instance.GetORM(T).UniqueKey.Name, pSelect.Source), pID);
      end, lList);
    if Result then
    begin
      pObject := lList.Extract;
    end else begin
      pObject := nil;
    end;
  end;
end;

function TAqDBObjectManager<T>.New: T;
var
  lNew: TAqDBBaseObject;
begin
  Result := nil;

  lNew := DoNew;

  try
    if lNew.InheritsFrom(T) then
    begin
      Result := T(lNew);
    end else begin
      raise EAqInternal.Create('Incomptible type when creatin a new Object Manager: ' + lNew.QualifiedClassName +
        ' x ' + T.QualifiedClassName);
    end;
  except
    lNew.Free;
    raise;
  end;
end;

function TAqDBObjectManager<T>.Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
  out pResultList: IAqResultList<T>; const pOnReadData: TProc<IAqDBReader> = nil): Boolean;
var
  lObject: T;
begin
  Result := ORMManager.Get<T>(pCustomizationMethod, pResultList,
    function: T
    begin
      Result := T(T.CreateNew(Self));
    end, pOnReadData);

  if Result then
  begin
    for lObject in pResultList do
    begin
      AddObject(lObject);
    end;

    pResultList.OnwsResults := not Assigned(FCache) or (FCache.&Type <> TAqDBObjectCacheType.octOwnsObjects);
  end;
end;

function TAqDBObjectManager<T>.Get(const pID: TAqEntityID): T;
begin
  if not Get(pID, Result) then
  begin
    Result := nil;
  end;
end;

{ TAqDBObjectAutoID }

function TAqDBObjectAutoID.GetID: TAqEntityID;
begin
  Result := FID;
end;

{ TAqDBObjectRegularID }

function TAqDBObjectRegularID.GetID: TAqEntityID;
begin
  Result := FID;
end;

procedure TAqDBObjectRegularID.SetID(const pID: TAqEntityID);
begin
  FID := pID;
end;

{ TAqDBGenericObjectsManager }

function TAqDBGenericObjectsManager.Delete(const pDBObject: TAqDBBaseObject): Boolean;
begin
  Result := DoDelete(pDBObject);
end;

function TAqDBGenericObjectsManager.Discard(const pDBObject: TAqDBBaseObject): Boolean;
begin
  Result := DoDiscard(pDBObject);
end;

procedure TAqDBGenericObjectsManager.Save(const pDBObject: TAqDBBaseObject);
begin
  DoSave(pDBObject);
end;

{ TAqDBObjectCacheContainer<T> }

procedure TAqDBObjectCacheContainer<T>.Change(const pObject: T);
begin
  if FObject <> pObject then
  begin
    FreeAndNil(FObject);

    FObject := pObject;
  end;

  RenewLastAccess;
end;

constructor TAqDBObjectCacheContainer<T>.Create(const pObject: T);
begin
  Change(pObject);
end;

destructor TAqDBObjectCacheContainer<T>.Destroy;
begin
  FObject.Free;

  inherited;
end;

function TAqDBObjectCacheContainer<T>.GetObject: T;
begin
  Result := FObject;
  RenewLastAccess;
end;

function TAqDBObjectCacheContainer<T>.IsExpired(const pTimeOut: TTime): Boolean;
begin
  Result := (pTimeOut > 0) and ((Now - FLastAccess.ToDateTime) >= pTimeOut);
end;

procedure TAqDBObjectCacheContainer<T>.RenewLastAccess;
begin
  FLastAccess := TAqUnixDateTime.Now;
end;

{ TAqDBObjectCache<T> }

function TAqDBObjectCache<T>.AddComplementaryCache<Key>(const pKeyGetter: TFunc<T, Key>): TAqDBComplementaryCacheIndex;
begin
  Result := FComplementaryCaches.Add(TAqDBComplementaryCache<Key, T>.Create(pKeyGetter));
end;

constructor TAqDBObjectCache<T>.Create(const pType: TAqDBObjectCacheType);
begin
  if not(pType in octActiveCacheTypes) then
  begin
    raise EAqInternal.Create('Invalid cache type.');
  end;

  FType := pType;
  FObjects := TAqDictionary<TAqEntityID, TAqDBObjectCacheContainer<T>>.Create(
    [TAqKeyValueOwnership.kvoValue],
    TAqLockerType.lktMultiReadeExclusiveWriter);
  FComplementaryCaches := TAqList<TAqDBBaseComplementaryCache<T>>.Create(True);
end;

destructor TAqDBObjectCache<T>.Destroy;
begin
  FreeMonitorThread;

  inherited;
end;

procedure TAqDBObjectCache<T>.FreeMonitorThread;
begin
  if Assigned(FMonitorThread) then
  begin
    FMonitorThread.Terminate;
    FMonitorThread.WaitFor;
    FreeAndNil(FMonitorThread);
  end;
end;

function TAqDBObjectCache<T>.Get(const pID: TAqEntityID; out pObject: T): Boolean;
var
  lContainer: TAqDBObjectCacheContainer<T>;
begin
  FObjects.BeginRead;

  try
    Result := FObjects.TryGetValue(pID, lContainer);

    if Result then
    begin
      case FType of
        octOwnsObjects:
          pObject := lContainer.GetObject;
        octCloned:
          pObject := T(lContainer.GetObject.CloneTo(T.CreateNew(nil)));
      end;
    end;
  finally
    FObjects.EndRead;
  end;
end;

function TAqDBObjectCache<T>.GetFromComplementaryCache<Key>(const pCacheIndex: TAqDBComplementaryCacheIndex;
  const pKey: Key; out pObject: T): Boolean;
var
  lCache: TAqDBBaseComplementaryCache<T>;
  lCachedObject: T;
begin
  FObjects.BeginRead;

  try
    lCache := FComplementaryCaches[pCacheIndex];

    Result := lCache is TAqDBComplementaryCache<Key, T>;

    if Result then
    begin
      Result := TAqDBComplementaryCache<Key, T>(lCache).Get(pKey, lCachedObject);

      if Result then
      begin
        case FType of
          octOwnsObjects:
            pObject := lCachedObject;
          octCloned:
            pObject := T(lCachedObject.CloneTo(T.CreateNew(nil)));
        end;

        FObjects.Items[pObject.ID].RenewLastAccess;
      end;
    end;
  finally
    FObjects.EndRead;
  end;
end;

procedure TAqDBObjectCache<T>.Keep(const pObject: T);
begin
  FObjects.ExecuteLockedForWriting(
    procedure
    var
      lObjectToKeep: T;
      lCache: TAqDBBaseComplementaryCache<T>;
      lNewObject: Boolean;
    begin
      lObjectToKeep := nil;

      case FType of
        octOwnsObjects:
          lObjectToKeep := pObject;
        octCloned:
          lObjectToKeep := T(pObject.CloneTo(T.CreateNew(nil)));
      end;

      lNewObject := not FObjects.ContainsKey(pObject.ID);

      for lCache in FComplementaryCaches do
      begin
        if lNewObject then
        begin
          lCache.Add(lObjectToKeep);
        end else begin
          lCache.Replace(FObjects[pObject.ID].GetObject, lObjectToKeep);
        end;
      end;

      if lNewObject then
      begin
        FObjects.Add(pObject.ID, TAqDBObjectCacheContainer<T>.Create(lObjectToKeep));
      end else
      begin
        FObjects[pObject.ID].Change(lObjectToKeep);
      end;
    end);
end;

function TAqDBObjectCache<T>.Keeps(const pObject: T): Boolean;
begin
  FObjects.BeginRead;

  try
    Result := FObjects.ContainsKey(pObject.ID);
  finally
    FObjects.EndRead;
  end;
end;

procedure TAqDBObjectCache<T>.Release(const pObject: T);
var
  lCache: TAqDBBaseComplementaryCache<T>;
begin
  FObjects.BeginWrite;

  try
    for lCache in FComplementaryCaches do
    begin
      lCache.Remove(pObject);
    end;

    FObjects.Remove(pObject.ID);
  finally
    FObjects.EndWrite;
  end;
end;

procedure TAqDBObjectCache<T>.SetTimeOut(const pTimeOut: TTime);
begin
  FTimeOut := pTimeOut;

  if Assigned(FMonitorThread) and (FTimeOut = 0) then
  begin
    if FTimeOut = 0 then
    begin
      FreeMonitorThread;
    end else begin
      FMonitorThread.TimeOut := pTimeOut;
    end;
  end else if FTimeOut <> 0 then
  begin
    FMonitorThread := TMonitorThread.Create(FObjects,
      procedure(pObject: T)
      begin
        Release(pObject);
      end, FTimeOut);
  end;
end;

{ TAqDBObjectCache<T>.TMonitorThread }

constructor TAqDBObjectCache<T>.TMonitorThread.Create(
  const pCache: IAqDictionary<TAqEntityID, TAqDBObjectCacheContainer<T>>; const pReleaser: TProc<T>; const pTimeOut: TTime);
begin
  inherited Create;

  FCache := pCache;
  FReleaser := pReleaser;
  FTimeOut := pTimeOut;
end;

procedure TAqDBObjectCache<T>.TMonitorThread.Execute;
begin
  inherited;

  while not Terminated do
  begin
    FCache.ExecuteLockedForWriting(
      procedure
      var
        lContainer: TAqDBObjectCacheContainer<T>;
      begin
        for lContainer in FCache.Values do
        begin
          if lContainer.IsExpired(FTimeOut) then
          begin
            FReleaser(lContainer.GetObject);
          end;
        end;
      end);

    Sleep(1000);
  end;
end;

procedure TAqDBObjectCache<T>.TMonitorThread.SetTimeOut(const pTimeOut: TTime);
begin
  FCache.ExecuteLockedForWriting(
    procedure
    begin
      FTimeOut := pTimeOut;
    end);
end;

{ TAqDBComplementaryCache<Key, Value> }

procedure TAqDBComplementaryCache<Key, Value>.Add(const pObject: Value);
begin
  FCache.Add(FKeyGetter(pObject), pObject);
end;

constructor TAqDBComplementaryCache<Key, Value>.Create(const pKeyGetter: TFunc<Value, Key>);
begin
  FCache := TAqDictionary<Key, Value>.Create;
  FKeyGetter := pKeyGetter;
end;

function TAqDBComplementaryCache<Key, Value>.Get(const pKey: Key; out pObject: Value): Boolean;
begin
  Result := FCache.TryGetValue(pKey, pObject);
end;

procedure TAqDBComplementaryCache<Key, Value>.Remove(const pObject: Value);
begin
  FCache.Remove(FKeyGetter(pObject));
end;

procedure TAqDBComplementaryCache<Key, Value>.Replace(const pOld, pNew: Value);
var
  lOldKey: Key;
  lNewKey: Key;
begin
  lOldKey := FKeyGetter(pOld);
  lNewKey := FKeyGetter(pNew);

  FCache.Remove(lOldKey);
  FCache.Add(lNewKey, pNew);
end;

{ TAqDBBaseObject }

constructor TAqDBBaseObject.Create;
begin
  inherited;

  InitializeObject;
end;

destructor TAqDBBaseObject.Destroy;
begin
  FinalizeObject;

  inherited;
end;

procedure TAqDBBaseObject.FinalizeObject;
begin

end;

function TAqDBBaseObject.GetForeignManager<T>: T;
begin
  Result := ORMManager.GetClient<T>;
end;

procedure TAqDBBaseObject.InitializeObject;
begin

end;

procedure TAqDBBaseObject.ValidateData;
begin
  // virtual method to be overwritten in order to validate the object's data (or delegate the validation )
  // before it being saved.
end;

end.
