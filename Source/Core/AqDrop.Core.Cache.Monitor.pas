unit AqDrop.Core.Cache.Monitor;

interface

uses
  System.SysUtils,
  System.TypInfo,
  System.Classes,
  AqDrop.Core.Types,
  AqDrop.Core.Cache.Intf,
  AqDrop.Core.Collections.Intf;

type
  TAqCaches<I: IAqMonitorableCache> = class
  strict private
    FCaches: IAqIDDictionary<I>;
    FCachesByTypeName: IAqDictionary<string, IAqList<TAqID>>;

    procedure ExecuteForEachCache(const pProcessingMethod: TProc<I>);
  public
    constructor Create;

    function RegisterCache(pCache: I; const pTypeLinkerCallback: TProc<TProc<PTypeInfo>>): TAqID;
    procedure UnregisterCache(const pID: TAqID);

    procedure DiscardExpiredItems;
    procedure DiscardCacheByTypeNames(const pTypeNames: TArray<string>; const pID: TAqEntityID); overload;
    procedure DiscardCacheByTypeNames(const pSenderID: TAqID; const pTypeNames: TArray<string>;
      const pID: TAqEntityID); overload;
  end;

  TAqCacheMonitor<I: IAqMonitorableCache> = class
  strict private
    FCaches: TAqCaches<I>;
    FThread: TThread;
  strict protected
    property Caches: TAqCaches<I> read FCaches;
  public
    constructor Create;
    destructor Destroy; override;

    function RegisterCache(pCache: I; const pTypeLinkerCallback: TProc<TProc<PTypeInfo>>): TAqID;
    procedure UnregisterCache(const pID: TAqID);
  end;

implementation

uses
  System.DateUtils,
  System.Rtti,
  AqDrop.Core.Helpers,
  AqDrop.Core.Helpers.Rtti,
  AqDrop.Core.Collections;

{ TAqCacheMonitor<I> }

constructor TAqCacheMonitor<I>.Create;
begin
  FCaches := TAqCaches<I>.Create;
  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      lNextCicle: TDateTime;
      lCache: I;
    begin
      while not TThread.CheckTerminated do
      begin
        FCaches.DiscardExpiredItems;

        lNextCicle := Now.IncSecond(10);

        while not TThread.CheckTerminated and (Now < lNextCicle) do
        begin
          Sleep(100);
        end;
      end;
    end);
  FThread.FreeOnTerminate := False;
  FThread.Start;
end;

destructor TAqCacheMonitor<I>.Destroy;
begin
  FThread.Terminate;
  FThread.WaitFor;
  FThread.Free;

  FCaches.Free;

  inherited;
end;

function TAqCacheMonitor<I>.RegisterCache(pCache: I; const pTypeLinkerCallback: TProc<TProc<PTypeInfo>>): TAqID;
begin
  Result := FCaches.RegisterCache(pCache, pTypeLinkerCallback);
end;

procedure TAqCacheMonitor<I>.UnregisterCache(const pID: TAqID);
begin
  FCaches.UnregisterCache(pID);
end;

{ TAqCaches<I> }

constructor TAqCaches<I>.Create;
begin
  FCaches := TAqIDDictionary<I>.Create(TAqLockerType.lktMultiReaderExclusiveWriter);
  FCachesByTypeName := TAqDictionary<string, IAqList<TAqID>>.Create;
end;

procedure TAqCaches<I>.DiscardCacheByTypeNames(const pTypeNames: TArray<string>; const pID: TAqEntityID);
begin
  DiscardCacheByTypeNames(TAqIDGenerator.GetEmpty, pTypeNames, pID);
end;

procedure TAqCaches<I>.DiscardCacheByTypeNames(const pSenderID: TAqID; const pTypeNames: TArray<string>;
  const pID: TAqEntityID);
var
  lCachesToDiscard: IAqList<TAqID>;
  lTypeName: string;
  lCachesIDs: IAqList<TAqID>;
  lCacheID: TAqID;
  lCache: I;
begin
  FCaches.BeginRead;

  try
    lCachesToDiscard := TAqList<TAqID>.Create;

    for lTypeName in pTypeNames do
    begin
      if FCachesByTypeName.TryGetValue(lTypeName, lCachesIDs) then
      begin
        for lCacheID in lCachesIDs do
        begin
          if (lCacheID <> pSenderID) and not lCachesToDiscard.Contains(lCacheID) then
          begin
            lCachesToDiscard.Add(lCacheID);
          end;
        end;
      end;
    end;

    for lCacheID in lCachesToDiscard do
    begin
      if FCaches.TryGetValue(lCacheID, lCache) then
      begin
        lCache.DiscardCache(pID);
      end;
    end;
  finally
    FCaches.EndRead;
  end;
end;

procedure TAqCaches<I>.DiscardExpiredItems;
begin
  ExecuteForEachCache(
    procedure(pCache: I)
    begin
      pCache.DiscardExpiredItems;
    end);
end;

procedure TAqCaches<I>.ExecuteForEachCache(const pProcessingMethod: TProc<I>);
var
  lCache: I;
begin
  FCaches.BeginRead;

  try
    for lCache in FCaches.Values.ToArray do
    begin
      pProcessingMethod(lCache);
    end;
  finally
    FCaches.EndRead;
  end;
end;

function TAqCaches<I>.RegisterCache(pCache: I; const pTypeLinkerCallback: TProc<TProc<PTypeInfo>>): TAqID;
var
  lID: TAqID;
begin
  FCaches.BeginWrite;

  try
    lID := FCaches.Add(pCache);

    pTypeLinkerCallback(
      procedure(pType: PTypeInfo)
      var
        lType: TRttiType;
      begin
        pCache.LinkToType(pType);

        lType := TAqRtti.&Implementation.GetType(pType);

        FCachesByTypeName.GetOrCreate(lType.QualifiedName,
          function: IAqList<TAqID>
          begin
            Result := TAqList<TAqID>.Create;
          end).Add(lID);
      end);
  finally
    FCaches.EndWrite;
  end;

  Result := lID;
end;

procedure TAqCaches<I>.UnregisterCache(const pID: TAqID);
var
  lCache: I;
  lLinkedTypeName: string;
  lCachesIDs: IAqList<TAqID>;
begin
  FCaches.BeginWrite;

  try
    if FCaches.TryGetValue(pID, lCache) then
    begin
      for lLinkedTypeName in lCache.GetLinkedTypesNames do
      begin
        if FCachesByTypeName.TryGetValue(lLinkedTypeName, lCachesIDs) then
        begin
          lCachesIDs.DeleteItem(pID);
        end;
      end;

      FCaches.Remove(pID);
    end;
  finally
    FCaches.EndWrite;
  end;
end;

end.
