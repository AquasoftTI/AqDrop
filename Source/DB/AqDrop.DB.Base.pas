unit AqDrop.DB.Base;

interface

uses
  System.SysUtils,
  System.TypInfo,
  System.Classes,
  AqDrop.Core.Types,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Collections,
  AqDrop.Core.Observers.Intf,
  AqDrop.Core.Cache.Intf,
  AqDrop.Core.Cache.Monitor,
  AqDrop.DB.Types,
  AqDrop.DB.SQL.Intf,
  AqDrop.DB.Connection,
  AqDrop.DB.ORM.Attributes,
  AqDrop.DB.ORM.Manager;

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

    procedure LoadDetails(const pRecursive: Boolean = True);


    property ORMManager: TAqDBORMManager read GetORMManager;
    property ID: TAqEntityID read GetID;
  end;


  TAqDBObjectClass = class of TAqDBObject;

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

  TAqDBBaseComplementaryCache = class
  public
    procedure Add(const pObject: TAqDBObject); virtual; abstract;
    procedure Replace(const pOld, pNew: TAqDBObject); virtual; abstract;
    procedure Remove(const pObject: TAqDBObject); virtual; abstract;
  end;

  TAqDBComplementaryCache<Key> = class(TAqDBBaseComplementaryCache)
  strict private
    FCache: IAqDictionary<Key, TAqDBObject>;
    FKeyGetter: TFunc<TAqDBObject, Key>;
  public
    constructor Create(const pKeyGetter: TFunc<TAqDBObject, Key>);

    procedure Add(const pObject: TAqDBObject); override;
    procedure Replace(const pOld, pNew: TAqDBObject); override;
    procedure Remove(const pObject: TAqDBObject); override;
    function Get(const pKey: Key; out pObject: TAqDBObject): Boolean;
  end;

  TAqDBObjectCacheContainer = class
  strict private
    FObject: TAqDBObject;
    FLastAccess: TAqUnixDateTime;
  public
    constructor Create(const pObject: TAqDBObject);
    destructor Destroy; override;

    function GetObject: TAqDBObject;
    procedure Change(const pObject: TAqDBObject);

    procedure RenewLastAccess;

    function IsExpired(const pTimeOut: TTime): Boolean;

    property LastAccess: TAqUnixDateTime read FLastAccess;
  end;

  IAqDBObjectCache = interface(IAqMonitorableCache)
    ['{0F300649-B16F-44F9-A9BE-6BDE8CD928B8}']
  end;

  IAqDBCustomCacheMonitor = interface
    ['{0AA34C3A-3D1F-4726-AC7A-95E5951A999A}']

    procedure Monitor(const pCaches: TAqCaches<IAqDBObjectCache>);
    function GetTimeBetweenCicles: TTime;

    procedure NotifyCacheAsInvalid(const pTypeNames: TArray<string>; const pID: TAqEntityID);
  end;

  TAqDBObjectCache = class(TAqInterfacedObject, IAqDBObjectCache)
  strict private
    FClass: TAqDBObjectClass;
    FType: TAqDBObjectCacheType;
    FObjects: IAqDictionary<TAqEntityID, TAqDBObjectCacheContainer>;
    FComplementaryCaches: IAqList<TAqDBBaseComplementaryCache>;
    FTimeOut: TTime;
    FMonitoringID: TAqID;
    FLinkedTypes: IAqList<string>;
    FOnDataChanged: IAqObservable<TAqEntityID>;

    procedure LinkToType(const pType: PTypeInfo);
    function GetLinkedTypesNames: IAqReadableList<string>;
    procedure DoRelease(const pObject: TAqDBObject);
    procedure DiscardCache(const pID: TAqEntityID);
    procedure DiscardExpiredItems;

    procedure SetTimeOut(const pTimeOut: TTime);

    function GetOnDataChanged: IAqObservable<TAqEntityID>;
    procedure NotifyOnDataChanged(const pID: TAqEntityID);
  public
    constructor Create(const pClass: TAqDBObjectClass; const pType: TAqDBObjectCacheType; const pTypeLinkerCallback: TProc<TProc<PTypeInfo>>);
    destructor Destroy; override;

    procedure Store(const pObject: TAqDBObject);
    procedure Update(const pObject: TAqDBObject);
    procedure Release(const pObject: TAqDBObject);
    procedure Delete(const pObject: TAqDBObject);

    function Keeps(const pObject: TAqDBObject): Boolean;
    function Get(const pID: TAqEntityID; out pObject: TAqDBObject): Boolean;

    function AddComplementaryCache<Key>(const pKeyGetter: TFunc<TAqDBObject, Key>): Int32;

    function GetFromComplementaryCache<Key>(const pCacheIndex: Int32; const pKey: Key; out pObject: TAqDBObject): Boolean;

    property &Type: TAqDBObjectCacheType read FType;
    property TimeOut: TTime read FTimeOut write SetTimeOut;
    property OnDataChanged: IAqObservable<TAqEntityID> read GetOnDataChanged;
  end;

  {TODO: hoje existe uma instância geral para TAqDBCacheMonitor, em um segundo momento precisamos ter múltiplas instâncias, associadas a cada ORM Manager (é uma possibilidade), de forma a, genericamente, recuperarmos qual o monitor que precisamos registrar uma cache, e o custom monitor }
  TAqDBCacheMonitor = class(TAqCacheMonitor<IAqDBObjectCache>)
  strict private
    FCustomMonitor: IAqDBCustomCacheMonitor;
    FCustomMonitorThread: TThread;

    procedure ReleaseCustomMonitorThread;

    class var FInstance: TAqDBCacheMonitor;
    class function GetInstance: TAqDBCacheMonitor; static;
  private
    class function IsAlive: Boolean;
    class procedure ReleaseInstance;
  public
    destructor Destroy; override;

    procedure SetCustomMonitor(pCustomMonitor: IAqDBCustomCacheMonitor);
    procedure NotifyCacheAsInvalid(const pTypeNames: TArray<string>; const pID: TAqEntityID); overload;
    procedure NotifyCacheAsInvalid(const pSenderID: TAqID; const pTypeNames: TArray<string>;
      const pID: TAqEntityID); overload;

    class procedure InitializeInstance;

    class property Instance: TAqDBCacheMonitor read GetInstance;
  end;

  TAqDBObjectManager<T: TAqDBObject, constructor> = class(TAqDBGenericObjectsManager)
  strict private
    FCache: TAqDBObjectCache;

    procedure AssertObjectInheritance(const pDBObject: TObject);
    function DiscardCache(const pDBObject: TAqDBBaseObject; const pDeleted: Boolean): Boolean;
  strict protected
    function DoGet(const pID: TAqEntityID): TAqDBBaseObject; override;
    function DoNew: TAqDBBaseObject; override;
    procedure DoSave(const pDBObject: TAqDBBaseObject); override;
    function DoDelete(const pDBObject: TAqDBBaseObject): Boolean; override;
    function DoDiscard(const pDBObject: TAqDBBaseObject): Boolean; override;

    procedure StoreInCache(const pObject: T);
    procedure UpdateCache(const pObject: T);

    procedure InitializeCache; virtual;
    procedure LinkTypesToCache(const pTypeLinkerMethod: TProc<PTypeInfo>); virtual;
    procedure ConfigureComplementaryCaches; virtual;

    function GetOnDataChanged: IAqObservable<TAqEntityID>;

    property Cache: TAqDBObjectCache read FCache;
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

    property OnDataChanged: IAqObservable<TAqEntityID> read GetOnDataChanged;
  end;

implementation

uses
  System.Math,
  System.DateUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.Core.Helpers.Rtti,
  AqDrop.Core.Helpers.TObject,
  AqDrop.Core.Helpers.TThread,
  AqDrop.Core.Observers,
  AqDrop.Core.ResourcesControl,
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
  FObjectsManager := pObjectsManager;

  inherited Create;
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

procedure TAqDBObjectManager<T>.StoreInCache(const pObject: T);
begin
  if Assigned(FCache) then
  begin
    FCache.Store(pObject);
  end;
end;

procedure TAqDBObjectManager<T>.UpdateCache(const pObject: T);
begin
  if Assigned(FCache) then
  begin
    FCache.Update(pObject);
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
    FCache := TAqDBObjectCache.Create(T, pType,
      procedure(pTypeLinkerMethod: TProc<PTypeInfo>)
      begin
        LinkTypesToCache(pTypeLinkerMethod);
      end);
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

function TAqDBObjectManager<T>.DiscardCache(const pDBObject: TAqDBBaseObject; const pDeleted: Boolean): Boolean;
var
  lDBObject: T;
begin
  AssertObjectInheritance(pDBObject);

  lDBObject := T(pDBObject);

  Result := Assigned(FCache) and Cache.Keeps(lDBObject);

  if Result then
  begin
    if pDeleted then
    begin
      FCache.Delete(lDBObject);
    end else
    begin
      FCache.Release(lDBObject);
    end;
    Result := FCache.&Type = TAqDBObjectCacheType.octOwnsObjects;
  end;
end;

function TAqDBObjectManager<T>.DoDelete(const pDBObject: TAqDBBaseObject): Boolean;
begin
  ORMManager.Delete(pDBObject, False);
  Result := DiscardCache(pDBObject, True);
end;

function TAqDBObjectManager<T>.DoDiscard(const pDBObject: TAqDBBaseObject): Boolean;
begin
  Result := DiscardCache(pDBObject, False);
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

  UpdateCache(T(pDBObject));
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

function TAqDBObjectManager<T>.GetOnDataChanged: IAqObservable<TAqEntityID>;
begin
  if not Assigned(FCache) then
    raise Exception.Create('Inactive cache for class');

  Result := FCache.OnDataChanged;
end;

procedure TAqDBObjectManager<T>.InitializeCache;
begin
  ConfigureCache(TaqDBObjectCacheType.octOwnsObjects, TTime.EncodeTime(0, 10, 0, 0))
end;

procedure TAqDBObjectManager<T>.LinkTypesToCache(const pTypeLinkerMethod: TProc<PTypeInfo>);
begin
  pTypeLinkerMethod(TypeInfo(T));
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
  end else
  begin
    pObject := nil;
  end;
end;

function TAqDBObjectManager<T>.Get(const pID: TAqEntityID; out pObject: T): Boolean;
var
  lList: IAqResultList<T>;
  lCacheObject: TAqDBObject;
begin
  Result := Assigned(FCache) and FCache.Get(pID, lCacheObject);

  if Result then
  begin
    pObject := T(lCacheObject);
  end else
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
      raise EAqInternal.Create('Incompatible type when creating a new Object Manager: ' + lNew.QualifiedClassName +
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
      StoreInCache(lObject);
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

{ TAqDBObjectCacheContainer }

procedure TAqDBObjectCacheContainer.Change(const pObject: TAqDBObject);
begin
  if FObject <> pObject then
  begin
    FreeAndNil(FObject);

    FObject := pObject;
  end;

  RenewLastAccess;
end;

constructor TAqDBObjectCacheContainer.Create(const pObject: TAqDBObject);
begin
  Change(pObject);
end;

destructor TAqDBObjectCacheContainer.Destroy;
begin
  FObject.Free;

  inherited;
end;

function TAqDBObjectCacheContainer.GetObject: TAqDBObject;
begin
  Result := FObject;
  RenewLastAccess;
end;

function TAqDBObjectCacheContainer.IsExpired(const pTimeOut: TTime): Boolean;
begin
  Result := (pTimeOut > 0) and ((Now - FLastAccess.ToDateTime) >= pTimeOut);
end;

procedure TAqDBObjectCacheContainer.RenewLastAccess;
begin
  FLastAccess := TAqUnixDateTime.Now;
end;

{ TAqDBObjectCache }

function TAqDBObjectCache.AddComplementaryCache<Key>(const pKeyGetter: TFunc<TAqDBObject, Key>): Int32;
begin
  Result := FComplementaryCaches.Add(TAqDBComplementaryCache<Key>.Create(pKeyGetter));
end;

procedure TAqDBObjectCache.Update(const pObject: TAqDBObject);
begin
  Store(pObject);

  NotifyOnDataChanged(pObject.ID);

  TAqDBCacheMonitor.Instance.NotifyCacheAsInvalid(FMonitoringID, FLinkedTypes.ToArray, pObject.ID);
end;

constructor TAqDBObjectCache.Create(const pClass: TAqDBObjectClass; const pType: TAqDBObjectCacheType;
  const pTypeLinkerCallback: TProc<TProc<PTypeInfo>>);
begin
  if not Assigned(pClass) then
  begin
    raise EAqInternal.Create('Class type needed to create a ' + Self.ClassName + '.');
  end;

  if not(pType in octActiveCacheTypes) then
  begin
    raise EAqInternal.Create('Invalid cache type.');
  end;

  FClass := pClass;
  FType := pType;
  FObjects := TAqDictionary<TAqEntityID, TAqDBObjectCacheContainer>.Create(
    [TAqKeyValueOwnership.kvoValue],
    TAqLockerType.lktMultiReaderExclusiveWriter);
  FComplementaryCaches := TAqList<TAqDBBaseComplementaryCache>.Create(True);

  FLinkedTypes := TAqList<string>.Create;
  FMonitoringID := TAqDBCacheMonitor.Instance.RegisterCache(Self, pTypeLinkerCallback);
end;

procedure TAqDBObjectCache.Delete(const pObject: TAqDBObject);
begin
  DoRelease(pObject);

  TAqDBCacheMonitor.Instance.NotifyCacheAsInvalid(FMonitoringID, FLinkedTypes.ToArray, pObject.ID);
  NotifyOnDataChanged(pObject.ID);
end;

destructor TAqDBObjectCache.Destroy;
begin
  if TAqDBCacheMonitor.IsAlive then
  begin
    TAqDBCacheMonitor.Instance.UnregisterCache(FMonitoringID);
  end;

  inherited;
end;

procedure TAqDBObjectCache.DiscardCache(const pID: TAqEntityID);
begin
  NotifyOnDataChanged(pID);

  FObjects.ExecuteLockedForWriting(
    procedure
    var
      lContainer: TAqDBObjectCacheContainer;
    begin
      if FObjects.TryGetValue(pID, lContainer) then
      begin
        DoRelease(lContainer.GetObject);
      end;
    end);
end;

procedure TAqDBObjectCache.DiscardExpiredItems;
begin
  FObjects.ExecuteLockedForWriting(
    procedure
    var
      lContainer: TAqDBObjectCacheContainer;
    begin
      for lContainer in FObjects.Values.ToArray do
      begin
        if lContainer.IsExpired(FTimeOut) then
        begin
          DoRelease(lContainer.GetObject);
        end;
      end;
    end);
end;

procedure TAqDBObjectCache.DoRelease(const pObject: TAqDBObject);
var
  lCache: TAqDBBaseComplementaryCache;
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

function TAqDBObjectCache.Get(const pID: TAqEntityID; out pObject: TAqDBObject): Boolean;
var
  lContainer: TAqDBObjectCacheContainer;
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
          pObject := TAqDBObject(lContainer.GetObject.CloneTo(FClass.CreateNew(nil)));
      end;
    end;
  finally
    FObjects.EndRead;
  end;
end;

function TAqDBObjectCache.GetFromComplementaryCache<Key>(const pCacheIndex: Int32; const pKey: Key; out pObject: TAqDBObject): Boolean;
var
  lCache: TAqDBBaseComplementaryCache;
  lCachedObject: TAqDBObject;
begin
  FObjects.BeginRead;

  try
    lCache := FComplementaryCaches[pCacheIndex];

    Result := lCache is TAqDBComplementaryCache<Key>;

    if Result then
    begin
      Result := TAqDBComplementaryCache<Key>(lCache).Get(pKey, lCachedObject);

      if Result then
      begin
        case FType of
          octOwnsObjects:
            pObject := lCachedObject;
          octCloned:
            pObject := TAqDBObject(lCachedObject.CloneTo(FClass.CreateNew(nil)));
        end;

        FObjects.Items[pObject.ID].RenewLastAccess;
      end;
    end;
  finally
    FObjects.EndRead;
  end;
end;

function TAqDBObjectCache.GetLinkedTypesNames: IAqReadableList<string>;
begin
  Result := FLinkedTypes.GetReadOnlyList;
end;

function TAqDBObjectCache.GetOnDataChanged: IAqObservable<TAqEntityID>;
begin
  Result := TAqResourcesControl.CreateIfNotExists<IAqObservable<TAqEntityID>>(FOnDataChanged,
    function: IAqObservable<TAqEntityID>
    begin
      Result := TAqObservationChannel<TAqEntityID>.Create;
    end);
end;

function TAqDBObjectCache.Keeps(const pObject: TAqDBObject): Boolean;
begin
  FObjects.BeginRead;
  try
    Result := FObjects.ContainsKey(pObject.ID);
  finally
    FObjects.EndRead;
  end;
end;

procedure TAqDBObjectCache.LinkToType(const pType: PTypeInfo);
begin
  FLinkedTypes.Add(TAqRtti.&Implementation.GetType(pType).QualifiedName);
end;

procedure TAqDBObjectCache.NotifyOnDataChanged(const pID: TAqEntityID);
begin
  TAqResourcesControl.ExecuteIfExists<IAqObservable<TAqEntityID>>(FOnDataChanged,
    procedure
    begin
      FOnDataChanged.Notify(pID);
    end);
end;

procedure TAqDBObjectCache.Release(const pObject: TAqDBObject);
begin
  DoRelease(pObject);
end;

procedure TAqDBObjectCache.SetTimeOut(const pTimeOut: TTime);
begin
  FTimeOut := pTimeOut;
end;

procedure TAqDBObjectCache.Store(const pObject: TAqDBObject);
begin
  FObjects.ExecuteLockedForWriting(
    procedure
    var
      lObjectToKeep: TAqDBObject;
      lCache: TAqDBBaseComplementaryCache;
      lNewObject: Boolean;
    begin
      lObjectToKeep := nil;

      case FType of
        octOwnsObjects:
          lObjectToKeep := pObject;
        octCloned:
          lObjectToKeep := TAqDBObject(pObject.CloneTo(FClass.CreateNew(nil)));
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
        FObjects.Add(pObject.ID, TAqDBObjectCacheContainer.Create(lObjectToKeep));
      end else
      begin
        FObjects[pObject.ID].Change(lObjectToKeep);
      end;
    end);
end;

{ TAqDBComplementaryCache<Key> }

procedure TAqDBComplementaryCache<Key>.Add(const pObject: TAqDBObject);
begin
  FCache.Add(FKeyGetter(pObject), pObject);
end;

constructor TAqDBComplementaryCache<Key>.Create(const pKeyGetter: TFunc<TAqDBObject, Key>);
begin
  FCache := TAqDictionary<Key, TAqDBObject>.Create;
  FKeyGetter := pKeyGetter;
end;

function TAqDBComplementaryCache<Key>.Get(const pKey: Key; out pObject: TAqDBObject): Boolean;
begin
  Result := FCache.TryGetValue(pKey, pObject);
end;

procedure TAqDBComplementaryCache<Key>.Remove(const pObject: TAqDBObject);
begin
  FCache.Remove(FKeyGetter(pObject));
end;

procedure TAqDBComplementaryCache<Key>.Replace(const pOld, pNew: TAqDBObject);
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

procedure TAqDBBaseObject.LoadDetails(const pRecursive: Boolean);
var
  lORM: TAqDBORM;
  lDetail: IAqDBORMDetail;
  lDetailItems: IAqReadableList<TObject>;
  lDetailItem: TObject;
begin
  lORM := TAqDBORMReader.Instance.GetORM(Self.ClassType);

  if lORM.HasDetails then
  begin
    for lDetail in lORM.Details do
    begin
      lDetailItems := lDetail.GetItems(Self);

      if pRecursive and (lDetail.ORM.ORMClass.InheritsFrom(TAqDBBaseObject)) then
      begin
        for lDetailItem in lDetailItems do
        begin
          TAqDBBaseObject(lDetailItem).LoadDetails;
        end;
      end;
    end;
  end;
end;

procedure TAqDBBaseObject.InitializeObject;
begin

end;

procedure TAqDBBaseObject.ValidateData;
begin
  // virtual method to be overwritten in order to validate the object's data (or delegate the validation )
  // before it being saved.
end;

{ TAqDBCacheMonitor }

procedure TAqDBCacheMonitor.NotifyCacheAsInvalid(const pSenderID: TAqID; const pTypeNames: TArray<string>;
  const pID: TAqEntityID);
begin
  Caches.DiscardCacheByTypeNames(pSenderID, pTypeNames, pID);

  if Assigned(FCustomMonitor) then
  begin
    FCustomMonitor.NotifyCacheAsInvalid(pTypeNames, pID);
  end;
end;

destructor TAqDBCacheMonitor.Destroy;
begin
  ReleaseCustomMonitorThread;

  inherited;
end;

class function TAqDBCacheMonitor.GetInstance: TAqDBCacheMonitor;
begin
  InitializeInstance;

  Result := FInstance;
end;

class procedure TAqDBCacheMonitor.InitializeInstance;
begin
  if not Assigned(FInstance) then
  begin
    TThread.RunOnMainThread(
      procedure
      begin
        FInstance := TAqDBCacheMonitor.Create;
      end,
      procedure
      begin
        TAqDBCacheMonitor.InitializeInstance;
      end);
  end;
end;

class function TAqDBCacheMonitor.IsAlive: Boolean;
begin
  Result := Assigned(FInstance);
end;

procedure TAqDBCacheMonitor.NotifyCacheAsInvalid(const pTypeNames: TArray<string>; const pID: TAqEntityID);
begin
  NotifyCacheAsInvalid(TAqIDGenerator.GetEmpty, pTypeNames, pID);
end;

procedure TAqDBCacheMonitor.ReleaseCustomMonitorThread;
begin
  if Assigned(FCustomMonitorThread) then
  begin
    FCustomMonitorThread.Terminate;
    FCustomMonitorThread.WaitFor;
    FreeAndNil(FCustomMonitorThread);
  end;
end;

class procedure TAqDBCacheMonitor.ReleaseInstance;
begin
  TThread.RunOnMainThread(
    procedure
    begin
      FreeAndNil(FInstance);
    end);
end;

procedure TAqDBCacheMonitor.SetCustomMonitor(pCustomMonitor: IAqDBCustomCacheMonitor);
begin
  ReleaseCustomMonitorThread;

  FCustomMonitor := pCustomMonitor;

  if Assigned(FCustomMonitor) then
  begin
    FCustomMonitorThread := TThread.CreateAnonymousThread(
      procedure
      var
        lNextCicle: TDateTime;
      begin
        while not TThread.CheckTerminated do
        begin
          FCustomMonitor.Monitor(Caches);

          lNextCicle := Now + FCustomMonitor.GetTimeBetweenCicles;

          while not TThread.CheckTerminated and (Now < lNextCicle) do
          begin
            Sleep(100);
          end;
        end;
      end);
    FCustomMonitorThread.FreeOnTerminate := False;
    FCustomMonitorThread.Start;
  end;
end;

initialization

finalization
  TAqDBCacheMonitor.ReleaseInstance;

end.
