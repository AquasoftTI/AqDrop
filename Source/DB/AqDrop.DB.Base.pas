unit AqDrop.DB.Base;

interface

uses
  System.SysUtils,
  System.Classes,
  AqDrop.Core.Types,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Collections,
  AqDrop.DB.Connection,
  AqDrop.DB.ORM.Manager,
  AqDrop.DB.SQL.Intf,
  AqDrop.DB.ORM.Attributes;

type
  TAqDBObjectCacheType = (octNone, octOwnsObjects, octCloned);

const
  octActiveCacheTypes: set of TAqDBObjectCacheType = [octOwnsObjects, octCloned];

type
  TAqDBObject = class;
  TAqDBObjectClass = class of TAqDBObject;

  TAqDBGenericObjectManager = class abstract(TAqDBORMManagerClient)
  private
    procedure Save(const pDBObject: TAqDBObject);
    function Delete(const pDBObject: TAqDBObject): Boolean;
  strict protected
    function DoNew: TAqDBObject; virtual; abstract;
    function DoGet(const pID: UInt64): TAqDBObject; virtual; abstract;
    procedure DoSave(const pDBObject: TAqDBObject); virtual; abstract;
    function DoDelete(const pDBObject: TAqDBObject): Boolean; virtual; abstract;
  public
    procedure ConfigureCache(const pType: TAqDBObjectCacheType; const pTimeOut: TTime); virtual; abstract;
  end;

  TAqDBObject = class
  public
    const ID_COLUMN = 'ID';
  strict private
    [weak]
    FManager: TAqDBGenericObjectManager;
  private
    procedure SetManager(const pManager: TAqDBGenericObjectManager);
  strict protected
    function GetID: UInt64; virtual; abstract;

    function GetForeignManager<T: TAqDBGenericObjectManager>: T;

    procedure StartTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;

    procedure ValidateData; virtual;

    property Manager: TAqDBGenericObjectManager read FManager;
  public
    procedure Save;
    procedure Delete;

    property ID: UInt64 read GetID;
  end;

  TAqDBObjectAutoID = class(TAqDBObject)
  strict private
    [AqAutoIncrementColumn(TAqDBObject.ID_COLUMN)]
    FID: UInt64;
  strict protected
    function GetID: UInt64; override;
  end;

  TAqDBObjectRegularID = class(TAqDBObject)
  strict private
    [AqPrimaryKey(TAqDBObject.ID_COLUMN)]
    FID: UInt64;
  strict protected
    function GetID: UInt64; override;

    procedure SetID(const pID: UInt64);
  end;

  TAqDBComplementaryCacheType = (cctInt, cctString, cctDouble);

  TAqDBBaseComplementaryCache<Value> = class
  public
    procedure Add(const pObject: Value); virtual; abstract;
    procedure Replace(const pOld, pNew: Value); virtual; abstract;
    procedure Remove(const pObject: Value); virtual; abstract;
  end;

  TAqDBComplementaryCache<Key; Value> = class(TAqDBBaseComplementaryCache<Value>)
  strict private
    FCache: TAqDictionary<Key, Value>;
    FKeyGetter: TFunc<Value, Key>;
  public
    constructor Create(const pKeyGetter: TFunc<Value, Key>);

    procedure Add(const pObject: Value); override;
    procedure Replace(const pOld, pNew: Value); override;
    procedure Remove(const pObject: Value); override;
    function Get(const pKey: Key; out pObject: Value): Boolean;
  end;

  TAqDBComplementaryIntCache<Value> = class(TAqDBComplementaryCache<Int64, Value>);
  TAqDBComplementaryStringCache<Value> = class(TAqDBComplementaryCache<string, Value>);
  TAqDBComplementaryDoubleCache<Value> = class(TAqDBComplementaryCache<Double, Value>);

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
      FCache: TAqDictionary<UInt64, TAqDBObjectCacheContainer<T>>;
      FReleaser: TProc<T>;
      FTimeOut: TTime;

      procedure SetTimeOut(const pTimeOut: TTime);
    protected
      procedure Execute; override;
    public
      constructor Create(const pCache: TAqDictionary<UInt64, TAqDBObjectCacheContainer<T>>;
        const pReleaser: TProc<T>; const pTimeOut: TTime);

      property TimeOut: TTime read FTimeOut write SetTimeOut;
    end;
  strict private
    FType: TAqDBObjectCacheType;
    FObjects: TAqDictionary<UInt64, TAqDBObjectCacheContainer<T>>;
    FComplementaryCaches: TAqList<TAqKeyValuePair<TAqDBComplementaryCacheType, TAqDBBaseComplementaryCache<T>>>;
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
    function Get(const pID: UInt64; out pObject: T): Boolean;

    function AddComplementaryIntCache(const pKeyGetter: TFunc<T, Int64>): TAqDBComplementaryCacheIndex;
    function AddComplementaryStringCache(const pKeyGetter: TFunc<T, string>): TAqDBComplementaryCacheIndex;
    function AddComplementaryDoubleCache(const pKeyGetter: TFunc<T, Double>): TAqDBComplementaryCacheIndex;

    function GetFromComplementaryIntCache(const pCacheIndex: TAqDBComplementaryCacheIndex;
      const pKey: Int64; out pObject: T): Boolean;
    function GetFromComplementaryStringCache(const pCacheIndex: TAqDBComplementaryCacheIndex;
      const pKey: string; out pObject: T): Boolean;
    function GetFromComplementaryDoubleCache(const pCacheIndex: TAqDBComplementaryCacheIndex;
      const pKey: Double; out pObject: T): Boolean;

    property &Type: TAqDBObjectCacheType read FType;
    property TimeOut: TTime read FTimeOut write SetTimeOut;
  end;

  TAqDBObjectManager<T: TAqDBObject, constructor> = class(TAqDBGenericObjectManager)
  strict private
    FCache: TAqDBObjectCache<T>;
  strict protected
    function DoGet(const pID: UInt64): TAqDBObject; override;
    function DoNew: TAqDBObject; override;
    procedure DoSave(const pDBObject: TAqDBObject); override;
    function DoDelete(const pDBObject: TAqDBObject): Boolean; override;

    procedure AddObject(const pObject: T); virtual;

    procedure ConfigureComplementaryCaches; virtual;

    property Cache: TAqDBObjectCache<T> read FCache;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure ConfigureCache(const pType: TAqDBObjectCacheType; const pTimeOut: TTime); override; final;

    function Get(const pID: Int64): T; overload;
    function Get(const pID: Int64; out pObject: T): Boolean; overload;
    function Get(out pResultList: IAqResultList<T>): Boolean; overload;
    function Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
      out pResultList: IAqResultList<T>): Boolean; overload;
    function Get: IAqResultList<T>; overload;
    function Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>): IAqResultList<T>; overload;

    function New: T;
  end;

implementation

uses
  System.DateUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.Core.Helpers.TObject,
  AqDrop.DB.SQL,
  AqDrop.DB.Base.Exceptions;

{ TAqDBObject }

procedure TAqDBObject.CommitTransaction;
begin
  FManager.ORMManager.Connection.CommitTransaction;
end;

procedure TAqDBObject.Delete;
begin
  if not FManager.Delete(Self) then
  begin
{$IFNDEF AUTOREFCOUNT}
    Free;
{$ENDIF}
  end;
end;

function TAqDBObject.GetForeignManager<T>: T;
begin
  Result := FManager.ORMManager.GetClient<T>;
end;

procedure TAqDBObject.RollbackTransaction;
begin
  FManager.ORMManager.Connection.RollbackTransaction;
end;

procedure TAqDBObject.Save;
begin
  ValidateData;

  FManager.Save(Self);
end;

procedure TAqDBObject.SetManager(const pManager: TAqDBGenericObjectManager);
begin
  FManager := pManager;
end;

procedure TAqDBObject.StartTransaction;
begin
  FManager.ORMManager.Connection.StartTransaction;
end;

procedure TAqDBObject.ValidateData;
begin
  // virtual method to be overwritten in order to validate the object's data before it being saved.
end;

{ TAqDBObjectManager<T> }

procedure TAqDBObjectManager<T>.AddObject(const pObject: T);
begin
  pObject.SetManager(Self);

  if Assigned(FCache) then
  begin
    FCache.Keep(pObject);
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

constructor TAqDBObjectManager<T>.Create;
begin
  inherited;

  ConfigureCache(TaqDBObjectCacheType.octOwnsObjects, TTime.EncodeTime(0, 10, 0, 0));
end;

destructor TAqDBObjectManager<T>.Destroy;
begin
  FCache.Free;

  inherited;
end;

function TAqDBObjectManager<T>.DoDelete(const pDBObject: TAqDBObject): Boolean;
begin
  if not Assigned(FCache) or FCache.Keeps(pDBObject) then
  begin
    ORMManager.Delete(pDBObject, False);

    Result := Assigned(FCache);
    if Result then
    begin
      FCache.Release(pDBObject);

      Result := FCache.&Type = TAqDBObjectCacheType.octOwnsObjects;
    end;
  end;
end;

function TAqDBObjectManager<T>.DoGet(const pID: UInt64): TAqDBObject;
begin
  Result := Get(pID);
end;

function TAqDBObjectManager<T>.DoNew: TAqDBObject;
begin
  Result := T.Create;
  Result.SetManager(Self);
end;

procedure TAqDBObjectManager<T>.DoSave(const pDBObject: TAqDBObject);
begin
  if not pDBObject.InheritsFrom(T) then
  begin
    raise EAqInternal.Create('Incomptible type when trying to save an object: ' + pDBObject.QualifiedClassName +
      ' x ' + T.QualifiedClassName);
  end;

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

function TAqDBObjectManager<T>.Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>): IAqResultList<T>;
begin
  if not Get(pCustomizationMethod, Result) then
  begin
    Result := nil;
  end;
end;

function TAqDBObjectManager<T>.Get(const pID: Int64; out pObject: T): Boolean;
var
  lList: IAqResultList<T>;
begin
  Result := Assigned(FCache) and FCache.Get(pID, pObject);

  if not Result then
  begin
    Result := Get(
      procedure(pSelect: IAqDBSQLSelect)
      begin
        pSelect.CustomizeCondition.AddColumnEqual(TAqDBSQLColumn.Create(T.ID_COLUMN, pSelect.Source), pID);
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
  lNew: TAqDBObject;
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

  Result := T(lNew);
end;

function TAqDBObjectManager<T>.Get(const pCustomizationMethod: TProc<IAqDBSQLSelect>;
  out pResultList: IAqResultList<T>): Boolean;
var
  lObject: T;
begin
  Result := ORMManager.Get<T>(pCustomizationMethod, pResultList);

  if Result then
  begin
    for lObject in pResultList do
    begin
      AddObject(lObject);
    end;

    pResultList.OnwsResults := not Assigned(FCache) or (FCache.&Type <> TAqDBObjectCacheType.octOwnsObjects);
  end;
end;

function TAqDBObjectManager<T>.Get(const pID: Int64): T;
begin
  if not Get(pID, Result) then
  begin
    Result := nil;
  end;
end;

{ TAqDBObjectAutoID }

function TAqDBObjectAutoID.GetID: UInt64;
begin
  Result := FID;
end;

{ TAqDBObjectRegularID }

function TAqDBObjectRegularID.GetID: UInt64;
begin
  Result := FID;
end;

procedure TAqDBObjectRegularID.SetID(const pID: UInt64);
begin
  FID := pID;
end;

{ TAqDBGenericObjectManager }

function TAqDBGenericObjectManager.Delete(const pDBObject: TAqDBObject): Boolean;
begin
  Result := DoDelete(pDBObject);
end;

procedure TAqDBGenericObjectManager.Save(const pDBObject: TAqDBObject);
begin
  DoSave(pDBObject);
end;

{ TAqDBObjectCacheContainer<T> }

procedure TAqDBObjectCacheContainer<T>.Change(const pObject: T);
begin
  FreeAndNil(FObject);

  FObject := pObject;
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

function TAqDBObjectCache<T>.AddComplementaryDoubleCache(
  const pKeyGetter: TFunc<T, Double>): TAqDBComplementaryCacheIndex;
begin
  Result := FComplementaryCaches.Add(
    TAqKeyValuePair<TAqDBComplementaryCacheType,TAqDBBaseComplementaryCache<T>>.Create(
    TAqDBComplementaryCacheType.cctDouble,
    TAqDBComplementaryDoubleCache<T>.Create(pKeyGetter),
    [TAqKeyValueOwnership.kvoValue]));
end;

function TAqDBObjectCache<T>.AddComplementaryIntCache(const pKeyGetter: TFunc<T, Int64>): TAqDBComplementaryCacheIndex;
begin
  Result := FComplementaryCaches.Add(
    TAqKeyValuePair<TAqDBComplementaryCacheType, TAqDBBaseComplementaryCache<T>>.Create(
    TAqDBComplementaryCacheType.cctInt,
    TAqDBComplementaryIntCache<T>.Create(pKeyGetter),
    [TAqKeyValueOwnership.kvoValue]));
end;

function TAqDBObjectCache<T>.AddComplementaryStringCache(
  const pKeyGetter: TFunc<T, string>): TAqDBComplementaryCacheIndex;
begin
  Result := FComplementaryCaches.Add(
    TAqKeyValuePair<TAqDBComplementaryCacheType ,TAqDBBaseComplementaryCache<T>>.Create(
    TAqDBComplementaryCacheType.cctString,
    TAqDBComplementaryStringCache<T>.Create(pKeyGetter),
    [TAqKeyValueOwnership.kvoValue]));
end;

constructor TAqDBObjectCache<T>.Create(const pType: TAqDBObjectCacheType);
begin
  if not(pType in octActiveCacheTypes) then
  begin
    raise EAqInternal.Create('Invalid cache type.');
  end;

  FType := pType;
  FObjects := TAqDictionary<UInt64, TAqDBObjectCacheContainer<T>>.Create([TAqKeyValueOwnership.kvoValue], True);
  FComplementaryCaches :=
    TAqList<TAqKeyValuePair<TAqDBComplementaryCacheType, TAqDBBaseComplementaryCache<T>>>.Create(True);
end;

destructor TAqDBObjectCache<T>.Destroy;
begin
  FreeMonitorThread;
  FComplementaryCaches.Free;
  FObjects.Free;

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

function TAqDBObjectCache<T>.Get(const pID: UInt64; out pObject: T): Boolean;
var
  lContainer: TAqDBObjectCacheContainer<T>;
begin
  FObjects.Lock;

  try
    Result := FObjects.TryGetValue(pID, lContainer);

    if Result then
    begin
      case FType of
        octOwnsObjects:
          pObject := lContainer.GetObject;
        octCloned:
          pObject := lContainer.GetObject.CloneTo<T>;
      end;
    end;
  finally
    FObjects.Release;
  end;
end;

function TAqDBObjectCache<T>.GetFromComplementaryDoubleCache(const pCacheIndex: TAqDBComplementaryCacheIndex;
  const pKey: Double; out pObject: T): Boolean;
var
  lPair: TAqKeyValuePair<TAqDBComplementaryCacheType, TAqDBBaseComplementaryCache<T>>;
  lCachedObject: T;
begin
  FObjects.Lock;

  try
    lPair := FComplementaryCaches[pCacheIndex];

    Result := lPair.Key = TAqDBComplementaryCacheType.cctDouble;

    if Result then
    begin
      Result := TAqDBComplementaryDoubleCache<T>(lPair.Value).Get(pKey, lCachedObject);

      if Result then
      begin
        case FType of
          octOwnsObjects:
            pObject := lCachedObject;
          octCloned:
            pObject := lCachedObject.CloneTo<T>;
        end;

        FObjects.Items[pObject.ID].RenewLastAccess;
      end;
    end;
  finally
    FObjects.Release;
  end;
end;

function TAqDBObjectCache<T>.GetFromComplementaryIntCache(const pCacheIndex: TAqDBComplementaryCacheIndex;
  const pKey: Int64; out pObject: T): Boolean;
var
  lPair: TAqKeyValuePair<TAqDBComplementaryCacheType, TAqDBBaseComplementaryCache<T>>;
  lCachedObject: T;
begin
  FObjects.Lock;

  try
    lPair := FComplementaryCaches[pCacheIndex];

    Result := lPair.Key = TAqDBComplementaryCacheType.cctInt;

    if Result then
    begin
      Result := TAqDBComplementaryIntCache<T>(lPair.Value).Get(pKey, lCachedObject);

      if Result then
      begin
        case FType of
          octOwnsObjects:
            pObject := lCachedObject;
          octCloned:
            pObject := lCachedObject.CloneTo<T>;
        end;

        FObjects.Items[pObject.ID].RenewLastAccess;
      end;
    end;
  finally
    FObjects.Release;
  end;
end;

function TAqDBObjectCache<T>.GetFromComplementaryStringCache(const pCacheIndex: TAqDBComplementaryCacheIndex;
  const pKey: string; out pObject: T): Boolean;
var
  lPair: TAqKeyValuePair<TAqDBComplementaryCacheType, TAqDBBaseComplementaryCache<T>>;
  lCachedObject: T;
begin
  FObjects.Lock;

  try
    lPair := FComplementaryCaches[pCacheIndex];

    Result := lPair.Key = TAqDBComplementaryCacheType.cctString;

    if Result then
    begin
      Result := TAqDBComplementaryStringCache<T>(lPair.Value).Get(pKey, lCachedObject);

      if Result then
      begin
        case FType of
          octOwnsObjects:
            pObject := lCachedObject;
          octCloned:
            pObject := lCachedObject.CloneTo<T>;
        end;

        FObjects.Items[pObject.ID].RenewLastAccess;
      end;
    end;
  finally
    FObjects.Release;
  end;
end;

procedure TAqDBObjectCache<T>.Keep(const pObject: T);
var
  lObjectToKeep: T;
  lPair: TAqKeyValuePair<TAqDBComplementaryCacheType, TAqDBBaseComplementaryCache<T>>;
  lNewObject: Boolean;
begin
  FObjects.Lock;

  try
    lObjectToKeep := nil;

    case FType of
      octOwnsObjects:
        lObjectToKeep := pObject;
      octCloned:
        lObjectToKeep := pObject.CloneTo<T>;
    end;

    lNewObject := not FObjects.ContainsKey(pObject.ID);

    for lPair in FComplementaryCaches do
    begin
      if lNewObject then
      begin
        lPair.Value.Add(lObjectToKeep);
      end else begin
        lPair.Value.Replace(FObjects[pObject.ID].GetObject, lObjectToKeep);
      end;
    end;

    if lNewObject then
    begin
      FObjects.Add(pObject.ID, TAqDBObjectCacheContainer<T>.Create(lObjectToKeep));
    end else if FType = TAqDBObjectCacheType.octCloned then
    begin
      FObjects[pObject.ID] := TAqDBObjectCacheContainer<T>.Create(lObjectToKeep);
    end;
  finally
    FObjects.Release;
  end;
end;

function TAqDBObjectCache<T>.Keeps(const pObject: T): Boolean;
begin
  FObjects.Lock;

  try
    Result := FObjects.ContainsKey(pObject.ID);
  finally
    FObjects.Release;
  end;
end;

procedure TAqDBObjectCache<T>.Release(const pObject: T);
var
  lPair: TAqKeyValuePair<TAqDBComplementaryCacheType, TAqDBBaseComplementaryCache<T>>;
begin
  FObjects.Lock;

  try
    for lPair in FComplementaryCaches do
    begin
      lPair.Value.Remove(pObject);
    end;

    FObjects.Remove(pObject.ID);
  finally
    FObjects.Release;
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

constructor TAqDBObjectCache<T>.TMonitorThread.Create(const pCache: TAqDictionary<UInt64, TAqDBObjectCacheContainer<T>>;
  const pReleaser: TProc<T>; const pTimeOut: TTime);
begin
  inherited Create;

  FCache := pCache;
  FReleaser := pReleaser;
  FTimeOut := pTimeOut;
end;

procedure TAqDBObjectCache<T>.TMonitorThread.Execute;
var
  lContainer: TAqDBObjectCacheContainer<T>;
begin
  inherited;

  while not Terminated do
  begin
    FCache.Lock;

    try
      for lContainer in FCache.Values do
      begin
        if lContainer.IsExpired(FTimeOut) then
        begin
          FReleaser(lContainer.GetObject);
        end;
      end;
    finally
      FCache.Release;
    end;

    Sleep(1000);
  end;
end;

procedure TAqDBObjectCache<T>.TMonitorThread.SetTimeOut(const pTimeOut: TTime);
begin
  FCache.Lock;

  try
    FTimeOut := pTimeOut;
  finally
    FCache.Release;
  end;
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

end.
