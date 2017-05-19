unit AqDrop.Core.Observer.Intf;

interface

type
  IAqObserver<T> = interface(IInterface)
    ['{401F5B12-8E60-4694-8CB4-761EE82FE60C}']
    procedure Notify(const pMessage: T);
  end;

implementation

end.
