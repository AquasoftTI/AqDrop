unit AqDrop.DB.FD.IB;

interface

uses
{$IF CompilerVersion >= 26}
  FireDAC.Phys.IB,
{$ELSE}
  uADPhysIB,
{$ENDIF}
  AqDrop.DB.FD,
  AqDrop.DB.Adapter;

type
  TAqFDIBAdapter = class(TAqFDAdapter)
  strict protected
    function GetAutoIncrementType: TAqDBAutoIncrementType; override;
    class function GetDefaultSolver: TAqDBSQLSolverClass; override;
    class function GetDefaultDataConverter: TAqFDDataConverterClass; override;
  end;

  TAqFDIBConnection = class(TAqFDCustomConnection)
  strict protected
    function GetParameterValueByIndex(const pIndex: Int32): string; override;
    procedure SetParameterValueByIndex(const pIndex: Int32; const pValue: string); override;

    class function GetDefaultAdapter: TAqDBAdapterClass; override;
  public
    constructor Create; override;

    property DataBase: string index $80 read GetParameterValueByIndex write SetParameterValueByIndex;
    property UserName: string index $81 read GetParameterValueByIndex write SetParameterValueByIndex;
    property Password: string index $82 read GetParameterValueByIndex write SetParameterValueByIndex;
  end;


implementation

uses
  AqDrop.DB.IB;

{ TAqFDIBAdapter }

function TAqFDIBAdapter.GetAutoIncrementType: TAqDBAutoIncrementType;
begin
  Result := TAqDBAutoIncrementType.aiGenerator;
end;

class function TAqFDIBAdapter.GetDefaultDataConverter: TAqFDDataConverterClass;
begin
  Result := TAqFDDataConverter;
end;

class function TAqFDIBAdapter.GetDefaultSolver: TAqDBSQLSolverClass;
begin
  Result := TAqDBIBSQLSolver;
end;

{ TAqFDIBConnection }

constructor TAqFDIBConnection.Create;
begin
  inherited;

  DriverName := 'IB';
end;

class function TAqFDIBConnection.GetDefaultAdapter: TAqDBAdapterClass;
begin
  Result := TAqFDIBAdapter;
end;

function TAqFDIBConnection.GetParameterValueByIndex(const pIndex: Int32): string;
begin
  case pIndex of
    $80:
      Result := Params.Values['Database'];
    $81:
      Result := Params.Values['User_Name'];
    $82:
      Result := Params.Values['Password'];
  else
    Result := inherited;
  end;
end;

procedure TAqFDIBConnection.SetParameterValueByIndex(const pIndex: Int32; const pValue: string);
begin
  case pIndex of
    $80:
      Params.Values['Database'] := pValue;
    $81:
      Params.Values['User_Name'] := pValue;
    $82:
      Params.Values['Password'] := pValue;
  else
    inherited;
  end;
end;

end.
