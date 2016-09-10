unit AqDrop.DB.DBX.MySQL;

interface

uses
  Data.DBXCommon,
  Data.DBXMySQL,
  AqDrop.DB.Connection,
  AqDrop.DB.DBX,
  AqDrop.DB.SQL.Intf;

type
  TAqDBXMySQLMapper = class(TAqDBXMapper)
  strict protected
    function SolveLimit(pSelect: IAqDBSQLSelect): string; override;
    function SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string; override;
  public
    procedure BooleanToParameter(const pParameter: TDBXParameter; const pValue: Boolean); override;
    procedure UInt8ToParameter(const pParameter: TDBXParameter; const pValue: UInt8); override;
    procedure UInt16ToParameter(const pParameter: TDBXParameter; const pValue: UInt16); override;
    function SolveSelect(pSelect: IAqDBSQLSelect): string; override;
  end;

  TAqDBXMySQLConnection = class(TAqDBXCustomConnection)
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
  AqDrop.Core.Helpers, AqDrop.DB.Types, AqDrop.Core.Exceptions;

{ TAqDBXMySQLMapper }

procedure TAqDBXMySQLMapper.BooleanToParameter(const pParameter: TDBXParameter; const pValue: Boolean);
begin
  pParameter.DataType := TDBXDataTypes.Int8Type;
  pParameter.Value.SetInt8(pValue.ToInt8);
end;

function TAqDBXMySQLMapper.SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string;
begin
  if pConstant.Value then
  begin
    Result := 'True';
  end else begin
    Result := 'False';
  end;
end;

function TAqDBXMySQLMapper.SolveLimit(pSelect: IAqDBSQLSelect): string;
begin
  if pSelect.IsLimitDefined then
  begin
    Result := ' limit ' + pSelect.Limit.ToString;
  end else begin
    Result := '';
  end;
end;

function TAqDBXMySQLMapper.SolveSelect(pSelect: IAqDBSQLSelect): string;
begin
  Result := inherited + SolveLimit(pSelect);
end;

procedure TAqDBXMySQLMapper.UInt16ToParameter(const pParameter: TDBXParameter; const pValue: UInt16);
begin
  UInt32ToParameter(pParameter, pValue);
end;

procedure TAqDBXMySQLMapper.UInt8ToParameter(const pParameter: TDBXParameter; const pValue: UInt8);
begin
  UInt32ToParameter(pParameter, pValue);
end;

{ TAqDBXMySQLConnection }

constructor TAqDBXMySQLConnection.Create;
begin
  inherited;

  Self.DriverName := 'MySQL';
  Self.VendorLib := 'LIBMYSQL.dll';
  Self.LibraryName := 'dbxmys.dll';
  Self.GetDriverFunc := 'getSQLDriverMYSQL';
end;

function TAqDBXMySQLConnection.GetAutoIncrement(const pGenerator: string): Int64;
var
  lReader: IAqDBReader;
begin
  lReader := OpenQuery('select last_insert_id()');

  if not lReader.Next then
  begin
    raise EAqInternal.Create('It wasn''t possible to get the last insert id.');
  end;

  Result := lReader.Values[0].AsInt64;
end;

class function TAqDBXMySQLConnection.GetDefaultMapper: TAqDBMapperClass;
begin
  Result := TAqDBXMySQLMapper;
end;

function TAqDBXMySQLConnection.GetPropertyValueAsString(const pIndex: Integer): string;
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

procedure TAqDBXMySQLConnection.SetPropertyValueAsString(const pIndex: Integer; const pValue: string);
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
