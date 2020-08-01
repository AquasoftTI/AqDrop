unit AqDrop.Core.Monitor;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  System.Classes,
  System.DateUtils,
  AqDrop.Core.Collections.Intf;

type
  TAqMonitor = class
  strict private
    FCriticalSection: TCriticalSection;
    FLastUse: TDateTime;

    procedure Enter; overload;
    procedure Exit; overload;

    class var FMonitors: IAqDictionary<Pointer, TAqMonitor>;
    class var FExpiredItemsThread: TThread;
    class function GetMonitor(const pPointer: Pointer): TAqMonitor;
  private
    class procedure Initialize;
    class procedure Finalize;
  public
    constructor Create;
    destructor Destroy; override;

    class procedure Enter(const pPointer: Pointer); overload;
    class procedure Exit(const pPointer: Pointer); overload;
    class procedure Protect(const pPointer: Pointer; const pMonitoredMethod: TProc);
  end;

implementation

uses
  AqDrop.Core.Collections,
  AqDrop.Core.Helpers;

{ TAqMonitor }

constructor TAqMonitor.Create;
begin
  FCriticalSection := TCriticalSection.Create;
end;

destructor TAqMonitor.Destroy;
begin
  FCriticalSection.Free;

  inherited;
end;

procedure TAqMonitor.Enter;
begin
  FCriticalSection.Enter;
  FLastUse := Now;
end;

procedure TAqMonitor.Exit;
begin
  FLastUse := Now;
  FCriticalSection.Leave;
end;

class procedure TAqMonitor.Finalize;
begin
  FExpiredItemsThread.Terminate;
  FExpiredItemsThread.WaitFor;
  FExpiredItemsThread.Free;
  FMonitors := nil;
end;

class function TAqMonitor.GetMonitor(const pPointer: Pointer): TAqMonitor;
begin
  Result := FMonitors.GetOrCreate(pPointer,
    function: TAqMonitor
    begin
      Result := TAqMonitor.Create;
    end, TAqCreateItemLockerBehaviour.HoldLockerWhileCreating);
end;

class procedure TAqMonitor.Initialize;
begin
  FMonitors := TAqDictionary<Pointer, TAqMonitor>.Create([TAqKeyValueOwnership.kvoValue], TAqLockerType.lktMultiReaderExclusiveWriter);
  FExpiredItemsThread := TThread.CreateAnonymousThread(
    procedure
    var
      lKeys: TArray<Pointer>;
      lKey: Pointer;
      lCut: TDateTime;
      lNextCicle: TDateTime;
    begin
      lNextCicle := 0;
      while not TThread.CheckTerminated do
      begin
        if Now >= lNextCicle then
        begin
          lCut := Now.IncMinute(-15);

          FMonitors.BeginWrite;

          try
            lKeys := FMonitors.Keys.ToArray;
            for lKey in lKeys do
            begin
              if FMonitors.Items[lKey].FLastUse < lCut then
              begin
                FMonitors.Remove(lKey);
              end;
            end;
          finally
            FMonitors.EndWrite;
          end;

          lNextCicle := Now.IncMinute();
        end else
        begin
          Sleep(100);
        end;
      end;
    end);

  FExpiredItemsThread.FreeOnTerminate := False;
  FExpiredItemsThread.Start;
end;

class procedure TAqMonitor.Protect(const pPointer: Pointer; const pMonitoredMethod: TProc);
var
  lMonitor: TAqMonitor;
begin
  lMonitor := GetMonitor(pPointer);

  lMonitor.Enter;

  try
    pMonitoredMethod;
  finally
    lMonitor.Exit;
  end;
end;

class procedure TAqMonitor.Enter(const pPointer: Pointer);
begin
  GetMonitor(pPointer).Enter;
end;

class procedure TAqMonitor.Exit(const pPointer: Pointer);
begin
  GetMonitor(pPointer).Exit;
end;

initialization
  TAqMonitor.Initialize;

finalization
  TAqMonitor.Finalize;

end.
