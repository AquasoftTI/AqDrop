unit AqDrop.DB.FD.FB;

interface

uses
  Data.DB,
{$IF CompilerVersion >= 26}
  FireDAC.Phys.FB,
{$ELSE}
  uADPhysIB,
{$ENDIF}
  AqDrop.Core.Types,
  AqDrop.DB.Adapter,
  AqDrop.DB.FB,
  AqDrop.DB.FD,
  AqDrop.DB.FD.TypeMapping;

type
  TAqFDFBDataConverter = class(TAqFDDataConverter)
  public
    function FieldToBoolean(const pField: TField): Boolean; override;
    function FieldToGUID(const pField: TField): TGUID; override;
    procedure BooleanToParam(const pParameter: TAqFDMappedParam; const pValue: Boolean); override;
    procedure GUIDToParam(const pParameter: TAqFDMappedParam; const pValue: TGUID); override;

    function AqDataTypeToFieldType(const pDataType: TAqDataType): TFieldType; override;
  end;

  TAqFDFBAdapter = class(TAqFDAdapter)
  strict protected
    function GetAutoIncrementType: TAqDBAutoIncrementType; override;
    class function GetDefaultSolver: TAqDBSQLSolverClass; override;
    class function GetDefaultDataConverter: TAqFDDataConverterClass; override;
  end;

  TAqFDFBConnection = class(TAqFDCustomConnection)
  strict protected
    function GetParameterValueByIndex(const pIndex: Int32): string; override;
    procedure SetParameterValueByIndex(const pIndex: Int32; const pValue: string); override;

    class function GetDefaultAdapter: TAqDBAdapterClass; override;
  public
    constructor Create; override;

    property DataBase: string index $80 read GetParameterValueByIndex write SetParameterValueByIndex;
    property UserName: string index $81 read GetParameterValueByIndex write SetParameterValueByIndex;
    property Password: string index $82 read GetParameterValueByIndex write SetParameterValueByIndex;
    property RoleName: string index $83 read GetParameterValueByIndex write SetParameterValueByIndex;
    property CharacterSet: string index $84 read GetParameterValueByIndex write SetParameterValueByIndex;
  end;


implementation

uses
  System.Types,
  System.SysUtils,
{$IF CompilerVersion >= 26}
  FireDAC.Stan.Param,
{$ENDIF}
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.DB.Types;

{ TAqFDFBDataConverter }

function TAqFDFBDataConverter.AqDataTypeToFieldType(const pDataType: TAqDataType): TFieldType;
begin
  if pDataType = TAqDataType.adtBoolean then
  begin
    Result := TFieldType.ftWideString;
  end else begin
    Result := inherited;
  end;
end;

procedure TAqFDFBDataConverter.BooleanToParam(const pParameter: TAqFDMappedParam; const pValue: Boolean);
begin
  if pValue then
  begin
    pParameter.AsString := '1';
  end else begin
    pParameter.AsString := '0';
  end;
end;

function TAqFDFBDataConverter.FieldToBoolean(const pField: TField): Boolean;
begin
  if pField.IsNull then
  begin
    Result := False;
  end else begin
    Result := inherited;
  end;
end;

function TAqFDFBDataConverter.FieldToGUID(const pField: TField): TGUID;
var
  lBytes: TArray<UInt8>;
begin
  if pField.IsNull then
  begin
    Result := inherited;
  end else
  begin
    lBytes := pField.AsBytes;
    Result := TGUID.Create(lBytes);
  end;
end;

procedure TAqFDFBDataConverter.GUIDToParam(const pParameter: TAqFDMappedParam; const pValue: TGUID);
var
  lBytes: TBytes;
begin
  if TAqGUIDFunctions.IsEmpty(pValue) then
  begin
    inherited;
  end else
  begin
    pParameter.DataType := ftString;
    lBytes := pValue.ToByteArray;
    pParameter.SetData(@lBytes[0], 16);
  end;
end;

{ TAqFDFBAdapter }

function TAqFDFBAdapter.GetAutoIncrementType: TAqDBAutoIncrementType;
begin
  Result := TAqDBAutoIncrementType.aiGenerator;
end;

class function TAqFDFBAdapter.GetDefaultDataConverter: TAqFDDataConverterClass;
begin
  Result := TAqFDFBDataConverter;
end;

class function TAqFDFBAdapter.GetDefaultSolver: TAqDBSQLSolverClass;
begin
  Result := TAqDBFBSQLSolver;
end;

{ TAqFDFBConnection }

constructor TAqFDFBConnection.Create;
begin
  inherited;

{$IF CompilerVersion >= 26}
  DriverName := 'FB';
{$ELSE}
  DriverName := 'IB';
{$ENDIF}
end;

class function TAqFDFBConnection.GetDefaultAdapter: TAqDBAdapterClass;
begin
  Result := TAqFDFBAdapter;
end;

function TAqFDFBConnection.GetParameterValueByIndex(const pIndex: Int32): string;
begin
  case pIndex of
    $80:
      Result := Params.Values['Database'];
    $81:
      Result := Params.Values['User_Name'];
    $82:
      Result := Params.Values['Password'];
    $83:
      Result := Params.Values['RoleName'];
    $84:
      Result := Params.Values['CharacterSet'];
  else
    Result := inherited;
  end;
end;

procedure TAqFDFBConnection.SetParameterValueByIndex(const pIndex: Int32; const pValue: string);
begin
  case pIndex of
    $80:
      Params.Values['Database'] := pValue;
    $81:
      Params.Values['User_Name'] := pValue;
    $82:
      Params.Values['Password'] := pValue;
    $83:
      Params.Values['RoleName'] := pValue;
    $84:
      Params.Values['CharacterSet'] := pValue;
  else
    inherited;
  end;
end;

end.
