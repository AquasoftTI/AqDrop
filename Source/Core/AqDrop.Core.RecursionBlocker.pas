unit AqDrop.Core.RecursionBlocker;

interface

uses
  System.SysUtils,
  System.Classes,
  AqDrop.Core.Collections.Intf;

type
  TAqRecursionBlockerInstancesManager = class;

  TAqRecursionBlocker<Identifier> = class
  strict private
    FBlockedItems: IAqDictionary<Identifier, UInt16>;
    FManager: TAqRecursionBlockerInstancesManager;

    function DoExecute(const pIdentifier: Identifier; const pMethod: TProc;
      const pExecuteIfBlocked: Boolean): Boolean;

    class var FDefaultInstance: TAqRecursionBlocker<Identifier>;

    class function GetDefaultInstance: TAqRecursionBlocker<Identifier>; static;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Execute(const pIdentifier: Identifier; const pMethod: TProc);
    function TryToExecute(const pIdentifier: Identifier; const pMethod: TProc): Boolean;

    class procedure InitializeDefaultInstance;
    class procedure ReleaseDefaultInstance;

    class property DefaultInstance: TAqRecursionBlocker<Identifier> read GetDefaultInstance;
  end;

  TAqStringRecursionBlocker = class(TAqRecursionBlocker<string>);
  TAqComponentRecursionBlocker = class(TAqRecursionBlocker<TComponent>);

{TODO 3 -oTatu -cMelhoria: fazer herdar de TAqManager - IAqManager}
  TAqRecursionBlockerInstancesManager = class
  strict private
    FObjects: IAqList<TObject>;

    class var FInstance: TAqRecursionBlockerInstancesManager;
    class function Getinstance: TAqRecursionBlockerInstancesManager; static;
  private
    procedure Add(const pObject: TObject);
    procedure Remove(const pObject: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    class procedure InitializeInstance;
    class procedure ReleaseInstance;

    class property Instance: TAqRecursionBlockerInstancesManager read GetInstance;
  end;

implementation

uses
  AqDrop.Core.Collections;

{ TAqRecursionBlocker<Identifier> }

constructor TAqRecursionBlocker<Identifier>.Create;
begin
  FManager := TAqRecursionBlockerInstancesManager.Instance;
  FManager.Add(Self);

  FBlockedItems := TAqDictionary<Identifier, UInt16>.Create;
end;

destructor TAqRecursionBlocker<Identifier>.Destroy;
begin
  FManager.Remove(Self);

  inherited;
end;

function TAqRecursionBlocker<Identifier>.DoExecute(const pIdentifier: Identifier; const pMethod: TProc;
  const pExecuteIfBlocked: Boolean): Boolean;
var
  lCalls: UInt16;
begin
  if not FBlockedItems.TryGetValue(pIdentifier, lCalls) then
  begin
    lCalls := 0;
  end;

  Result := pExecuteIfBlocked or (lCalls = 0);

  if Result then
  begin
    FBlockedItems.AddOrSetValue(pIdentifier, lCalls + 1);

    try
      pMethod;
    finally
      if lCalls = 0 then
      begin
        FBlockedItems.Remove(pIdentifier);
      end else begin
        FBlockedItems.AddOrSetValue(pIdentifier, lCalls);
      end;
    end;
  end;
end;

procedure TAqRecursionBlocker<Identifier>.Execute(const pIdentifier: Identifier; const pMethod: TProc);
begin
  DoExecute(pIdentifier, pMethod, True);
end;

class function TAqRecursionBlocker<Identifier>.GetDefaultInstance: TAqRecursionBlocker<Identifier>;
begin
  InitializeDefaultInstance;

  Result := FDefaultInstance;
end;

class procedure TAqRecursionBlocker<Identifier>.InitializeDefaultInstance;
begin
  if not Assigned(FDefaultInstance) then
  begin
    FDefaultInstance := Self.Create;
  end;
end;

class procedure TAqRecursionBlocker<Identifier>.ReleaseDefaultInstance;
begin
  FDefaultInstance.Free;
end;

function TAqRecursionBlocker<Identifier>.TryToExecute(const pIdentifier: Identifier; const pMethod: TProc): Boolean;
begin
  Result := DoExecute(pIdentifier, pMethod, False);
end;

{ TAqRecursionBlockerInstancesManager }

procedure TAqRecursionBlockerInstancesManager.Add(const pObject: TObject);
begin
  if not FObjects.Contains(pObject) then
  begin
    FObjects.Add(pObject);
  end;
end;

constructor TAqRecursionBlockerInstancesManager.Create;
begin
  FObjects := TAqList<TObject>.Create;
end;

destructor TAqRecursionBlockerInstancesManager.Destroy;
begin
{$IFNDEF AUTOREFCOUNT}
  while FObjects.Count > 0 do
  begin
    FObjects.Extract.Free;
  end;
{$ENDIF}

  inherited;
end;

class function TAqRecursionBlockerInstancesManager.Getinstance: TAqRecursionBlockerInstancesManager;
begin
  InitializeInstance;

  Result := FInstance;
end;

class procedure TAqRecursionBlockerInstancesManager.InitializeInstance;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TAqRecursionBlockerInstancesManager.Create;
  end;
end;

class procedure TAqRecursionBlockerInstancesManager.ReleaseInstance;
begin
  FreeAndNil(FInstance);
end;

procedure TAqRecursionBlockerInstancesManager.Remove(const pObject: TObject);
var
  lIndex: Int32;
begin
  lIndex := FObjects.IndexOf(pObject);

  if lIndex >= 0 then
  begin
    FObjects.Extract(lIndex);
  end;
end;

initialization

finalization
  TAqRecursionBlockerInstancesManager.ReleaseInstance;

end.
