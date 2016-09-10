unit AqDrop.Core.InterfacedObject;

interface

type
  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Base class for objects that must implememnt IInterface.
  ///   PT-BR:
  ///     Classe base para objetos que devem implementar IInterface.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqInterfacedObject = class(TObject, IInterface)
  strict private
    FReferences: Int32;
  strict protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Int32; stdcall;
    function _Release: Int32; stdcall;

    class function MustCountReferences: Boolean; virtual;

    property References: Int32 read FReferences;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    class function NewInstance: TObject; override;
  end;


implementation

uses
  System.SyncObjs;

{ TAqCustomInterfacedObject }

procedure TAqInterfacedObject.AfterConstruction;
begin
  inherited;

  if MustCountReferences then
  begin
    TInterlocked.Decrement(FReferences);
  end;
end;

procedure TAqInterfacedObject.BeforeDestruction;
begin
  if MustCountReferences and (FReferences <> 0) then
  begin
    System.Error(reInvalidPtr);
  end;

  inherited;
end;

class function TAqInterfacedObject.MustCountReferences: Boolean;
begin
  Result := False;
end;

class function TAqInterfacedObject.NewInstance: TObject;
var
  lInterfacedObject: TAqInterfacedObject;
begin
  lInterfacedObject := TAqInterfacedObject(inherited NewInstance);

  if lInterfacedObject.MustCountReferences then
  begin
    lInterfacedObject.FReferences := 1;
  end;

  Result := lInterfacedObject;
end;

function TAqInterfacedObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
  begin
    Result := 0;
  end else begin
    Result := E_NOINTERFACE;
  end;
end;

function TAqInterfacedObject._AddRef: Int32;
begin
  if MustCountReferences then
  begin
    Result := TInterlocked.Increment(FReferences);
  end else begin
    Result := 0;
  end;
end;

function TAqInterfacedObject._Release: Int32;
begin
  if MustCountReferences then
  begin
    Result := TInterlocked.Decrement(FReferences);

    if Result = 0 then
    begin
      Destroy;
    end;
  end else begin
    Result := 0;
  end;
end;

end.

