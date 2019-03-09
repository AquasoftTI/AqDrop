unit AqDrop.Core.Observers.Intf;

interface

uses
  System.SysUtils,
  AqDrop.Core.Types;

type
  IAqObserver<T> = interface;

  IAqCustomObservable<T> = interface
    ['{743B970B-D83B-4085-8A4E-57637470F189}']

    function RegisterObserver(pObserver: IAqObserver<T>): TAqID;

    procedure Notify(pMessage: T);

    procedure UnregisterObserver(const pObserverID: TAqID);
  end;

  IAqObservable<T> = interface(IAqCustomObservable<T>)
    ['{40170293-F0C4-4A7A-9AFF-83FCB1E8000E}']

    function RegisterObserver(pMethod: TProc<T>): TAqID; overload;
    function RegisterObserver(pEvent: TAqGenericEvent<T>): TAqID; overload;
  end;

  IAqObserver<T> = interface(IInterface)
    ['{401F5B12-8E60-4694-8CB4-761EE82FE60C}']

    procedure Observe(const pMessage: T);
  end;

  IAqObservablesChain<T> = interface
    ['{217C37C5-70C2-497E-B3CB-A08DCAE3A117}']

    function Share: IAqObservablesChain<T>;
    procedure Unchain;

    procedure Notify(pMessage: T);
    function GetObservationChannel: IAqObservable<T>;

    property ObservationChannel: IAqObservable<T> read GetObservationChannel;
  end;

implementation

end.
