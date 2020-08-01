unit AqDrop.Core.Observers;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  AqDrop.Core.Types,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Observers.Intf,
  AqDrop.Core.Collections.Intf;

type
  TAqNotifyEvent<T> = procedure(pMessage: T) of object;

  TAqObservationChannel<T> = class(TAqARCObject, IAqCustomObservable<T>, IAqObservable<T>)
  strict private
    FObservers: IAqIDDictionary<IAqObserver<T>>;
  public
    constructor Create(const pCreateLocker: Boolean = False);

    procedure Notify(pMessage: T);

    function RegisterObserver(pObserver: IAqObserver<T>): TAqID; overload;
    function RegisterObserver(pMethod: TProc<T>): TAqID; overload;
    function RegisterObserver(pEvent: TAqGenericEvent<T>): TAqID; overload;

    procedure UnregisterObserver(const pObserverID: TAqID);
  end;

  TAqObservable<T> = class(TAqObservationChannel<T>);

  TAqObserver<T> = class(TAqARCObject, IAqObserver<T>)
  public
    procedure Observe(const pMessage: T); virtual; abstract;
  end;

  TAqObserverByMethod<T> = class(TAqObserver<T>)
  strict private
    FObserverMethod: TProc<T>;
  public
    constructor Create(const pMethod: TProc<T>);

    procedure Observe(const pMessage: T); override;
  end;

  TAqObserverByEvent<T> = class(TAqObserver<T>)
  strict private
    FObserverEvent: TAqNotifyEvent<T>;
  public
    constructor Create(const pEvent: TAqNotifyEvent<T>);

    procedure Observe(const pMessage: T); override;
  end;

  TAqObservablesChain<T> = class(TAqARCObject, IAqObservablesChain<T>)
  strict private
    [weak]
    FParent: TAqObservablesChain<T>;
    FChildren: IAqList<TAqObservablesChain<T>>;
    FObservationChannel: IAqObservable<T>;

    function ElectNewKeyNode: TAqObservablesChain<T>;
    procedure ReleaseChild(const pChild: TAqObservablesChain<T>; const pNewKeyNode: TAqObservablesChain<T>);
    function GetObservationChannel: IAqObservable<T>;
  strict protected
    procedure DoNotifyObservers(pMessage: T);
  public
    constructor Create;
    destructor Destroy; override;

    function Share: IAqObservablesChain<T>;
    procedure Unchain;

    procedure Notify(pMessage: T);

    property ObservationChannel: IAqObservable<T> read GetObservationChannel;
  end;

resourcestring
  StrItWasNotPossibleToRemoveTheObserverFromTheChannelObserverNotFound =
    'It was not possible to remove the observer from the channel (observer not found).';

implementation

uses
  AqDrop.Core.Exceptions,
  AqDrop.Core.Collections;

{ TAqObserverByMethod<T> }

constructor TAqObserverByMethod<T>.Create(const pMethod: TProc<T>);
begin
  inherited Create;

  FObserverMethod := pMethod;
end;

procedure TAqObserverByMethod<T>.Observe(const pMessage: T);
begin
  FObserverMethod(pMessage);
end;

{ TAqObserverByEvent<T> }

constructor TAqObserverByEvent<T>.Create(const pEvent: TAqNotifyEvent<T>);
begin
  inherited Create;

  FObserverEvent := pEvent;
end;

procedure TAqObserverByEvent<T>.Observe(const pMessage: T);
begin
  FObserverEvent(pMessage);
end;

{ TAqObservationChannel<T> }

function TAqObservationChannel<T>.RegisterObserver(pObserver: IAqObserver<T>): TAqID;
begin
  if FObservers.HasLocker then
  begin
    FObservers.BeginWrite;
  end;

  try
    Result := FObservers.Add(pObserver);
  finally
    if FObservers.HasLocker then
    begin
      FObservers.EndWrite;
    end;
  end;
end;

constructor TAqObservationChannel<T>.Create(const pCreateLocker: Boolean = False);
var
  lLockerType: TAqLockerType;
begin
  inherited Create;

  if pCreateLocker then
  begin
    lLockerType := TAqLockerType.lktNone;
  end else
  begin
    lLockerType := TAqLockerType.lktMultiReaderExclusiveWriter;
  end;

  FObservers := TAqIDDictionary<IAqObserver<T>>.Create(False, lLockerType);
end;

procedure TAqObservationChannel<T>.UnregisterObserver(const pObserverID: TAqID);
begin
  if not pObserverID.IsEmpty then
  begin
    if FObservers.HasLocker then
    begin
      FObservers.BeginWrite;
    end;

    try
      if not FObservers.ContainsKey(pObserverID) then
      begin
        raise EAqInternal.Create(StrItWasNotPossibleToRemoveTheObserverFromTheChannelObserverNotFound);
      end;

      FObservers.Remove(pObserverID);
    finally
      if FObservers.HasLocker then
      begin
        FObservers.EndWrite;
      end;
    end;
  end;
end;

procedure TAqObservationChannel<T>.Notify(pMessage: T);
var
  lObserver: IAqObserver<T>;
begin
  if FObservers.HasLocker then
  begin
    FObservers.BeginRead;
  end;

  try
    for lObserver in FObservers.Values do
    begin
      lObserver.Observe(pMessage);
    end;
  finally
    if FObservers.HasLocker then
    begin
      FObservers.EndRead;
    end;
  end;
end;

function TAqObservationChannel<T>.RegisterObserver(pEvent: TAqGenericEvent<T>): TAqID;
begin
  Result := RegisterObserver(TAqObserverByEvent<T>.Create(pEvent));
end;

function TAqObservationChannel<T>.RegisterObserver(pMethod: TProc<T>): TAqID;
begin
  Result := RegisterObserver(TAqObserverByMethod<T>.Create(pMethod));
end;

{ TAqObservablesChain<T> }

constructor TAqObservablesChain<T>.Create;
begin
  FObservationChannel := TAqObservationChannel<T>.Create;
  FChildren := TAqList<TAqObservablesChain<T>>.Create;
end;

destructor TAqObservablesChain<T>.Destroy;
begin
  Unchain;

  inherited;
end;

procedure TAqObservablesChain<T>.DoNotifyObservers(pMessage: T);
var
  lChild: TAqObservablesChain<T>;
begin
  FObservationChannel.Notify(pMessage);

  for lChild in FChildren do
  begin
    lChild.DoNotifyObservers(pMessage);
  end;
end;

function TAqObservablesChain<T>.ElectNewKeyNode: TAqObservablesChain<T>;
var
  lChild: TAqObservablesChain<T>;
begin
  if FChildren.Count > 0 then
  begin
    Result := FChildren.Extract;

    for lChild in FChildren do
    begin
      Result.FChildren.Add(lChild);
    end;

    Result.FParent := FParent;
  end else begin
    Result := nil;
  end;
end;

function TAqObservablesChain<T>.GetObservationChannel: IAqObservable<T>;
begin
  Result := FObservationChannel;
end;

procedure TAqObservablesChain<T>.Notify(pMessage: T);
var
  lChild: TAqObservablesChain<T>;
begin
  if Assigned(FParent) then
  begin
    FParent.Notify(pMessage);
  end else begin
    DoNotifyObservers(pMessage);
  end;
end;

procedure TAqObservablesChain<T>.ReleaseChild(const pChild, pNewKeyNode: TAqObservablesChain<T>);
begin
  FChildren.DeleteItem(pChild);

  if Assigned(pNewKeyNode) then
  begin
    FChildren.Add(pNewKeyNode);
  end;
end;

function TAqObservablesChain<T>.Share: IAqObservablesChain<T>;
var
  lChild: TAqObservablesChain<T>;
begin
  lChild := TAqObservablesChain<T>.Create;

  try
    lChild.FParent := Self;
    FChildren.Add(lChild);
    Result := lChild;
  except
    lChild.Free;
    raise;
  end;
end;

procedure TAqObservablesChain<T>.Unchain;
var
  lNewKeyNode: TAqObservablesChain<T>;
begin
  lNewKeyNode := ElectNewKeyNode;

  if Assigned(FParent) then
  begin
    FParent.ReleaseChild(Self, lNewKeyNode);
  end;

  FChildren.Clear;
end;

end.
