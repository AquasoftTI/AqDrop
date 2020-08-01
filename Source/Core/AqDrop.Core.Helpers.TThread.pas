unit AqDrop.Core.Helpers.TThread;

interface

uses
  System.Classes;

type
  TAqThreadHelper = class helper for TThread
  public
    class procedure RunOnMainThread(const pMethod: TThreadProcedure); overload; static;
    class procedure RunOnMainThread(
      const pIfAlreadyOnMainThreadMethod, pSynchronizableMethod: TThreadProcedure); overload; static;
  end;

implementation

{ TAqThreadHelper }

class procedure TAqThreadHelper.RunOnMainThread(const pMethod: TThreadProcedure);
begin
  RunOnMainThread(pMethod, pMethod);
end;

class procedure TAqThreadHelper.RunOnMainThread(
  const pIfAlreadyOnMainThreadMethod, pSynchronizableMethod: TThreadProcedure);
begin
  if TThread.Current.ThreadID = System.MainThreadID then
  begin
    pIfAlreadyOnMainThreadMethod();
  end else
  begin
    TThread.Synchronize(nil, pSynchronizableMethod);
  end;
end;

end.
