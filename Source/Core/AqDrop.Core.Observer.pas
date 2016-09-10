unit AqDrop.Core.Observer;

interface

uses
  System.Classes, System.Generics.Collections, AqDrop.Core.InterfacedObject,
  AqDrop.Core.Observer.Intf, AqDrop.Core.AnonymousMethods, AqDrop.Core.Collections;

type
  TAqObserver = class(TAqInterfacedObject, IAqObserver)
  strict protected
    class function MustCountReferences: Boolean; override;
  public
    procedure Notify(const Sender: TObject); virtual; abstract;
  end;

  TAqObserverByMethod = class(TAqObserver)
  strict private
    FObserverMethod: TAqNotifyMethod;
  public
    constructor Create(const pMethod: TAqNotifyMethod);

    procedure Notify(const Sender: TObject); override;
  end;

  TAqObserverByEvent = class(TAqObserver)
  strict private
    FObserverEvent: TNotifyEvent;
  public
    constructor Create(const pEvent: TNotifyEvent);

    procedure Notify(const Sender: TObject); override;
  end;

  TAqObserversChannel = class
  strict private
    FObservers: TAqIDDictionary<IAqObserver>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Notify(Sender: TObject);
    function RegisterObserver(pObserver: IAqObserver): TAqID;
    procedure UnregisterObserver(const pObserverID: TAqID);
  end;

resourcestring
  StrItWasNotPossibleToRemoveTheObserverFromTheChannelObserverNotFound =
    'It was not possible to remove the observer from the channel (observer not found).';

implementation

uses
  AqDrop.Core.Exceptions;

{ TAqObserverByMethod }

constructor TAqObserverByMethod.Create(const pMethod: TAqNotifyMethod);
begin
  inherited Create;

  FObserverMethod := pMethod;
end;

procedure TAqObserverByMethod.Notify(const Sender: TObject);
begin
  FObserverMethod(Sender);
end;

{ TAqObserverByEvent }

constructor TAqObserverByEvent.Create(const pEvent: TNotifyEvent);
begin
  inherited Create;

  FObserverEvent := pEvent;
end;

procedure TAqObserverByEvent.Notify(const Sender: TObject);
begin
  FObserverEvent(Sender);
end;

{ TAqObserversChannel }

function TAqObserversChannel.RegisterObserver(pObserver: IAqObserver): TAqID;
begin
  Result := FObservers.Add(pObserver);
end;

constructor TAqObserversChannel.Create;
begin
  inherited;

  FObservers := TAqIDDictionary<IAqObserver>.Create(False);
end;

procedure TAqObserversChannel.UnregisterObserver(const pObserverID: TAqID);
begin
  if not FObservers.ContainsKey(pObserverID) then
  begin
    raise EAqInternal.Create(StrItWasNotPossibleToRemoveTheObserverFromTheChannelObserverNotFound);
  end;

  FObservers.Remove(pObserverID);
end;

destructor TAqObserversChannel.Destroy;
begin
  FObservers.Free;

  inherited;
end;

procedure TAqObserversChannel.Notify(Sender: TObject);
var
  lObserver: IAqObserver;
begin
  for lObserver in FObservers.Values do
  begin
    lObserver.Notify(Sender);
  end;
end;

{ TAqNotificacao }

class function TAqObserver.MustCountReferences: Boolean;
begin
  Result := True;
end;

end.
