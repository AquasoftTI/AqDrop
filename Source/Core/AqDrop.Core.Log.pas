unit AqDrop.Core.Log;

interface

uses
  System.SysUtils,
  System.Classes,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Observers.Intf,
  AqDrop.Core.Observers;

type
  IAqLog<T> = interface(IAqObservable<T>)
    ['{E0E5390F-2145-4CD6-AE23-9C067BE6E253}']

    function GetDefaultFormatMessage: string;
    procedure SetDefaultFormatMessage(const pValue: string);

    property DefaultFormatMessage: string read GetDefaultFormatMessage write SetDefaultFormatMessage;
  end;

  TAqLogMessage = class
    FDateTime: TDateTime;
    FSender: IAqLog<TAqLogMessage>;
    FMessage: string;
  public
    constructor Create(pSender: IAqLog<TAqLogMessage>; const pMessage: string);

    function GetDefaultFormatMessage: string;

    property DateTime: TDateTime read FDateTime;
    property Sender: IAqLog<TAqLogMessage> read FSender;
    property Message: string read FMessage;
  public const
    THREAD_ID_PLACE_HOLDER = '%thid';
  end;

  TAqLog = class(TAqObservable<TAqLogMessage>, IAqObservable<TAqLogMessage>,
    IAqLog<TAqLogMessage>)
  strict private
    FDefaultFormatMesssage: string;
    FExecutionLevels: IAqDictionary<TThreadID, UInt32>;

    function IncrementExecutionLevel: UInt32;
    procedure DecrementExecutionLevel;

    function GetDefaultFormatMessage: string;
    procedure SetDefaultFormatMessage(const pValue: string);

    function GetExceptionMessage(const pException: Exception): string;

    class var FDefaultInstance: TAqLog;
    class function GetDefaultInstance: TAqLog; static;
  public
    constructor Create;

    class procedure InitializeDefaultInstance;
    class procedure ReleaseDefaultInstance;

    procedure Log(const pMessage: string); overload;
    procedure Log(const pFormat: string; const pParameters: array of const); overload;
    procedure Log(const pException: Exception); overload; inline;

    procedure LogExecution(const pDescription: string; const pMethod: TProc);

    class property DefaultInstance: TAqLog read GetDefaultInstance;
  end;


implementation

uses
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.Core.Helpers.Exception,
  AqDrop.Core.Collections;

resourcestring
  StrExceptionLogFormat = 'Error: %s (%s)';

{ TAqLogMessage }

constructor TAqLogMessage.Create(pSender: IAqLog<TAqLogMessage>; const pMessage: string);
begin
  FDateTime := Now;
  FSender := pSender;
  FMessage := pMessage;
end;

function TAqLogMessage.GetDefaultFormatMessage: string;
var
  lFormat: string;
begin
  lFormat := FormatDateTime(FSender.DefaultFormatMessage, FDateTime);

  if lFormat.Contains(THREAD_ID_PLACE_HOLDER, False) then
  begin
    lFormat := lFormat.Replace(THREAD_ID_PLACE_HOLDER, FormatFloat('000000', TThread.CurrentThread.ThreadID),
      [rfIgnoreCase]);
  end;

  Result := Format(lFormat, [FMessage]);
end;

{ TAqLog }

constructor TAqLog.Create;
begin
  inherited Create(True);

  FDefaultFormatMesssage := 'hh:mm:ss:zzz ''' + TAqLogMessage.THREAD_ID_PLACE_HOLDER + ''' ''%s''';
  FExecutionLevels := TAqDictionary<TThreadID, UInt32>.Create(TAqLockerType.lktMultiReaderExclusiveWriter);
end;

procedure TAqLog.DecrementExecutionLevel;
var
  lExecutionLevel: UInt32;
  lThreadID: TThreadID;
begin
  lThreadID := TThread.CurrentThread.ThreadID;

  FExecutionLevels.ExecuteLockedForWriting(
    procedure
    begin
      if not FExecutionLevels.TryGetValue(lThreadID, lExecutionLevel) or (lExecutionLevel = 0) then
      begin
        raise EAqInternal.Create('No execution level to decrement in log management.');
      end;

      Dec(lExecutionLevel);

      FExecutionLevels.Items[lThreadID] := lExecutionLevel;
    end);
end;

function TAqLog.GetDefaultFormatMessage: string;
begin
  Result := FDefaultFormatMesssage;
end;

class function TAqLog.GetDefaultInstance: TAqLog;
begin
  InitializeDefaultInstance;

  Result := FDefaultInstance;
end;

function TAqLog.GetExceptionMessage(const pException: Exception): string;
begin
  Result := Format(StrExceptionLogFormat, [
    pException.Message,
    pException.QualifiedClassName]);

  if Assigned(pException.InnerException) then
  begin
    Result := Result + string.LineBreak +
      '  caused by ' + pException.InnerException.ConcatFullMessage(string.LineBreak + '            ');
  end;
end;

function TAqLog.IncrementExecutionLevel: UInt32;
var
  lExecutionLevel: UInt32;
  lThreadID: TThreadID;
begin
  lThreadID := TThread.CurrentThread.ThreadID;

  FExecutionLevels.ExecuteLockedForWriting(
    procedure
    begin
      if FExecutionLevels.TryGetValue(lThreadID, lExecutionLevel) then
      begin
        Inc(lExecutionLevel);
      end else begin
        lExecutionLevel := 1;
      end;

      FExecutionLevels.AddOrSetValue(lThreadID, lExecutionLevel);
    end);

  Result := lExecutionLevel;
end;

class procedure TAqLog.InitializeDefaultInstance;
begin
  if not Assigned(FDefaultInstance) then
  begin
    FDefaultInstance := Self.Create;
  end;
end;

procedure TAqLog.Log(const pException: Exception);
begin
  Log(GetExceptionMessage(pException));
end;

procedure TAqLog.LogExecution(const pDescription: string; const pMethod: TProc);
var
  lExecutionLevel: UInt32;

  procedure LogWithExecutionLevelMarker(pMessage: string);
  begin
    if lExecutionLevel > 0 then
    begin
      pMessage := string.Create('>', lExecutionLevel) + ' ' + pMessage;
    end;

    Log(pMessage);
  end;
begin
  lExecutionLevel := IncrementExecutionLevel - 1;

  try
    LogWithExecutionLevelMarker('Starting ' + pDescription);

    try
      pMethod;
    except
      on E: Exception do
      begin
        LogWithExecutionLevelMarker('Error while running ' + pDescription + ' > ' + GetExceptionMessage(E));
        raise;
      end;
    end;

    LogWithExecutionLevelMarker('Ending ' + pDescription);
  finally
    DecrementExecutionLevel;
  end;
end;

procedure TAqLog.Log(const pFormat: string; const pParameters: array of const);
begin
  Log(Format(pFormat, pParameters));
end;

procedure TAqLog.Log(const pMessage: string);
var
  lMessage: TAqLogMessage;
begin
  lMessage := TAqLogMessage.Create(Self, pMessage);

  try
    Notify(lMessage);
  finally
    lMessage.Free;
  end;
end;

class procedure TAqLog.ReleaseDefaultInstance;
begin
  FreeAndNil(FDefaultInstance);
end;

procedure TAqLog.SetDefaultFormatMessage(const pValue: string);
begin
  FDefaultFormatMesssage := pValue;
end;

initialization

finalization
  TAqLog.ReleaseDefaultInstance;

end.
