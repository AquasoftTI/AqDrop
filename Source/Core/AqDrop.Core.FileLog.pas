unit AqDrop.Core.FileLog;

interface

uses
  AqDrop.Core.Types,
  AqDrop.Core.Log;

type
  TAqFileLog = class
  strict private
    FLogsPath: string;
    FFileNameMask: string;
    FLog: TAqLog;
    FObserverID: TAqID;
  public
    constructor Create(const pLogsPath: string; const pLog: TAqLog; const pFileNameMask: string = 'YYYYMMDD');
    destructor Destroy; override;

    procedure SaveLog(const pMessage: TAqLogMessage);
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils;

{ TAqFileLog }

constructor TAqFileLog.Create(const pLogsPath: string; const pLog: TAqLog; const pFileNameMask: string);
begin
  FLogsPath := pLogsPath;
  FFileNameMask := pFileNameMask;
  TDirectory.CreateDirectory(FLogsPath);

  FLog := pLog;
  FObserverID := pLog.RegisterObserver(
    procedure(pMessage: TAqLogMessage)
    begin
      SaveLog(pMessage);
    end);
end;

destructor TAqFileLog.Destroy;
begin
  FLog.UnregisterObserver(FObserverID);

  inherited;
end;

procedure TAqFileLog.SaveLog(const pMessage: TAqLogMessage);
var
  lFilePath: string;
  lMessage: string;
begin
  lFilePath := TPath.Combine(FLogsPath, FormatDateTime(FFileNameMask, pMessage.DateTime) + '.log');
  lMessage := pMessage.GetDefaultFormatMessage;

  TThread.Queue(nil,
    procedure
    begin
      TFile.AppendAllText(lFilePath, lMessage + sLineBreak, TEncoding.Unicode);
    end);
end;

end.
