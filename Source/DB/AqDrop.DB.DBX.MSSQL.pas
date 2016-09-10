unit AqDrop.DB.DBX.MSSQL;

interface

uses
  Data.DBXMSSQL,
  AqDrop.DB.SQL.Intf,
  AqDrop.DB.Connection,
  AqDrop.DB.DBX;

type
  TAqDBXMSSQLMapper = class(TAqDBXMapper)
  strict protected
    function SolveLimit(pSelect: IAqDBSQLSelect): string; override;
  public
    function SolveSelect(pSelect: IAqDBSQLSelect): string; override;
  end;

  TAqDBXMSSQLConnection = class(TAqDBXCustomConnection)
  strict protected
    function GetPropertyValueAsString(const pIndex: Integer): string; override;
    procedure SetPropertyValueAsString(const pIndex: Integer; const pValue: string); override;
    class function GetDefaultMapper: TAqDBMapperClass; override;
  public
    constructor Create; override;

    function GetAutoIncrement(const pGenerator: string = ''): Int64; override;

    property HostName: string index $80 read GetPropertyValueAsString write SetPropertyValueAsString;
    property DataBase: string index $81 read GetPropertyValueAsString write SetPropertyValueAsString;
    property Username: string index $82 read GetPropertyValueAsString write SetPropertyValueAsString;
    property Password: string index $83 read GetPropertyValueAsString write SetPropertyValueAsString;
  end;

implementation

uses
  System.SysUtils,
  Data.DBXCommon,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.DB.Types;

{ TAqDBXMSSQLMapper }

function TAqDBXMSSQLMapper.SolveLimit(pSelect: IAqDBSQLSelect): string;
begin
  if pSelect.IsLimitDefined then
  begin
    Result := 'top ' + pSelect.Limit.ToString + ' ';
  end else begin
    Result := '';
  end;
end;

function TAqDBXMSSQLMapper.SolveSelect(pSelect: IAqDBSQLSelect): string;
begin
  Result := 'select ' + SolveLimit(pSelect) + SolveSelectBody(pSelect);
end;

{ TAqDBXMSSQLConnection }

constructor TAqDBXMSSQLConnection.Create;
begin
  inherited;

  Self.DriverName := 'MSSQL';
  Self.VendorLib := 'sqlncli10.dll';
  Self.LibraryName := 'dbxmss.dll';
  Self.GetDriverFunc := 'getSQLDriverMSSQL';
end;

function TAqDBXMSSQLConnection.GetAutoIncrement(const pGenerator: string): Int64;
var
  lReader: IAqDBReader;
begin
  lReader := OpenQuery('select @@identity');

  if not lReader.Next then
  begin
    raise EAqInternal.Create('It wasn''t possible to get the last insert id.');
  end;

  Result := lReader.Values[0].AsInt64;
end;

class function TAqDBXMSSQLConnection.GetDefaultMapper: TAqDBMapperClass;
begin
  Result := TAqDBXMSSQLMapper;
end;

function TAqDBXMSSQLConnection.GetPropertyValueAsString(const pIndex: Integer): string;
begin
  case pIndex of
    $80:
      Result := Properties[TDBXPropertyNames.HostName];
    $81:
      Result := Properties[TDBXPropertyNames.Database];
    $82:
      Result := Properties[TDBXPropertyNames.UserName];
    $83:
      Result := Properties[TDBXPropertyNames.Password];
  else
    Result := inherited;
  end;
end;

procedure TAqDBXMSSQLConnection.SetPropertyValueAsString(const pIndex: Integer; const pValue: string);
begin
  case pIndex of
    $80:
      Properties[TDBXPropertyNames.HostName] := pValue;
    $81:
      Properties[TDBXPropertyNames.Database] := pValue;
    $82:
      Properties[TDBXPropertyNames.UserName] := pValue;
    $83:
      Properties[TDBXPropertyNames.Password] := pValue;
  else
    inherited;
  end;
end;

end.
