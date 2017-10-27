unit AqDrop.Core.Observable;

{$I 'AqDrop.Core.FullRTTIForMethods.inc'}

interface

uses
  System.Rtti,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  AqDrop.Core.Attributes,
  AQDrop.Core.Observer.Intf,
  AqDrop.Core.Observer,
  AqDrop.Core.Collections;

type
  AqNotifyObserversTag = class(TAqAttribute);

  TAqObservable = class
  strict private
    FObserversChannel: TAqObserversChannel<TObject>;
    FUpdating: Boolean;

    class var FLocker: TCriticalSection;
    class var FInterceptors: TAqDictionary<string, TVirtualMethodInterceptor>;
    class function GetInterceptor: TVirtualMethodInterceptor;

    class procedure Proxify(const pInstance: TAqObservable);
    class procedure Unproxify(const pInstance: TAqObservable);
  private
    class procedure _Initialize;
    class procedure _Finalize;
  strict protected
    procedure SetAndNotify<T>(var pTarget: T; const pValue: T);
    procedure Notify; virtual;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;

    function RegisterObserver(const pObserverEvent: TAqNotifyEvent<TObject>): TAqID; overload;
    function RegisterObserver(const pObserverMethod: TProc<TObject>): TAqID; overload;
    function RegisterObserver(pObserver: IAqObserver<TObject>): TAqID; overload;
    procedure UnregisterObserver(const pObserverID: Int32);
  end;

implementation

uses
  AqDrop.Core.Collections.Intf, AqDrop.Core.Helpers.TRttiObject;

{ TAqObservable }

function TAqObservable.RegisterObserver(const pObserverEvent: TAqNotifyEvent<TObject>): TAqID;
begin
  Result := FObserversChannel.RegisterObserver(TAqObserverByEvent<TObject>.Create(pObserverEvent));
end;

function TAqObservable.RegisterObserver(const pObserverMethod: TProc<TObject>): TAqID;
begin
  Result := FObserversChannel.RegisterObserver(TAqObserverByMethod<TObject>.Create(pObserverMethod));
end;

procedure TAqObservable.BeginUpdate;
begin
  FUpdating := True;
end;

constructor TAqObservable.Create;
begin
  inherited;

  FObserversChannel := TAqObserversChannel<TObject>.Create;

  Proxify(Self);
end;

class procedure TAqObservable.Unproxify(const pInstance: TAqObservable);
begin
  FLocker.Enter;

  try
    GetInterceptor.Unproxify(pInstance);
  finally
    FLocker.Leave;
  end;
end;

procedure TAqObservable.UnregisterObserver(const pObserverID: Int32);
begin
  FObserversChannel.UnregisterObserver(pObserverID);
end;

class procedure TAqObservable._Finalize;
begin
  FInterceptors.Free;
  FLocker.Free;
end;

class procedure TAqObservable._Initialize;
begin
  FLocker := TCriticalSection.Create;
end;

destructor TAqObservable.Destroy;
begin
  Unproxify(Self);
  FObserversChannel.Free;

  inherited;
end;

procedure TAqObservable.EndUpdate;
begin
  if FUpdating then
  begin
    FUpdating := False;
    Notify;
  end;
end;

class function TAqObservable.GetInterceptor: TVirtualMethodInterceptor;
begin
  if not Assigned(FInterceptors) then
  begin
    FInterceptors := TAqDictionary<string, TVirtualMethodInterceptor>.Create([TAqKeyValueOwnership.kvoValue]);
  end;

  if not FInterceptors.TryGetValue(Self.QualifiedClassName, Result) then
  begin
    Result := TVirtualMethodInterceptor.Create(Self);

    try
      Result.OnAfter :=
        procedure(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; var Result: TValue)
        var
          lAttribute: AqNotifyObserversTag;
        begin
          if Method.GetAttribute<AqNotifyObserversTag>(lAttribute) then
          begin
            (Instance as Self).Notify;
          end;
        end;

      FInterceptors.Add(Self.QualifiedClassName, Result);
    except
      Result.Free;
      raise;
    end;
  end;
end;

procedure TAqObservable.Notify;
begin
  if not FUpdating then
  begin
    FObserversChannel.Notify(Self);
  end;
end;

class procedure TAqObservable.Proxify(const pInstance: TAqObservable);
begin
  FLocker.Enter;

  try
    GetInterceptor.Proxify(pInstance);
  finally
    FLocker.Leave;
  end;
end;

procedure TAqObservable.SetAndNotify<T>(var pTarget: T; const pValue: T);
begin
  pTarget := pValue;
  Notify;
end;

function TAqObservable.RegisterObserver(pObserver: IAqObserver<TObject>): TAqID;
begin
  Result := FObserversChannel.RegisterObserver(pObserver);
end;

initialization
  TAqObservable._Initialize;

finalization
  TAqObservable._Finalize;

end.
