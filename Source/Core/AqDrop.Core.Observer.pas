unit AqDrop.Core.Observer;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Observer.Intf,
  AqDrop.Core.Collections;

type
  TAqNotifyEvent<T> = procedure(pMessage: T) of object;

  TAqObserver<T> = class(TAqInterfacedObject, IAqObserver<T>)
  strict protected
{$IFNDEF AUTOREFCOUNT}
    class function MustCountReferences: Boolean; override;
{$ENDIF}
  public
    procedure Notify(const pMessage: T); virtual; abstract;
  end;

  TAqObserverByMethod<T> = class(TAqObserver<T>)
  strict private
    FObserverMethod: TProc<T>;
  public
    constructor Create(const pMethod: TProc<T>);

    procedure Notify(const pMessage: T); override;
  end;

  TAqObserverByEvent<T> = class(TAqObserver<T>)
  strict private
    FObserverEvent: TAqNotifyEvent<T>;
  public
    constructor Create(const pEvent: TAqNotifyEvent<T>);

    procedure Notify(const pMessage: T); override;
  end;

  TAqObserversChannel<T> = class
  strict private
    FObservers: TAqIDDictionary<IAqObserver<T>>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Notify(pMessage: T);
    function RegisterObserver(pObserver: IAqObserver<T>): TAqID;
    procedure UnregisterObserver(const pObserverID: TAqID);
  end;

resourcestring
  StrItWasNotPossibleToRemoveTheObserverFromTheChannelObserverNotFound =
    'It was not possible to remove the observer from the channel (observer not found).';

implementation

uses
  AqDrop.Core.Exceptions;

{ TAqObserverByMethod<T> }

constructor TAqObserverByMethod<T>.Create(const pMethod: TProc<T>);
begin
  inherited Create;

  FObserverMethod := pMethod;
end;

procedure TAqObserverByMethod<T>.Notify(const pMessage: T);
begin
  FObserverMethod(pMessage);
end;

{ TAqObserverByEvent<T> }

constructor TAqObserverByEvent<T>.Create(const pEvent: TAqNotifyEvent<T>);
begin
  inherited Create;

  FObserverEvent := pEvent;
end;

procedure TAqObserverByEvent<T>.Notify(const pMessage: T);
begin
  FObserverEvent(pMessage);
end;

{ TAqObserversChannel<T> }

function TAqObserversChannel<T>.RegisterObserver(pObserver: IAqObserver<T>): TAqID;
begin
  Result := FObservers.Add(pObserver);
end;

constructor TAqObserversChannel<T>.Create;
begin
  inherited;

  FObservers := TAqIDDictionary<IAqObserver<T>>.Create(False);
end;

procedure TAqObserversChannel<T>.UnregisterObserver(const pObserverID: TAqID);
begin
  if not FObservers.ContainsKey(pObserverID) then
  begin
    raise EAqInternal.Create(StrItWasNotPossibleToRemoveTheObserverFromTheChannelObserverNotFound);
  end;

  FObservers.Remove(pObserverID);
end;

destructor TAqObserversChannel<T>.Destroy;
begin
  FObservers.Free;

  inherited;
end;

procedure TAqObserversChannel<T>.Notify(pMessage: T);
var
  lObserver: IAqObserver<T>;
begin
  for lObserver in FObservers.Values do
  begin
    lObserver.Notify(pMessage);
  end;
end;

{ TAqNotificacao<T> }

{$IFNDEF AUTOREFCOUNT}
class function TAqObserver<T>.MustCountReferences: Boolean;
begin
  Result := True;
end;
{$ENDIF}

end.
