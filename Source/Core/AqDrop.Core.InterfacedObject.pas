unit AqDrop.Core.InterfacedObject;

interface

type
  IAqInterfacedObject = interface
    ['{CC89B6C7-D7AB-4ECD-B12B-A8A597F06153}']

    function VerifyIfARCIsEnabled: Boolean;

    property ARCEnabled: Boolean read VerifyIfARCIsEnabled;
  end;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Base class for objects that must implememnt IInterface.
  ///   PT-BR:
  ///     Classe base para objetos que devem implementar IInterface.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqInterfacedObject = class(TInterfacedObject, IInterface, IAqInterfacedObject)
  strict protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Int32; stdcall;
    function _Release: Int32; stdcall;

    function _VerifyIfARCIsEnabled: Boolean; virtual;

    function IAqInterfacedObject.VerifyIfARCIsEnabled = _VerifyIfARCIsEnabled;

    function _EnableARCForObject: Boolean; virtual;
    class function _EnableARCForClass: Boolean; virtual;
  end;

  TAqARCObject = class(TAqInterfacedObject)
  strict protected
    class function _EnableARCForClass: Boolean; override;
  end;

  IAqDelegatedInterface = interface
    ['{7D10ED7E-4ECA-4653-91EE-A0BD170FEB16}']

    procedure EnableARC;
    procedure DisableARC;
  end;

  TAqDelegatedInterface = class(TAqARCObject, IInterface, IAqDelegatedInterface)
  strict private
    FOwner: TObject;
    FARCEnabled: Boolean;

    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
  strict protected
    function _VerifyIfARCIsEnabled: Boolean; override;
  public
    constructor Create(pOwner: TObject; const pARCEnabled: Boolean = True); overload;

    procedure EnableARC;
    procedure DisableARC;
  end;

implementation

{ TAqInterfacedObject }

class function TAqInterfacedObject._EnableARCForClass: Boolean;
begin
  Result := False;
end;

function TAqInterfacedObject._EnableARCForObject: Boolean;
begin
  Result := _EnableARCForClass;
end;

function TAqInterfacedObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := inherited;
end;

function TAqInterfacedObject._AddRef: Int32;
var
  lCallInheritedFunction: Boolean;
begin
{$IFDEF AUTOREFCOUNT}
  lCallInheritedFunction := True;
{$ELSE}
  lCallInheritedFunction := _EnableARCForObject;
{$ENDIF}
  if lCallInheritedFunction then
  begin
    Result := inherited;
  end else begin
    Result := 0;
  end;
end;

function TAqInterfacedObject._Release: Int32;
var
  lCallInheritedFunction: Boolean;
begin
{$IFDEF AUTOREFCOUNT}
  lCallInheritedFunction := True;
{$ELSE}
  lCallInheritedFunction := _EnableARCForObject;
{$ENDIF}
  if lCallInheritedFunction then
  begin
    Result := inherited;
  end else begin
    Result := 0;
  end;
end;

function TAqInterfacedObject._VerifyIfARCIsEnabled: Boolean;
begin
  Result := _EnableARCForObject;
end;

{ TAqARCObject }

class function TAqARCObject._EnableARCForClass: Boolean;
begin
  Result := True;
end;

{ TAqDelegatedInterface }

constructor TAqDelegatedInterface.Create(pOwner: TObject; const pARCEnabled: Boolean);
begin
  FOwner := pOwner;
  FARCEnabled := pARCEnabled;
end;

procedure TAqDelegatedInterface.DisableARC;
begin
  FARCEnabled := False;
end;

procedure TAqDelegatedInterface.EnableARC;
begin
  FARCEnabled := True;
end;

function TAqDelegatedInterface.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  if FOwner.GetInterface(IID, Obj) then
  begin
    Result := 0;
  end else begin
    Result := E_NOINTERFACE;
  end;
end;

function TAqDelegatedInterface._Release: Integer;
begin
  Result := inherited;

  if FARCEnabled and (Result = 1) then
  begin
{$IFDEF AUTOREFCOUNT}
    FOwner.DisposeOf;
{$ELSE}
    FOwner.Free;
{$ENDIF}
  end;
end;

function TAqDelegatedInterface._VerifyIfARCIsEnabled: Boolean;
begin
  Result := FARCEnabled;
end;

end.

