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

  IAqObserver<T> = interface
    ['{401F5B12-8E60-4694-8CB4-761EE82FE60C}']

    procedure Observe(const pMessage: T);
  end;

  {TODO 2 -oTatu -cMelhoria: Criar interface genérica para cadeias (relação parent x childreen), com métodos que permitam progagar a ação na cadeia, total ou parcial
    a ideia é usar no cursor em cadeia, para que o cursor possa ter acesso ao seu parent, ou seus filhos, e não somente à cadeia de notificadores, seria algo como
    IAqChain<ITSFCursorEmCadeia>}

  IAqObservablesChain<T> = interface
    ['{217C37C5-70C2-497E-B3CB-A08DCAE3A117}']

    function Share: IAqObservablesChain<T>;
    procedure Unchain;

    procedure Notify(pMessage: T);
    function GetObservationChannel: IAqObservable<T>;

    property ObservationChannel: IAqObservable<T> read GetObservationChannel;
  end;

  IAqDestructionObservable = interface
    ['{810CA67F-30BB-41CF-A1A9-6E744E238319}']

    function RegisterDestructionObserver(const pMethod: TProc<TObject>): TAqID;
    procedure UnregisterDestructionObserver(const pID: TAqID);
  end;

implementation

end.
