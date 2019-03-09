unit AqDrop.Core.ExecutionQueue;

interface

uses
  System.SysUtils,
  System.Classes,
  AqDrop.Core.Types,
  AqDrop.Core.Collections.Intf;

type
  TAqTaskStatus = (tksWaiting, tksExecuting, tksDone, tksError);
  TAqExecutionQueueStatus = (eqsWaiting, eqsExecuting, eqsDone, eqsFinishing, eqsFinished);

  TAqTask = class
  strict private
    FID: TAqID;
    FStatus: TAqTaskStatus;
    FErrorMessage: string;
  private
    procedure SetID(pID: TAqID);

    procedure SetStatus(const pStatus: TAqTaskStatus);
    procedure SetError(const pErrorMessage: string);
  strict protected
    procedure DoExecute; virtual; abstract;

    function VerifyIfShouldReleaseWhenFinished: Boolean; virtual;
  public
    procedure Execute;

    property ID: TAqID read FID;
    property Status: TAqTaskStatus read FStatus;
    property ReleaseWhenFinished: Boolean read VerifyIfShouldReleaseWhenFinished;
  end;

  TAqCustomExecutionQueue = class
  strict private
    FStatus: TAqExecutionQueueStatus;
    FTasks: IAqIDDictionary<TAqTask>;
    FTasksOrder: IAqList<TAqID>;
    FNextTaskIndex: Int32;
  strict protected
    function IsLockerNeeded: Boolean; virtual; abstract;

    function VerifyIfHasUnfinishedTasks: Boolean; virtual;
    procedure SetStatus(const pNewStatus: TAqExecutionQueueStatus); virtual;

    function VerifyIfNeedsToInterrupt: Boolean; virtual;
    procedure ProcessList; virtual;

    function DoAdd(const pTask: TAqTask): TAqID; virtual;
    procedure DoExecute; virtual; abstract;
    procedure DoClear; virtual;

    procedure ExecuteLockedForReading(const pMethod: TProc);
    procedure ExecuteLockedForWriting(const pMethod: TProc);

    property Status: TAqExecutionQueueStatus read FStatus;
  public
    constructor Create;

    function Add(const pTask: TProc): TAqID; overload;
    function Add(const pTask: TProc<TAqID>): TAqID; overload;
    function Add(const pTask: TAqTask): TAqID; overload;

    procedure Clear;
    procedure Finish;

    procedure Execute; virtual;
  end;

  TAqExecutionQueue = class(TAqCustomExecutionQueue)
  strict protected
    procedure DoExecute; override;
  end;

  TAqAsynchronousExecutionQueue = class(TAqCustomExecutionQueue)
  strict private
    FThread: TThread;
    FAutoStart: Boolean;

    procedure ReleaseThread;
  strict protected
    function IsLockerNeeded: Boolean; override;
    function VerifyIfNeedsToInterrupt: Boolean; override;
    function DoAdd(const pTask: TAqTask): TAqID; override;
    procedure DoExecute; override;
    procedure DoClear; override;
  public
    constructor Create(const pAutoStart: Boolean);
    destructor Destroy; override;
  end;

implementation

uses
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers.Exception,
  AqDrop.Core.Collections;

type
  TAqSimpleTask = class(TAqTask)
  strict private
    FTask: TProc<TAqID>;
  strict protected
    procedure DoExecute; override;
  public
    constructor Create(const pTask: TProc<TAqID>);

    procedure SetID(const pID: TAqID);
  end;

{ TAqCustomExecutionQueue }

function TAqCustomExecutionQueue.Add(const pTask: TAqTask): TAqID;
begin
  Result := DoAdd(pTask);
end;

procedure TAqCustomExecutionQueue.Clear;
begin
  DoClear;
end;

constructor TAqCustomExecutionQueue.Create;
var
  lLockerType: TAqLockerType;
begin
  if IsLockerNeeded then
  begin
    lLockerType := TAqLockerType.lktMultiReadeExclusiveWriter;
  end else
  begin
    lLockerType := TAqLockerType.lktNone;
  end;

  FTasks := TAqIDDictionary<TAqTask>.Create(True, lLockerType);
  FTasksOrder := TAqList<TAqID>.Create;
end;

function TAqCustomExecutionQueue.DoAdd(const pTask: TAqTask): TAqID;
var
  lResult: TAqID;
begin
  ExecuteLockedForWriting(
    procedure
    begin
      if FStatus <> TAqExecutionQueueStatus.eqsFinished then
      begin
        lResult := FTasks.Add(
          function(pNewID: TAqID): TAqTask
          begin
            pTask.SetID(pNewID);
            FTasksOrder.Add(pNewID);
            Result := pTask;
          end);
      end else begin
        pTask.Free;
        lResult := 0;
      end;
    end);

  Result := lResult;
end;

procedure TAqCustomExecutionQueue.DoClear;
begin
  ExecuteLockedForWriting(
    procedure
    begin
      FTasks.Clear;
      FTasksOrder.Clear;
      FNextTaskIndex := 0;
    end);

  SetStatus(TAqExecutionQueueStatus.eqsWaiting);
end;

procedure TAqCustomExecutionQueue.Execute;
begin
  ExecuteLockedForWriting(
    procedure
    begin
      if FStatus <> TAqExecutionQueueStatus.eqsWaiting then
      begin
        raise EAqInternal.Create('This execution queue is already executig or finished.');
      end;
      SetStatus(TAqExecutionQueueStatus.eqsExecuting);
    end);

  DoExecute;
end;

procedure TAqCustomExecutionQueue.ExecuteLockedForReading(const pMethod: TProc);
begin
  if FTasks.HasLocker then
  begin
    FTasks.BeginRead;
  end;

  try
    pMethod;
  finally
    if FTasks.HasLocker then
    begin
      FTasks.EndRead;
    end;
  end;
end;

procedure TAqCustomExecutionQueue.ExecuteLockedForWriting(const pMethod: TProc);
begin
  if FTasks.HasLocker then
  begin
    FTasks.BeginWrite;
  end;

  try
    pMethod;
  finally
    if FTasks.HasLocker then
    begin
      FTasks.EndWrite;
    end;
  end;
end;

procedure TAqCustomExecutionQueue.Finish;
begin
  SetStatus(TAqExecutionQueueStatus.eqsFinishing);

  Clear;

  SetStatus(TAqExecutionQueueStatus.eqsFinished);
end;

procedure TAqCustomExecutionQueue.ProcessList;
var
  lTask: TAqTask;
  lPreviousTaskStatus: TAqTaskStatus;
  lErrorMessage: string;

  function ChangeToNextTask: Boolean;
  var
    lResult: Boolean;
  begin
    ExecuteLockedForWriting(
      procedure
      begin
        if Assigned(lTask) then
        begin
          if lTask.ReleaseWhenFinished then
          begin
            FTasksOrder.DeleteItem(lTask.ID);
            FTasks.Remove(lTask.ID);
            Dec(FNextTaskIndex);
          end else begin
            if lPreviousTaskStatus = TAqTaskStatus.tksError then
            begin
              lTask.SetError(lErrorMessage);
            end else begin
              lTask.SetStatus(lPreviousTaskStatus);
            end;
          end;
        end;

        lResult := (Status = TAqExecutionQueueStatus.eqsExecuting) and (FNextTaskIndex < FTasksOrder.Count);

        if lResult then
        begin
          lTask := FTasks.Items[FTasksOrder[FNextTaskIndex]];
          Inc(FNextTaskIndex);

          lTask.SetStatus(TAqTaskStatus.tksExecuting);
        end;
      end);

    Result := lResult;
  end;


begin
  ExecuteLockedForReading(
    procedure
    begin
      if FStatus <> TAqExecutionQueueStatus.eqsExecuting then
      begin
        raise EAqInternal.Create('Wrong status while trying to process the queue list.');
      end;
    end);

  lTask := nil;

  while not VerifyIfNeedsToInterrupt and ChangeToNextTask do
  begin
    try
      lTask.Execute;

      lPreviousTaskStatus := TAqTaskStatus.tksDone;
    except
      on E: Exception do
      begin
        lPreviousTaskStatus := TAqTaskStatus.tksError;
        lErrorMessage := E.ConcatFullMessage;
        ExecuteLockedForWriting(
          procedure
          begin
            lTask.SetError(lErrorMessage);
          end);
      end;
    end;
  end;
end;

procedure TAqCustomExecutionQueue.SetStatus(const pNewStatus: TAqExecutionQueueStatus);
begin
  ExecuteLockedForWriting(
    procedure
    begin
      FStatus := pNewStatus;
    end);
end;

function TAqCustomExecutionQueue.VerifyIfHasUnfinishedTasks: Boolean;
var
  lResult: Boolean;
begin
  ExecuteLockedForReading(
    procedure
    begin
      lResult := FNextTaskIndex < FTasksOrder.Count;
    end);

  Result := lResult;
end;

function TAqCustomExecutionQueue.VerifyIfNeedsToInterrupt: Boolean;
begin
  Result := False;
end;

function TAqCustomExecutionQueue.Add(const pTask: TProc): TAqID;
begin
  Result := Add(
    procedure(pID: TAqID)
    begin
      pTask();
    end);
end;

function TAqCustomExecutionQueue.Add(const pTask: TProc<TAqID>): TAqID;
var
  lTask: TAqSimpleTask;
begin
  lTask := TAqSimpleTask.Create(pTask);

  try
    Result := Add(lTask);
  except
    lTask.Free;
    raise;
  end;
end;

{ TAqTask }

procedure TAqTask.Execute;
begin
  DoExecute;
end;

procedure TAqTask.SetError(const pErrorMessage: string);
begin
  SetStatus(TAqTaskStatus.tksError);
  FErrorMessage := pErrorMessage;
end;

procedure TAqTask.SetID(pID: TAqID);
begin
  FID := pID;
end;

procedure TAqTask.SetStatus(const pStatus: TAqTaskStatus);
begin
  FStatus := pStatus;
end;

function TAqTask.VerifyIfShouldReleaseWhenFinished: Boolean;
begin
  Result := False;
end;

{ TAqAsynchronousExecutionQueue }

constructor TAqAsynchronousExecutionQueue.Create(const pAutoStart: Boolean);
begin
  inherited Create;

  FAutoStart := pAutoStart;
end;

destructor TAqAsynchronousExecutionQueue.Destroy;
begin
  ReleaseThread;

  inherited;
end;

function TAqAsynchronousExecutionQueue.DoAdd(const pTask: TAqTask): TAqID;
var
  lResult: TAqID;
begin
  ExecuteLockedForWriting(
    procedure
    begin
      lResult := inherited;

      if FAutoStart and (Status = TAqExecutionQueueStatus.eqsWaiting) then
      begin
        Execute;
      end;
    end);

  Result := lResult;
end;

procedure TAqAsynchronousExecutionQueue.DoClear;
var
  lNeedsToRestart: Boolean;
begin
  ExecuteLockedForReading(
    procedure
    begin
      lNeedsToRestart := Status in [TAqExecutionQueueStatus.eqsExecuting, TAqExecutionQueueStatus.eqsDone];
    end);

  ReleaseThread;

  inherited;

  if lNeedsToRestart then
  begin
    Execute;
  end;
end;

procedure TAqAsynchronousExecutionQueue.DoExecute;
begin
  if Assigned(FThread) then
  begin
    raise EAqInternal.Create('Error while trying to execute an asynchronous task queue: duplicate background thread.');
  end;

  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      lFinishing: Boolean;
      lProcessList: Boolean;
    begin
      lFinishing := False;
      while not lFinishing and not TThread.CheckTerminated do
      begin
        ExecuteLockedForWriting(
          procedure
          begin
            lFinishing := Status in [TAqExecutionQueueStatus.eqsFinishing, TAqExecutionQueueStatus.eqsFinished];

            if not lFinishing then
            begin
              lProcessList := VerifyIfHasUnfinishedTasks;

              if lProcessList then
              begin
                SetStatus(TAqExecutionQueueStatus.eqsExecuting);
              end else begin
                SetStatus(TAqExecutionQueueStatus.eqsDone);
              end;
            end;
          end);

        if lProcessList then
        begin
          ProcessList;
        end else begin
          Sleep(50);
        end;
      end;

      SetStatus(TAqExecutionQueueStatus.eqsFinished);
    end);

  FThread.FreeOnTerminate := False;
  FThread.Start;
end;

function TAqAsynchronousExecutionQueue.IsLockerNeeded: Boolean;
begin
  Result := True;
end;

procedure TAqAsynchronousExecutionQueue.ReleaseThread;
begin
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
end;

function TAqAsynchronousExecutionQueue.VerifyIfNeedsToInterrupt: Boolean;
begin
  Result := Assigned(FThread) and (FThread.ThreadID = TThread.CurrentThread.ThreadID) and TThread.CheckTerminated;
end;

{ TAqExecutionQueue }

procedure TAqExecutionQueue.DoExecute;
begin
  ProcessList;

  SetStatus(TAqExecutionQueueStatus.eqsFinished);
end;

{ TAqSimpleTask }

constructor TAqSimpleTask.Create(const pTask: TProc<TAqID>);
begin
  FTask := pTask;
end;

procedure TAqSimpleTask.DoExecute;
begin

end;

procedure TAqSimpleTask.SetID(const pID: TAqID);
begin

end;

end.
