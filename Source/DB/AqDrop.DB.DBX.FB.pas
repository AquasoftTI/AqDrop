unit AqDrop.DB.DBX.FB;

interface

uses
  Data.DBXCommon,
  Data.DBXFirebird,
  AqDrop.DB.Connection,
  AqDrop.DB.DBX,
  AqDrop.DB.SQL.Intf;

type
  TAqDBXFBMapper = class(TAqDBXMapper)
  strict protected
    function SolveLimit(pSelect: IAqDBSQLSelect): string; override;
    function SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string; override;
  public
    function SolveSelect(pSelect: IAqDBSQLSelect): string; override;
    procedure BooleanToParameter(const pParameter: TDBXParameter; const pValue: Boolean); override;
  end;

  TAqDBXFBConnection = class(TAqDBXCustomConnection)
  strict protected
    function GetPropertyValueAsString(const pIndex: Integer): string; override;
    procedure SetPropertyValueAsString(const pIndex: Integer; const pValue: string); override;
    class function GetDefaultMapper: TAqDBMapperClass; override;
    function GetAutoIncrementType: TAqDBAutoIncrementType; override;
  public
    constructor Create; override;

    function GetAutoIncrement(const pGenerator: string = ''): Int64; override;

    property DataBase: string index $80 read GetPropertyValueAsString write SetPropertyValueAsString;
    property Username: string index $81 read GetPropertyValueAsString write SetPropertyValueAsString;
    property Password: string index $82 read GetPropertyValueAsString write SetPropertyValueAsString;
  end;


implementation

uses
  System.SysUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.DB.Types;

{ TAqDBXFBConnection }

constructor TAqDBXFBConnection.Create;
begin
  inherited;

  Self.DriverName := 'Firebird';
  Self.VendorLib := 'fbclient.dll';
  Self.LibraryName := 'dbxfb.dll';
  Self.GetDriverFunc := 'getSQLDriverINTERBASE';
end;

function TAqDBXFBConnection.GetAutoIncrement(const pGenerator: string): Int64;
var
  lReader: IAqDBReader;
begin
  lReader := OpenQuery('select gen_id(' + pGenerator + ', 1) from RDB$DATABASE');

  if not lReader.Next then
  begin
    raise EAqInternal.Create('It wasn''t possible to get the last insert id.');
  end;

  Result := lReader.Values[0].AsInt64;
end;

function TAqDBXFBConnection.GetAutoIncrementType: TAqDBAutoIncrementType;
begin
  Result := TAqDBAutoIncrementType.aiGenerator;
end;

class function TAqDBXFBConnection.GetDefaultMapper: TAqDBMapperClass;
begin
  Result := TAqDBXFBMapper;
end;

function TAqDBXFBConnection.GetPropertyValueAsString(const pIndex: Integer): string;
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

procedure TAqDBXFBConnection.SetPropertyValueAsString(const pIndex: Integer; const pValue: string);
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

{ TAqDBXFBMapper }

procedure TAqDBXFBMapper.BooleanToParameter(const pParameter: TDBXParameter; const pValue: Boolean);
begin
  pParameter.DataType := TDBXDataTypes.AnsiStringType;

  if pValue then
  begin
    pParameter.Value.SetAnsiString('1');
  end else begin
    pParameter.Value.SetAnsiString('0');
  end;
end;

function TAqDBXFBMapper.SolveBooleanConstant(pConstant: IAqDBSQLBooleanConstant): string;
begin
  if pConstant.Value then
  begin
    Result := '1';
  end else begin
    Result := '0';
  end;

  Result := Result.Quote;
end;

function TAqDBXFBMapper.SolveLimit(pSelect: IAqDBSQLSelect): string;
begin
  if pSelect.IsLimitDefined then
  begin
    Result := ' first ' + pSelect.Limit.ToString + ' ';
  end else begin
    Result := '';
  end;
end;

function TAqDBXFBMapper.SolveSelect(pSelect: IAqDBSQLSelect): string;
begin
  Result := 'select ' + SolveLimit(pSelect) + SolveSelectBody(pSelect);
end;

end.
