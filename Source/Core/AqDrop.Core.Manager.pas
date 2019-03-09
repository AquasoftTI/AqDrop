unit AqDrop.Core.Manager;

interface

uses
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Manager.Intf;

type
  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Base class for Aquasoft object managers.
  ///   PT-BR:
  ///     Classe base para gerenciadores de objetos da Aquasoft.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqCustomManager<T: class> = class(TAqInterfacedObject, IAqManager<T>)
  strict private
    FDependents: IAqList<T>;
  strict protected
    procedure AddDependent(const pDependent: T); virtual;
    procedure RemoveDependent(const pDependent: T); virtual;

    procedure IAqManager<T>._AddDependent = AddDependent;
    procedure IAqManager<T>._RemoveDependent = RemoveDependent;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Specialization of the base class of managers who make publicly available the method of adding dependent.
  ///   PT-BR:
  ///     Especialização da classe base de gerenciadores que disponibiliza publicamente o método de adição de
  ///     dependente.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqManager<T: class> = class(TAqCustomManager<T>)
  public
    procedure AddDependent(const pDepedent: T); override;
    procedure RemoveDependent(const pDepedent: T); override;
  end;

implementation

uses
  AqDrop.Core.Collections;

{ TAqCustomManager<T> }

procedure TAqCustomManager<T>.AddDependent(const pDependent: T);
begin
  FDependents.Add(pDependent);
end;

constructor TAqCustomManager<T>.Create;
begin
  FDependents := TAqList<T>.Create(True);
end;

destructor TAqCustomManager<T>.Destroy;
var
  lDependent: T;
begin
{$IFNDEF AUTOREFCOUNT}
  while FDependents.Count > 0 do
  begin
    FDependents.Delete(FDependents.Count - 1);
  end;
{$ENDIF}

  inherited;
end;

procedure TAqCustomManager<T>.RemoveDependent(const pDependent: T);
var
  lIndex: Int32;
begin
  lIndex := FDependents.IndexOf(pDependent);

  if lIndex >= 0 then
  begin
    FDependents.Extract(lIndex);
  end;
end;

{ TAqManager<T> }

procedure TAqManager<T>.AddDependent(const pDepedent: T);
begin
  inherited;
end;

procedure TAqManager<T>.RemoveDependent(const pDepedent: T);
begin
  inherited;
end;

end.
