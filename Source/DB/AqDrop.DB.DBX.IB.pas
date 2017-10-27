unit AqDrop.DB.DBX.IB;

interface

uses
  Data.DBXInterbase,
  AqDrop.DB.Adapter,
  AqDrop.DB.DBX,
  Data.DBXCommon;

type
  TAqDBXIBAdapter = class(TAqDBXAdapter)
  strict protected
    function GetAutoIncrementType: TAqDBAutoIncrementType; override;
    class function GetDefaultSolver: TAqDBSQLSolverClass; override;
  end;

  TAqDBXIBConnection = class(TAqDBXCustomConnection)
  strict protected
    function GetPropertyValueAsString(const pIndex: Int32): string; override;
    procedure SetPropertyValueAsString(const pIndex: Int32; const pValue: string); override;

    class function GetDefaultAdapter: TAqDBAdapterClass; override;
  public
    constructor Create; override;

    property DataBase: string index $80 read GetPropertyValueAsString write SetPropertyValueAsString;
    property UserName: string index $81 read GetPropertyValueAsString write SetPropertyValueAsString;
    property Password: string index $82 read GetPropertyValueAsString write SetPropertyValueAsString;
  end;

implementation

uses
  System.Math,
  AqDrop.DB.IB;


{ TAqDBXIBAdapter }

function TAqDBXIBAdapter.GetAutoIncrementType: TAqDBAutoIncrementType;
begin
  Result := TAqDBAutoIncrementType.aiGenerator;
end;

class function TAqDBXIBAdapter.GetDefaultSolver: TAqDBSQLSolverClass;
begin
  Result := TAqDBIBSQLSolver;
end;

{ TAqDBXIBConnection }

constructor TAqDBXIBConnection.Create;
begin
  inherited;

  Self.DriverName := 'InterBase';
  Self.VendorLib := 'GDS32.DLL';
  Self.LibraryName := 'dbxint.dll';
  Self.GetDriverFunc := 'getSQLDriverINTERBASE';
end;

class function TAqDBXIBConnection.GetDefaultAdapter: TAqDBAdapterClass;
begin
  Result := TAqDBXIBAdapter;
end;

function TAqDBXIBConnection.GetPropertyValueAsString(const pIndex: Int32): string;
begin
  case pIndex of
    $80:
      Result := Properties[TDBXPropertyNames.Database];
    $81:
      Result := Properties[TDBXPropertyNames.UserName];
    $82:
      Result := Properties[TDBXPropertyNames.Password];
  else
    Result := inherited;
  end;
end;

procedure TAqDBXIBConnection.SetPropertyValueAsString(const pIndex: Int32; const pValue: string);
begin
  case pIndex of
    $80:
      Properties[TDBXPropertyNames.Database] := pValue;
    $81:
      Properties[TDBXPropertyNames.UserName] := pValue;
    $82:
      Properties[TDBXPropertyNames.Password] := pValue;
  else
    inherited;
  end;
end;

end.
