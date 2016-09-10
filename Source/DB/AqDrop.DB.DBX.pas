unit AqDrop.DB.DBX;

interface

uses
  System.Rtti,
  System.SysUtils,
  Data.DBXCommon,
  Data.SqlTimSt,
  Data.FmtBcd,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Collections,
  AqDrop.Core.Types,
  AqDrop.DB.Types,
  AqDrop.DB.Adapter,
  AqDrop.DB.Connection;

const
  TAqDBXDataTypeMapping: array[TAqDataType] of TDBXType = (
    TDBXDataTypes.UnknownType,           // adtUnknown
    TDBXDataTypes.BooleanType,           // adtBoolean
    TDBXDataTypes.Int32Type,             // adtEnumerated
    TDBXDataTypes.UInt8Type,             // adtUInt8
    TDBXDataTypes.Int8Type,              // adtInt8
    TDBXDataTypes.UInt16Type,            // adtUInt16
    TDBXDataTypes.Int16Type,             // adtInt16
    TDBXDataTypes.UInt32Type,            // adtUInt32
    TDBXDataTypes.Int32Type,             // adtInt32
    TDBXDataTypes.UInt64Type,            // adtUInt64
    TDBXDataTypes.Int64Type,             // adtInt64
    TDBXDataTypes.CurrencyType,          // adtCurrency
    TDBXDataTypes.DoubleType,            // adtDouble
    TDBXDataTypes.SingleType,            // adtSingle
    TDBXDataTypes.DateTimeType,          // adtDatetime
    TDBXDataTypes.DateType,              // adtDate
    TDBXDataTypes.TimeType,              // adtTime
    TDBXDataTypes.AnsiStringType,        // adtAnsiChar
    TDBXDataTypes.WideStringType,        // adtChar
    TDBXDataTypes.AnsiStringType,        // adtAnsiString
    TDBXDataTypes.WideStringType,        // adtString
    TDBXDataTypes.WideStringType,        // adtWideString
    TDBXDataTypes.UnknownType,           // adtSet
    TDBXDataTypes.UnknownType,           // adtClass
    TDBXDataTypes.UnknownType,           // adtMethod
    TDBXDataTypes.VariantType,           // adtVariant
    TDBXDataTypes.UnknownType,           // adtRecord
    TDBXDataTypes.UnknownType);          // adtInterface

type
  TAqDBXDataConverter = class
  public
    function DBToString(const pValue: TDBXValue): string; virtual;
    function DBToAnsiString(const pValue: TDBXValue): AnsiString; virtual;
    function DBToBoolean(const pValue: TDBXValue): Boolean; virtual;
    function DBToTimeStamp(const pValue: TDBXValue): TSQLTimeStamp; virtual;
    function DBToTimeStampOffset(const pValue: TDBXValue): TSQLTimeStampOffset; virtual;
    function DBToBCD(const pValue: TDBXValue): TBcd; virtual;
    function DBToDate(const pValue: TDBXValue): TDate; virtual;
    function DBToTime(const pValue: TDBXValue): TTime; virtual;
    function DBToDateTime(const pValue: TDBXValue): TDateTime; virtual;
    function DBToUInt8(const pValue: TDBXValue): UInt8; virtual;
    function DBToInt8(const pValue: TDBXValue): Int8; virtual;
    function DBToUInt16(const pValue: TDBXValue): UInt16; virtual;
    function DBToInt16(const pValue: TDBXValue): Int16; virtual;
    function DBToUInt32(const pValue: TDBXValue): UInt32; virtual;
    function DBToInt32(const pValue: TDBXValue): Int32; virtual;
    function DBToUInt64(const pValue: TDBXValue): UInt64; virtual;
    function DBToInt64(const pValue: TDBXValue): Int64; virtual;
    function DBToSingle(const pValue: TDBXValue): Single; virtual;
    function DBToDouble(const pValue: TDBXValue): Double; virtual;
    function DBToCurrency(const pValue: TDBXValue): Currency; virtual;

    procedure StringToParameter(const pParameter: TDBXParameter; const pValue: string); virtual;
    procedure AnsiStringToParameter(const pParameter: TDBXParameter; const pValue: AnsiString); virtual;
    procedure BooleanToParameter(const pParameter: TDBXParameter; const pValue: Boolean); virtual;
    procedure TimeStampToParameter(const pParameter: TDBXParameter; const pValue: TSQLTimeStamp); virtual;
    procedure TimeStampOffsetToParameter(const pParameter: TDBXParameter;
      const pValue: TSQLTimeStampOffset); virtual;
    procedure BCDToParameter(const pParameter: TDBXParameter; const pValue: TBcd); virtual;
    procedure DateToParameter(const pParameter: TDBXParameter; const pValue: TDate); virtual;
    procedure TimeToParameter(const pParameter: TDBXParameter; const pValue: TTime); virtual;
    procedure DateTimeToParameter(const pParameter: TDBXParameter; const pValue: TDateTime); virtual;
    procedure UInt8ToParameter(const pParameter: TDBXParameter; const pValue: UInt8); virtual;
    procedure Int8ToParameter(const pParameter: TDBXParameter; const pValue: Int8); virtual;
    procedure UInt16ToParameter(const pParameter: TDBXParameter; const pValue: UInt16); virtual;
    procedure Int16ToParameter(const pParameter: TDBXParameter; const pValue: Int16); virtual;
    procedure UInt32ToParameter(const pParameter: TDBXParameter; const pValue: UInt32); virtual;
    procedure Int32ToParameter(const pParameter: TDBXParameter; const pValue: Int32); virtual;
    procedure UInt64ToParameter(const pParameter: TDBXParameter; const pValue: UInt64); virtual;
    procedure Int64ToParameter(const pParameter: TDBXParameter; const pValue: Int64); virtual;
    procedure SingleToParameter(const pParameter: TDBXParameter; const pValue: Single); virtual;
    procedure DoubleToParameter(const pParameter: TDBXParameter; const pValue: Double); virtual;
    procedure CurrencyToParameter(const pParameter: TDBXParameter; const pValue: Currency); virtual;
  end;

  TAqDBXDataConverterClass = class of TAqDBXDataConverter;

  TAqDBXAdapter = class(TAqDBAdapter)
  strict private
    FDBXConverter: TAqDBXDataConverter;

    procedure SetDBXConverter(const pValue: TAqDBXDataConverter);
  strict protected
    function CreateConverter: TAqDBXDataConverter; virtual;
    class function GetDefaultConverter: TAqDBXDataConverterClass; virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    property DBXConverter: TAqDBXDataConverter read FDBXConverter write SetDBXConverter;
  end;

  TAqDBXBaseValues = class;
  TAqDBXCustomConnection = class;

  TAqDBXBaseValue = class(TAqInterfacedObject, IAqDBReadValue)
  strict private
    FValues: TAqDBXBaseValues;
    FName: string;
  strict protected
    function GetValue: TDBXValue; virtual; abstract;

    function GetName: string; virtual;
    procedure SetName(const pName: string); virtual;

    function GetIsNull: Boolean; virtual;

    function GetAsString: string; virtual;
    function GetAsAnsiString: AnsiString; virtual;
    function GetAsBoolean: Boolean; virtual;
    function GetAsTimeStamp: TSQLTimeStamp; virtual;
    function GetAsTimeStampOffset: TSQLTimeStampOffset; virtual;
    function GetAsBCD: TBcd; virtual;
    function GetAsDate: TDate; virtual;
    function GetAsTime: TTime; virtual;
    function GetAsDateTime: TDateTime; virtual;
    function GetAsUInt8: UInt8; virtual;
    function GetAsInt8: Int8; virtual;
    function GetAsUInt16: UInt16; virtual;
    function GetAsInt16: Int16; virtual;
    function GetAsUInt32: UInt32; virtual;
    function GetAsInt32: Int32; virtual;
    function GetAsUInt64: UInt64; virtual;
    function GetAsInt64: Int64; virtual;
    function GetAsSingle: Single; virtual;
    function GetAsDouble: Double; virtual;
    function GetAsCurrency: Currency; virtual;

    class function MustCountReferences: Boolean; override;
  public
    constructor Create(const pValues: TAqDBXBaseValues; const pName: string);

    property Values: TAqDBXBaseValues read FValues;
  end;

  TAqDBXValue = class(TAqDBXBaseValue)
  strict private
    FValue: TDBXValue;
  strict protected
    function GetValue: TDBXValue; override;
  public
    constructor Create(const pValues: TAqDBXBaseValues; const pName: string; const pValue: TDBXValue);
  end;

  TAqDBXParameter = class(TAqDBXBaseValue, IAqDBValue)
  strict private
    FDBXParameter: TDBXParameter;
  strict protected
    function GetValue: TDBXValue; override;

    procedure SetDataType(const pDataType: TAqDataType);

    procedure SetAsString(const pValue: string); virtual;
    procedure SetAsAnsiString(const pValue: AnsiString); virtual;
    procedure SetAsBoolean(const pValue: Boolean); virtual;
    procedure SetAsTimeStamp(const pValue: TSQLTimeStamp); virtual;
    procedure SetAsTimeStampOffset(const pValue: TSQLTimeStampOffset); virtual;
    procedure SetAsBCD(const pValue: TBcd); virtual;
    procedure SetAsDate(const pValue: TDate); virtual;
    procedure SetAsTime(const pValue: TTime); virtual;
    procedure SetAsDateTime(const pValue: TDateTime); virtual;
    procedure SetAsUInt8(const pValue: UInt8); virtual;
    procedure SetAsInt8(const pValue: Int8); virtual;
    procedure SetAsUInt16(const pValue: UInt16); virtual;
    procedure SetAsInt16(const pValue: Int16); virtual;
    procedure SetAsUInt32(const pValue: UInt32); virtual;
    procedure SetAsInt32(const pValue: Int32); virtual;
    procedure SetAsUInt64(const pValue: UInt64); virtual;
    procedure SetAsInt64(const pValue: Int64); virtual;
    procedure SetAsSingle(const pValue: Single); virtual;
    procedure SetAsDouble(const pValue: Double); virtual;
    procedure SetAsCurrency(const pValue: Currency); virtual;

    procedure SetNull(const pDataType: TAqDataType = TAqDataType.adtUnknown);
  public
    constructor Create(const pValues: TAqDBXBaseValues; const pName: string; const pDBXParameter: TDBXParameter);

    property DBXParameter: TDBXParameter read FDBXParameter;
  end;

  TAqDBXParameterByNameSetterMethod =
    reference to procedure(const pParameterSetterMethod: TAqDBValueHandlerMethod);

  TAqDBXFakeParameterByName = class(TAqDBXParameter)
  strict private
    FParameterByNameSetterMethod: TAqDBXParameterByNameSetterMethod;
  strict protected
    procedure SetAsString(const pValue: string); override;
    procedure SetAsBoolean(const pValue: Boolean); override;
    procedure SetAsAnsiString(const pValue: AnsiString); override;
    procedure SetAsTimeStamp(const pValue: TSQLTimeStamp); override;
    procedure SetAsTimeStampOffset(const pValue: TSQLTimeStampOffset); override;
    procedure SetAsBCD(const pValue: TBcd); override;
    procedure SetAsDate(const pValue: TDate); override;
    procedure SetAsTime(const pValue: TTime); override;
    procedure SetAsDateTime(const pValue: TDateTime); override;
    procedure SetAsUInt8(const pValue: UInt8); override;
    procedure SetAsInt8(const pValue: Int8); override;
    procedure SetAsUInt16(const pValue: UInt16); override;
    procedure SetAsInt16(const pValue: Int16); override;
    procedure SetAsUInt32(const pValue: UInt32); override;
    procedure SetAsInt32(const pValue: Int32); override;
    procedure SetAsUInt64(const pValue: UInt64); override;
    procedure SetAsInt64(const pValue: Int64); override;
    procedure SetAsSingle(const pValue: Single); override;
    procedure SetAsDouble(const pValue: Double); override;
    procedure SetAsCurrency(const pValue: Currency); override;
  public
    constructor Create(const pValues: TAqDBXBaseValues; const pName: string; const pDBXParameter: TDBXParameter;
      const pParameterByNameSetterMethod: TAqDBXParameterByNameSetterMethod);
  end;

  TAqDBXBaseValues = class(TAqInterfacedObject)
  strict private
    FConnection: TAqDBXCustomConnection;
  public
    constructor Create(const pConnection: TAqDBXCustomConnection);

    property Connction: TAqDBXCustomConnection read FConnection;
  end;

  TAqDBXValues<I: IAqDBReadValue> = class(TAqDBXBaseValues)
  strict private
    FValues: TAqList<I>;
  strict protected
    class function MustCountReferences: Boolean; override;
  public
    constructor Create(const pConnection: TAqDBXCustomConnection);
    destructor Destroy; override;

    function GetValueByIndex(pIndex: Int32): I; virtual;
    function GetValueByName(pName: string): I; virtual;
    function GetCount: Int32;

    procedure Add(pValue: I);
  end;

  TAqDBXParameters = class(TAqDBXValues<IAqDBValue>, IAqDBParameters)
  strict private
    FDBXCommand: TDBXCommand;
  strict protected
    class function MustCountReferences: Boolean; override;
  public
    constructor Create(const pConnection: TAqDBXCustomConnection; const pDBXCommand: TDBXCommand);

    procedure CreateParameter(const pName: string);
    function GetValueByName(pName: string): IAqDBValue; override;
  end;

  TAqDBXReader = class;

  TAqDBXCommand = class
  strict private
    FConnection: TAqDBXCustomConnection;
    FDBXCommand: TDBXCommand;
    FParameters: TAqDBXParameters;
    FPrepared: Boolean;
  public
    constructor Create(const pConnection: TAqDBXCustomConnection; const pDBXCommand: TDBXCommand);
    destructor Destroy; override;

    function Execute(const pParametersHandler: TAqDBParametersHandlerMethod): Int64;
    function Open(const pParametersHandler: TAqDBParametersHandlerMethod): TAqDBXReader;

    procedure Prepare(const pParametersInitializer: TAqDBParametersHandlerMethod);

    property DBXCommand: TDBXCommand read FDBXCommand;
    property Parameters: TAqDBXParameters read FParameters;
    property Prepared: Boolean read FPrepared;
  end;

  TAqDBXReader = class(TAqDBXValues<IAqDBReadValue>, IAqDBReader)
  strict private
    FCommand: TAqDBXCommand;
    FDBXReader: TDBXReader;
  public
    constructor Create(const pConnection: TAqDBXCustomConnection; const pCommand: TAqDBXCommand);
    destructor Destroy; override;

    function Next: Boolean;
  end;

  TAqDBXParser = class
  strict private type
    TAqDBParserHandlerMethod = reference to procedure(const pName: string);
  strict private
    class procedure Execute(const pHandlerMethod: TAqDBParserHandlerMethod; var pSQL: string); overload;
  public
    class procedure Execute(const pParameters: TAqDBXParameters; var pSQL: string); overload;
  end;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Base class for connections using DBX framework.
  ///   PT-BR:
  ///     Classe base para conexões usando DBX framework.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqDBXCustomConnection = class (TAqDBConnection)
  strict private
    FDBXConnection: TDBXConnection;
    FDBXTransaction: TDBXTransaction;
    FProperties: TDBXProperties;
    FPreparedQueries: TAqIDDictionary<TAqDBXCommand>;

    function CreateCommand: TAqDBXCommand;
    function PrepareDBXCommand(pSQL: string): TAqDBXCommand;

    function GetProperty(pName: string): string;
    procedure SetProperty(pName: string; const pValue: string);
    function GetDBXAdapter: TAqDBXAdapter;
    procedure SetDBXAdapter(const pValue: TAqDBXAdapter);
  strict protected
    procedure DoConnect; override;
    procedure DoDisconnect; override;

    function GetPropertyValueAsString(const pIndex: Int32): string; virtual;
    procedure SetPropertyValueAsString(const pIndex: Int32; const pValue: string); virtual;

    function GetActive: Boolean; override;

    function DoPrepareCommand(const pSQL: string;
      const pParametersInitializer: TAqDBParametersHandlerMethod): TAqID; override;
    procedure DoUnprepareCommand(const pCommandID: TAqID); override;

    function DoExecuteCommand(const pSQL: string;
      const pParametersHandler: TAqDBParametersHandlerMethod): Int64; override;
    function DoExecuteCommand(const pCommandID: TAqID;
      const pParametersHandler: TAqDBParametersHandlerMethod): Int64; override;

    function DoOpenQuery(const pSQL: string;
      const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader; override;
    function DoOpenQuery(const pCommandID: TAqID;
      const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader; override;

    procedure DoStartTransaction; override;
    procedure DoCommitTransaction; override;
    procedure DoRollbackTransaction; override;

    class function GetDefaultAdapter: TAqDBAdapterClass; override;

    property DriverName: string index $00 read GetPropertyValueAsString write SetPropertyValueAsString;
    property VendorLib: string index $01 read GetPropertyValueAsString write SetPropertyValueAsString;
    property LibraryName: string index $02 read GetPropertyValueAsString write SetPropertyValueAsString;
    property GetDriverFunc: string index $03 read GetPropertyValueAsString write SetPropertyValueAsString;

    property Properties[Name: string]: string read GetProperty write SetProperty;
  protected
    procedure SetAdapter(const pAdapter: TAqDBAdapter); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    property DBXAdapter: TAqDBXAdapter read GetDBXAdapter write SetDBXAdapter;
  end;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Generic class for connections with DBMSs using DBX framework.
  ///   PT-BR:
  ///     Classe genérica para conexão com SGBDs usando DBX framework.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqDBXConnection = class(TAqDBXCustomConnection)
  strict private
    FGetterAutoIncrement: TFunc<Int64>;
  public
    function GetAutoIncrement(const pGeneratorName: string = ''): Int64; override;

    property DriverName;
    property VendorLib;
    property LibraryName;
    property GetDriverFunc;
    property Properties;

    property GetterAutoIncrement: TFunc<Int64> read FGetterAutoIncrement write FGetterAutoIncrement;
  end;

implementation

uses
  System.StrUtils,
  System.DateUtils,
  System.Classes,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.DB.Tokenizer;


{ TAqDBXCustomConnection }

procedure TAqDBXCustomConnection.DoConnect;
begin
  inherited;

  try
    FDBXConnection := TDBXConnectionFactory.GetConnectionFactory.GetConnection(FProperties);
  except
    on E: Exception do
    begin
      FreeAndNil(FDBXConnection);
      RaiseImpossibleToConnect(E);
    end;
  end;
end;

constructor TAqDBXCustomConnection.Create;
begin
  inherited;

  FProperties := TDBXProperties.Create;
  FPreparedQueries := TAqIDDictionary<TAqDBXCommand>.Create(True);
end;

function TAqDBXCustomConnection.CreateCommand: TAqDBXCommand;
begin
  Result := TAqDBXCommand.Create(Self, Self.FDBXConnection.CreateCommand);
end;

procedure TAqDBXCustomConnection.DoDisconnect;
var
  lID: TAqID;
begin
  for lID in FPreparedQueries.Keys do
  begin
    UnprepareCommand(lID);
  end;

  FreeAndNil(FDBXConnection);
end;

destructor TAqDBXCustomConnection.Destroy;
begin
  if Assigned(FDBXTransaction) then
  begin
    FDBXConnection.RollbackFreeAndNil(FDBXTransaction);
  end;

  FPreparedQueries.Free;
  FDBXConnection.Free;
  FProperties.Free;

  inherited;
end;

function TAqDBXCustomConnection.GetProperty(pName: string): string;
begin
  Result := FProperties.Values[pName];
end;

function TAqDBXCustomConnection.GetActive: Boolean;
begin
  Result := Assigned(FDBXConnection);
end;

function TAqDBXCustomConnection.GetDBXAdapter: TAqDBXAdapter;
begin
  Result := TAqDBXAdapter(Adapter);
end;

class function TAqDBXCustomConnection.GetDefaultAdapter: TAqDBAdapterClass;
begin
  Result := TAqDBXAdapter;
end;

function TAqDBXCustomConnection.GetPropertyValueAsString(const pIndex: Int32): string;
begin
  case pIndex of
    $00:
      Result := FProperties.Values[TDBXPropertyNames.DriverName];
    $01:
      Result := FProperties.Values[TDBXPropertyNames.VendorLib];
    $02:
      Result := FProperties.Values[TDBXPropertyNames.LibraryName];
    $03:
      Result := FProperties.Values[TDBXPropertyNames.GetDriverFunc];
  else
    raise EAqInternal.Create('Index not expected in TAqDBXCustomConnection.GetPropertyValueAsString.');
  end;
end;

function TAqDBXCustomConnection.PrepareDBXCommand(pSQL: string): TAqDBXCommand;
begin
  Result := CreateCommand;

  try
    TAqDBXParser.Execute(Result.Parameters, pSQL);
    Result.DBXCommand.Text := pSQL;
    Result.DBXCommand.Prepare;
  except
    Result.Free;
    raise;
  end;
end;

function TAqDBXCustomConnection.DoOpenQuery(const pSQL: string;
  const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader;
var
  lCommand: TAqDBXCommand;
begin
  lCommand := PrepareDBXCommand(pSQL);

  try
    if Assigned(pParametersHandler) then
    begin
      pParametersHandler(lCommand.Parameters);
    end;
  except
    lCommand.Free;
    raise;
  end;

  Result := TAqDBXReader.Create(Self, lCommand);
end;

function TAqDBXCustomConnection.DoExecuteCommand(const pSQL: string;
  const pParametersHandler: TAqDBParametersHandlerMethod): Int64;
var
  lCommand: TAqDBXCommand;
begin
  lCommand := PrepareDBXCommand(pSQL);

  try
    Result := lCommand.Execute(pParametershandler);
  finally
    lCommand.Free;
  end;
end;

procedure TAqDBXCustomConnection.SetDBXAdapter(const pValue: TAqDBXAdapter);
begin
  SetAdapter(pValue);
end;

procedure TAqDBXCustomConnection.SetAdapter(const pAdapter: TAqDBAdapter);
begin
  if not (pAdapter is TAqDBXAdapter) then
  begin
    raise EAqInternal.Create('Invalid Adapter for a DBX Connection.');
  end;

  inherited;
end;

procedure TAqDBXCustomConnection.SetProperty(pName: string; const pValue: string);
begin
  FProperties.Values[pName] := pValue;
end;

procedure TAqDBXCustomConnection.SetPropertyValueAsString(const pIndex: Int32; const pValue: string);
begin
  case pIndex of
    $00:
      FProperties.Values[TDBXPropertyNames.DriverName] := pValue;
    $01:
      FProperties.Values[TDBXPropertyNames.VendorLib] := pValue;
    $02:
      FProperties.Values[TDBXPropertyNames.LibraryName] := pValue;
    $03:
      FProperties.Values[TDBXPropertyNames.GetDriverFunc] := pValue;
  else
    raise EAqInternal.Create('Wrong index for setting connection properties.');
  end;
end;

function TAqDBXCustomConnection.DoOpenQuery(const pCommandID: TAqID;
  const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader;
var
  lCommand: TAqDBXCommand;
begin
  if FPreparedQueries.TryGetValue(pCommandID, lCommand) then
  begin
    Result := lCommand.Open(pParametersHandler);
  end else begin
    raise EAqInternal.Create('Command of ID ' + pCommandID.ToString + ' not found.');
  end;
end;

procedure TAqDBXCustomConnection.DoStartTransaction;
begin
  inherited;

  FDBXTransaction := FDBXConnection.BeginTransaction;
end;

procedure TAqDBXCustomConnection.DoCommitTransaction;
begin
  FDBXConnection.CommitFreeAndNil(FDBXTransaction);

  inherited;
end;

function TAqDBXCustomConnection.DoExecuteCommand(const pCommandID: TAqID;
  const pParametersHandler: TAqDBParametersHandlerMethod): Int64;
var
  lCommand: TAqDBXCommand;
begin
  if FPreparedQueries.TryGetValue(pCommandID, lCommand) then
  begin
    Result := lCommand.Execute(pParametersHandler);
  end else begin
    raise EAqInternal.Create('Command from ID ' + pCommandID.ToString + ' not found.');
  end;
end;

function TAqDBXCustomConnection.DoPrepareCommand(const pSQL: string;
  const pParametersInitializer: TAqDBParametersHandlerMethod): TAqID;
var
  lCommand: TAqDBXCommand;
begin
  lCommand := nil;

  try
    lCommand := PrepareDBXCommand(pSQL);

    lCommand.Prepare(pParametersInitializer);

    Result := FPreparedQueries.Add(lCommand);
  except
    lCommand.Free;
    raise;
  end;
end;

procedure TAqDBXCustomConnection.DoRollbackTransaction;
begin
  FDBXConnection.RollbackFreeAndNil(FDBXTransaction);

  inherited;
end;

procedure TAqDBXCustomConnection.DoUnprepareCommand(const pCommandID: TAqID);
begin
  FPreparedQueries.Remove(pCommandID);

  inherited;
end;

{ TAqDBXParser }

class procedure TAqDBXParser.Execute(const pParameters: TAqDBXParameters; var pSQL: string);
begin
  Execute(
    procedure(const pName: string)
    begin
      pParameters.CreateParameter(pName);
    end,
    pSQL);
end;

class procedure TAqDBXParser.Execute(const pHandlerMethod: TAqDBParserHandlerMethod; var pSQL: string);
var
  lTokens: TAqBDTokenizer.IAqTokenizerResult;
  lToken: TAqBDTokenizer.TAqTokenizerToken;
begin
  lTokens := TAqBDTokenizer.GetInstance.Execute(pSQL);

  pSQL := '';

  for lToken in lTokens do
  begin
    if lToken.&Type = ttNamedParameter then
    begin
      pSQL := pSQL + '?';

      pHandlerMethod(RightStr(lToken.Text, Length(lToken.Text) - 1));
    end else begin
      if lToken.&Type = ttParameter then
      begin
        pHandlerMethod('');
      end;
      pSQL := pSQL + lToken.Text;
    end;
  end;
end;

{ TAqDBXBaseValue }

class function TAqDBXBaseValue.MustCountReferences: Boolean;
begin
  Result := True;
end;

constructor TAqDBXBaseValue.Create(const pValues: TAqDBXBaseValues; const pName: string);
begin
  inherited Create;

  FValues := pValues;
  FName := pName;
end;

function TAqDBXBaseValue.GetAsAnsiString: AnsiString;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToAnsiString(GetValue);
end;

function TAqDBXBaseValue.GetAsBCD: TBcd;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToBCD(GetValue);
end;

function TAqDBXBaseValue.GetAsBoolean: Boolean;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToBoolean(GetValue);
end;

function TAqDBXBaseValue.GetAsCurrency: Currency;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToCurrency(GetValue);
end;

function TAqDBXBaseValue.GetAsDate: TDate;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToDate(GetValue);
end;

function TAqDBXBaseValue.GetAsDateTime: TDateTime;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToDateTime(GetValue);
end;

function TAqDBXBaseValue.GetAsDouble: Double;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToDouble(GetValue);
end;

function TAqDBXBaseValue.GetAsInt16: Int16;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToInt16(GetValue);
end;

function TAqDBXBaseValue.GetAsInt32: Int32;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToInt32(GetValue);
end;

function TAqDBXBaseValue.GetAsInt64: Int64;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToInt64(GetValue);
end;

function TAqDBXBaseValue.GetAsInt8: Int8;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToInt8(GetValue);
end;

function TAqDBXBaseValue.GetAsSingle: Single;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToSingle(GetValue);
end;

function TAqDBXBaseValue.GetAsString: string;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToString(GetValue);
end;

function TAqDBXBaseValue.GetAsTime: TTime;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToTime(GetValue);
end;

function TAqDBXBaseValue.GetAsTimeStamp: TSQLTimeStamp;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToTimeStamp(GetValue);
end;

function TAqDBXBaseValue.GetAsTimeStampOffset: TSQLTimeStampOffset;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToTimeStampOffset(GetValue);
end;

function TAqDBXBaseValue.GetAsUInt16: UInt16;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToUInt16(GetValue);
end;

function TAqDBXBaseValue.GetAsUInt32: UInt32;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToUInt32(GetValue);
end;

function TAqDBXBaseValue.GetAsUInt64: UInt64;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToUInt64(GetValue);
end;

function TAqDBXBaseValue.GetAsUInt8: UInt8;
begin
  Result := Values.Connction.DBXAdapter.DBXConverter.DBToUInt8(GetValue);
end;

function TAqDBXBaseValue.GetName: string;
begin
  Result := FName;
end;

function TAqDBXBaseValue.GetIsNull: Boolean;
begin
  Result := GetValue.IsNull;
end;

procedure TAqDBXBaseValue.SetName(const pName: string);
begin
  FName := pName;
end;

{ TAqDBXValue }

constructor TAqDBXValue.Create(const pValues: TAqDBXBaseValues; const pName: string; const pValue: TDBXValue);
begin
  inherited Create(pValues, pName);

  FValue := pValue;
end;

function TAqDBXValue.GetValue: TDBXValue;
begin
  Result := FValue;
end;

{ TAqDBXParameter }

constructor TAqDBXParameter.Create(const pValues: TAqDBXBaseValues; const pName: string;
  const pDBXParameter: TDBXParameter);
begin
  inherited Create(pValues, pName);

  FDBXParameter := pDBXParameter;
end;

function TAqDBXParameter.GetValue: TDBXValue;
begin
  Result := FDBXParameter.Value;
end;

procedure TAqDBXParameter.SetAsAnsiString(const pValue: AnsiString);
begin
  Values.Connction.DBXAdapter.DBXConverter.AnsiStringToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsBCD(const pValue: TBcd);
begin
  Values.Connction.DBXAdapter.DBXConverter.BCDToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsBoolean(const pValue: Boolean);
begin
  Values.Connction.DBXAdapter.DBXConverter.BooleanToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsCurrency(const pValue: Currency);
begin
  Values.Connction.DBXAdapter.DBXConverter.CurrencyToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsDate(const pValue: TDate);
begin
  Values.Connction.DBXAdapter.DBXConverter.DateToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsDateTime(const pValue: TDateTime);
begin
  Values.Connction.DBXAdapter.DBXConverter.DateTimeToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsDouble(const pValue: Double);
begin
  Values.Connction.DBXAdapter.DBXConverter.DoubleToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsInt16(const pValue: Int16);
begin
  Values.Connction.DBXAdapter.DBXConverter.Int16ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsInt32(const pValue: Int32);
begin
  Values.Connction.DBXAdapter.DBXConverter.Int32ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsInt64(const pValue: Int64);
begin
  Values.Connction.DBXAdapter.DBXConverter.Int64ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsInt8(const pValue: Int8);
begin
  Values.Connction.DBXAdapter.DBXConverter.Int8ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsSingle(const pValue: Single);
begin
  Values.Connction.DBXAdapter.DBXConverter.SingleToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsString(const pValue: string);
begin
  Values.Connction.DBXAdapter.DBXConverter.StringToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsTime(const pValue: TTime);
begin
  Values.Connction.DBXAdapter.DBXConverter.TimeToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsTimeStamp(const pValue: TSQLTimeStamp);
begin
  Values.Connction.DBXAdapter.DBXConverter.TimeStampToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsTimeStampOffset(const pValue: TSQLTimeStampOffset);
begin
  Values.Connction.DBXAdapter.DBXConverter.TimeStampOffsetToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsUInt16(const pValue: UInt16);
begin
  Values.Connction.DBXAdapter.DBXConverter.UInt16ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsUInt32(const pValue: UInt32);
begin
  Values.Connction.DBXAdapter.DBXConverter.UInt32ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsUInt64(const pValue: UInt64);
begin
  Values.Connction.DBXAdapter.DBXConverter.UInt64ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsUInt8(const pValue: UInt8);
begin
  Values.Connction.DBXAdapter.DBXConverter.UInt8ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetDataType(const pDataType: TAqDataType);
begin
  FDBXParameter.DataType := TAqDBXDataTypeMapping[pDataType];
end;

procedure TAqDBXParameter.SetNull;
begin
  FDBXParameter.DataType := TAqDBXDataTypeMapping[pDataType];
  FDBXParameter.Value.SetNull;
end;

{ TAqDBXFakeParameterByName }

constructor TAqDBXFakeParameterByName.Create(const pValues: TAqDBXBaseValues; const pName: string;
  const pDBXParameter: TDBXParameter; const pParameterByNameSetterMethod: TAqDBXParameterByNameSetterMethod);
begin
  inherited Create(pValues, pName, pDBXParameter);

  FParameterByNameSetterMethod := pParameterByNameSetterMethod;
end;

procedure TAqDBXFakeParameterByName.SetAsAnsiString(const pValue: AnsiString);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsAnsiString := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsBCD(const pValue: TBcd);
var
  lValor: TBcd;
begin
  lValor := pValue;
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsBCD := lValor;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsBoolean(const pValue: Boolean);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsBoolean := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsCurrency(const pValue: Currency);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsCurrency := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsDate(const pValue: TDate);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsDate := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsDateTime(const pValue: TDateTime);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsDateTime := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsDouble(const pValue: Double);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsDouble := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsInt16(const pValue: Int16);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsInt16 := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsInt32(const pValue: Int32);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsInt32 := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsInt64(const pValue: Int64);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsInt64 := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsInt8(const pValue: Int8);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsInt8 := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsSingle(const pValue: Single);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsSingle := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsString(const pValue: string);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsString := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsTime(const pValue: TTime);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsTime := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsTimeStamp(const pValue: TSQLTimeStamp);
var
  lValor: TSQLTimeStamp;
begin
  lValor := pValue;
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsTimeStamp := lValor;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsTimeStampOffset(const pValue: TSQLTimeStampOffset);
var
  lValor: TSQLTimeStampOffset;
begin
  lValor := pValue;
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsTimeStampOffset := lValor;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsUInt16(const pValue: UInt16);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsUInt16 := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsUInt32(const pValue: UInt32);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsUInt32 := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsUInt64(const pValue: UInt64);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsUInt64 := pValue;
    end);
end;

procedure TAqDBXFakeParameterByName.SetAsUInt8(const pValue: UInt8);
begin
  FParameterByNameSetterMethod(
    procedure(pParameter: IAqDBValue)
    begin
      pParameter.AsUInt8 := pValue;
    end);
end;

{ TAqDBXValues<I> }

procedure TAqDBXValues<I>.Add(pValue: I);
begin
  FValues.Add(pValue);
end;

class function TAqDBXValues<I>.MustCountReferences: Boolean;
begin
  Result := True;
end;

constructor TAqDBXValues<I>.Create(const pConnection: TAqDBXCustomConnection);
begin
  inherited Create(pConnection);

  FValues := TAqList<I>.Create;
end;

destructor TAqDBXValues<I>.Destroy;
begin
  FValues.Free;

  inherited;
end;

function TAqDBXValues<I>.GetCount: Int32;
begin
  Result := FValues.Count;
end;

function TAqDBXValues<I>.GetValueByIndex(pIndex: Int32): I;
begin
  Result := FValues[pIndex];
end;

function TAqDBXValues<I>.GetValueByName(pName: string): I;
var
  lI: Int32;
begin
  lI := FValues.Count - 1;

  while (lI >= 0) and (FValues[lI].Name <> pName) do
  begin
    Dec(lI);
  end;

  if lI < 0 then
  begin
    raise EAqInternal.Create('Value of name ' + pName + ' not found.');
  end;

  Result := FValues[lI];
end;

{ TAqDBXReader }

constructor TAqDBXReader.Create(const pConnection: TAqDBXCustomConnection; const pCommand: TAqDBXCommand);
var
  lValue: TDBXValue;
begin
  pConnection.IncreaseReaderes;

  inherited Create(pConnection);

  FCommand := pCommand;
  FDBXReader := FCommand.DBXCommand.ExecuteQuery;

  for lValue in FDBXReader.Values do
  begin
    Add(TAqDBXValue.Create(Self, lValue.ValueType.Name, lValue));
  end;
end;

destructor TAqDBXReader.Destroy;
begin
  FDBXReader.Free;

  if not FCommand.Prepared then
  begin
    FCommand.Free;
  end;

  Connction.DecrementReaders;

  inherited;
end;

function TAqDBXReader.Next: Boolean;
begin
  Result := FDBXReader.Next;
end;

{ TAqDBXParameters }

class function TAqDBXParameters.MustCountReferences: Boolean;
begin
  Result := False;
end;

constructor TAqDBXParameters.Create(const pConnection: TAqDBXCustomConnection; const pDBXCommand: TDBXCommand);
begin
  inherited Create(pConnection);

  FDBXCommand := pDBXCommand;
end;

procedure TAqDBXParameters.CreateParameter(const pName: string);
var
  lParameter: TDBXParameter;
begin
  lParameter := FDBXCommand.CreateParameter;
  try
    FDBXCommand.Parameters.AddParameter(lParameter);
  except
    lParameter.Free;
    raise;
  end;

  lParameter.Name := pName;
  Add(TAqDBXParameter.Create(Self, pName, lParameter));
end;

function TAqDBXParameters.GetValueByName(pName: string): IAqDBValue;
begin
  Result := TAqDBXFakeParameterByName.Create(Self, pName,
    (inherited GetValueByName(pName) as TAqDBXParameter).DBXParameter,
    procedure(const pMetodoAqBDValor: TAqDBValueHandlerMethod)
    var
      lI: Int32;
      lValue: IAqDBValue;
    begin
      lI := GetCount;

      while lI > 0 do
      begin
        Dec(lI);

        lValue := GetValueByIndex(lI);
        if lValue.Name = pName then
        begin
          pMetodoAqBDValor(lValue);
        end;
      end;
    end);
end;

{ TAqDBXBaseValues }

constructor TAqDBXBaseValues.Create(const pConnection: TAqDBXCustomConnection);
begin
  FConnection := pConnection;
end;

{ TAqDBXDataConverter }

procedure TAqDBXDataConverter.AnsiStringToParameter(const pParameter: TDBXParameter;
  const pValue: AnsiString);
begin
  pParameter.DataType := TDBXDataTypes.AnsiStringType;
  pParameter.Value.SetAnsiString(pValue);
end;

procedure TAqDBXDataConverter.BCDToParameter(const pParameter: TDBXParameter; const pValue: TBcd);
begin
  pParameter.DataType := TDBXDataTypes.BcdType;
  pParameter.Value.SetBcd(pValue);
end;

function TAqDBXDataConverter.DBToAnsiString(const pValue: TDBXValue): AnsiString;
begin
  if pValue.IsNull then
  begin
    Result := '';
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := pValue.GetAnsiString;
    else
      Result := AnsiString(DBToString(pValue));
    end;
  end;
end;

function TAqDBXDataConverter.DBToBCD(const pValue: TDBXValue): TBcd;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString);
      TDBXDataTypes.Int16Type:
        Result := Int32(pValue.AsInt16);
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble;
      TDBXDataTypes.BcdType:
        Result := pValue.AsBcd;
      TDBXDataTypes.UInt16Type:
        Result := Int32(pValue.AsUInt16);
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle;
      TDBXDataTypes.Int8Type:
        Result := Int32(pValue.AsInt8);
      TDBXDataTypes.UInt8Type:
        Result := Int32(pValue.AsUInt8);
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain a BCD field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToBoolean(const pValue: TDBXValue): Boolean;
begin
  if pValue.IsNull then
  begin
    Result := False;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result :=  string(pValue.GetAnsiString).ToBoolean;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean;
      TDBXDataTypes.Int16Type:
        Result := Boolean(pValue.AsInt16);
      TDBXDataTypes.Int32Type:
        Result := Boolean(pValue.AsInt32);
      TDBXDataTypes.UInt16Type:
        Result := Boolean(pValue.AsUInt16);
      TDBXDataTypes.Int64Type:
        Result := Boolean(pValue.AsInt64);
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToBoolean;
      TDBXDataTypes.Int8Type:
        Result := Boolean(pValue.AsInt8);
      TDBXDataTypes.UInt8Type:
        Result := Boolean(pValue.AsUInt8);
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain a boolean field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToCurrency(const pValue: TDBXValue): Currency;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToCurrency;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble;
      TDBXDataTypes.BcdType:
        Result := pValue.AsBcd.ToCurrency;
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToCurrency;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain a Currency field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToDate(const pValue: TDBXValue): TDate;
var
  lTimeStamp: TSQLTimeStamp;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToDate;
      TDBXDataTypes.DateType:
        Result := pValue.AsDateTime.DateOf;
      TDBXDataTypes.DoubleType:
        Result := DateOf(pValue.AsDouble);
      TDBXDataTypes.DateTimeType:
        Result := pValue.AsDateTime.DateOf;
      TDBXDataTypes.TimeStampType:
        begin
          lTimeStamp := pValue.AsTimeStamp;
          Result := TDate.EncodeDate(lTimeStamp.Year, lTimeStamp.Month, lTimeStamp.Day);
        end;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToDate;
      TDBXDataTypes.SingleType:
        Result := DateOf(pValue.AsSingle);
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain a date field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToDateTime(const pValue: TDBXValue): TDateTime;
var
  lTimeStamp: TSQLTimeStamp;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToDateTime;
      TDBXDataTypes.DateType:
        Result := pValue.AsDateTime;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble;
      TDBXDataTypes.DateTimeType:
        Result := pValue.AsDateTime;
      TDBXDataTypes.TimeStampType:
        begin
          lTimeStamp := pValue.AsTimeStamp;
          Result := TDateTime.EncodeDateTime(lTimeStamp.Year, lTimeStamp.Month, lTimeStamp.Day, lTimeStamp.Hour,
            lTimeStamp.Minute, lTimeStamp.Second, lTimeStamp.Fractions);
        end;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToDateTime;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain a datetime field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToDouble(const pValue: TDBXValue): Double;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToDouble;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble;
      TDBXDataTypes.BcdType:
        Result := pValue.AsBcd.ToString.ToDouble;
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToDouble;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain a Double field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToInt16(const pValue: TDBXValue): Int16;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToInt16;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble.Trunc;
      TDBXDataTypes.BcdType:
        Result := Int32(pValue.AsBcd);
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToInt16;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle.Trunc;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain an Int16 field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToInt32(const pValue: TDBXValue): Int32;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToInt32;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble.Trunc;
      TDBXDataTypes.BcdType:
        Result := Int32(pValue.AsBcd);
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToInt32;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle.Trunc;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain an Int32 field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToInt64(const pValue: TDBXValue): Int64;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToInt64;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble.Trunc;
      TDBXDataTypes.BcdType:
        Result := pValue.AsBcd.ToString.ToDouble.Trunc;
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToInt64;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle.Trunc;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain an Int64 field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToInt8(const pValue: TDBXValue): Int8;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToInt8;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble.Trunc;
      TDBXDataTypes.BcdType:
        Result := Int32(pValue.AsBcd);
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToInt8;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle.Trunc;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain an Int8 field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToSingle(const pValue: TDBXValue): Single;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToDouble;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble;
      TDBXDataTypes.BcdType:
        Result := pValue.AsBcd.ToString.ToDouble;
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToDouble;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain a Single field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToString(const pValue: TDBXValue): string;
begin
  if pValue.IsNull then
  begin
    Result := '';
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString);
      TDBXDataTypes.BlobType:
        Result := pValue.AsString;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToString;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16.ToString;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32.ToString;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble.ToString;
      TDBXDataTypes.BcdType:
        Result := pValue.AsBcd.ToString;
      TDBXDataTypes.DateTimeType:
        Result := pValue.AsDateTime.ToString;
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16.ToString;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64.ToString;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle.ToString;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8.ToString;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8.ToString;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain a string field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToTime(const pValue: TDBXValue): TTime;
var
  lTimeStamp: TSQLTimeStamp;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToTime;
      TDBXDataTypes.DoubleType:
        Result := TimeOf(pValue.AsDouble);
      TDBXDataTypes.TimeType:
        Result := pValue.AsDateTime.TimeOf;
      TDBXDataTypes.DateTimeType:
        Result := pValue.AsDateTime.TimeOf;
      TDBXDataTypes.TimeStampType:
        begin
          lTimeStamp := pValue.AsTimeStamp;
          Result := TTime.EncodeTime(lTimeStamp.Hour, lTimeStamp.Minute, lTimeStamp.Second, lTimeStamp.Fractions);
        end;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToTime;
      TDBXDataTypes.SingleType:
        Result := TimeOf(pValue.AsSingle);
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain a time field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToTimeStamp(const pValue: TDBXValue): TSQLTimeStamp;
begin
  case pValue.ValueType.DataType of
    TDBXDataTypes.AnsiStringType:
      Result := string(pValue.GetAnsiString).ToDateTime.ToSQLTimeStamp;
    TDBXDataTypes.DoubleType:
      Result := TDateTime(pValue.AsDouble).ToSQLTimeStamp;
    TDBXDataTypes.DateTimeType:
      Result := pValue.AsDateTime.ToSQLTimeStamp;
    TDBXDataTypes.TimeStampType:
      Result := pValue.AsTimeStamp;
    TDBXDataTypes.WideStringType:
      Result := pValue.AsString.ToDateTime.ToSQLTimeStamp;
  else
    raise EAqInternal.Create('Unexpectet type when trying to obtain a TimeStamp field.');
  end;
end;

function TAqDBXDataConverter.DBToTimeStampOffset(const pValue: TDBXValue): TSQLTimeStampOffset;
begin
  case pValue.ValueType.DataType of
    TDBXDataTypes.TimeStampOffsetType:
      Result := pValue.GetTimeStampOffset;
  else
    raise EAqInternal.Create('Unexpectet type when trying to obtain a TimeStampOffset field.');
  end;
end;

function TAqDBXDataConverter.DBToUInt16(const pValue: TDBXValue): UInt16;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToUInt16;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble.Trunc;
      TDBXDataTypes.BcdType:
        Result := Int32(pValue.AsBcd);
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToUInt16;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle.Trunc;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain an UInt16 field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToUInt32(const pValue: TDBXValue): UInt32;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToUInt32;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble.Trunc;
      TDBXDataTypes.BcdType:
        Result := Int32(pValue.AsBcd);
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToUInt32;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle.Trunc;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain an UInt32 field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToUInt64(const pValue: TDBXValue): UInt64;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToUInt64;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble.Trunc;
      TDBXDataTypes.BcdType:
        Result := pValue.AsBcd.ToString.ToDouble.Trunc;
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToUInt64;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle.Trunc;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain an UInt64 field.');
    end;
  end;
end;

function TAqDBXDataConverter.DBToUInt8(const pValue: TDBXValue): UInt8;
begin
  if pValue.IsNull then
  begin
    Result := 0;
  end else begin
    case pValue.ValueType.DataType of
      TDBXDataTypes.AnsiStringType:
        Result := string(pValue.GetAnsiString).ToUInt8;
      TDBXDataTypes.BooleanType:
        Result := pValue.AsBoolean.ToInt8;
      TDBXDataTypes.Int16Type:
        Result := pValue.AsInt16;
      TDBXDataTypes.Int32Type:
        Result := pValue.AsInt32;
      TDBXDataTypes.DoubleType:
        Result := pValue.AsDouble.Trunc;
      TDBXDataTypes.BcdType:
        Result := Int32(pValue.AsBcd);
      TDBXDataTypes.UInt16Type:
        Result := pValue.AsUInt16;
      TDBXDataTypes.Int64Type:
        Result := pValue.AsInt64;
      TDBXDataTypes.WideStringType:
        Result := pValue.AsString.ToUInt8;
      TDBXDataTypes.SingleType:
        Result := pValue.AsSingle.Trunc;
      TDBXDataTypes.Int8Type:
        Result := pValue.AsInt8;
      TDBXDataTypes.UInt8Type:
        Result := pValue.AsUInt8;
    else
      raise EAqInternal.Create('Unexpectet type when trying to obtain an UInt8 field.');
    end;
  end;
end;

procedure TAqDBXDataConverter.BooleanToParameter(const pParameter: TDBXParameter; const pValue: Boolean);
begin
  pParameter.DataType := TDBXDataTypes.BooleanType;
  pParameter.Value.SetBoolean(pValue);
end;

procedure TAqDBXDataConverter.CurrencyToParameter(const pParameter: TDBXParameter; const pValue: Currency);
begin
  BCDToParameter(pParameter, pValue.ToBcd);
end;

procedure TAqDBXDataConverter.DateToParameter(const pParameter: TDBXParameter; const pValue: TDate);
begin
  pParameter.DataType := TDBXDataTypes.DateType;
  pParameter.Value.AsDateTime := DateOf(pValue);
end;

procedure TAqDBXDataConverter.DateTimeToParameter(const pParameter: TDBXParameter; const pValue: TDateTime);
begin
  pParameter.DataType := TDBXDataTypes.TimeStampType;
  pParameter.Value.AsDateTime := pValue;
end;

procedure TAqDBXDataConverter.DoubleToParameter(const pParameter: TDBXParameter; const pValue: Double);
begin
  pParameter.DataType := TDBXDataTypes.DoubleType;
  pParameter.Value.SetDouble(pValue);
end;

procedure TAqDBXDataConverter.Int16ToParameter(const pParameter: TDBXParameter; const pValue: Int16);
begin
  pParameter.DataType := TDBXDataTypes.Int16Type;
  pParameter.Value.SetInt16(pValue);
end;

procedure TAqDBXDataConverter.Int32ToParameter(const pParameter: TDBXParameter; const pValue: Int32);
begin
  pParameter.DataType := TDBXDataTypes.Int32Type;
  pParameter.Value.SetInt32(pValue);
end;

procedure TAqDBXDataConverter.Int64ToParameter(const pParameter: TDBXParameter; const pValue: Int64);
begin
  pParameter.DataType := TDBXDataTypes.Int64Type;
  pParameter.Value.SetInt64(pValue);
end;

procedure TAqDBXDataConverter.Int8ToParameter(const pParameter: TDBXParameter; const pValue: Int8);
begin
  pParameter.DataType := TDBXDataTypes.Int32Type;
  pParameter.Value.SetInt32(pValue);
end;

procedure TAqDBXDataConverter.SingleToParameter(const pParameter: TDBXParameter; const pValue: Single);
begin
  raise EAqInternal.Create('The type Single wasn''t mapped in the DBX Framework.');
end;

procedure TAqDBXDataConverter.StringToParameter(const pParameter: TDBXParameter; const pValue: string);
begin
  pParameter.DataType := TDBXDataTypes.WideStringType;
  pParameter.Value.SetString(pValue);
end;

procedure TAqDBXDataConverter.TimeToParameter(const pParameter: TDBXParameter; const pValue: TTime);
begin
  pParameter.DataType := TDBXDataTypes.TimeType;
  pParameter.Value.AsDateTime := TimeOf(pValue);
end;

procedure TAqDBXDataConverter.TimeStampOffsetToParameter(const pParameter: TDBXParameter;
  const pValue: TSQLTimeStampOffset);
begin
  pParameter.DataType := TDBXDataTypes.TimeStampOffsetType;
  pParameter.Value.SetTimeStampOffset(pValue);
end;

procedure TAqDBXDataConverter.TimeStampToParameter(const pParameter: TDBXParameter; const pValue: TSQLTimeStamp);
begin
  pParameter.DataType := TDBXDataTypes.TimeStampType;
  pParameter.Value.SetTimeStamp(pValue);
end;

procedure TAqDBXDataConverter.UInt16ToParameter(const pParameter: TDBXParameter; const pValue: UInt16);
begin
  pParameter.DataType := TDBXDataTypes.UInt16Type;
  pParameter.Value.SetUInt16(pValue);
end;

procedure TAqDBXDataConverter.UInt32ToParameter(const pParameter: TDBXParameter; const pValue: UInt32);
begin
  pParameter.DataType := TDBXDataTypes.Int64Type;
  pParameter.Value.SetInt64(pValue);
end;

procedure TAqDBXDataConverter.UInt64ToParameter(const pParameter: TDBXParameter; const pValue: UInt64);
begin
  raise EAqInternal.Create('Type UInt64 wasn''t mapped in the DBX Framework.');
end;

procedure TAqDBXDataConverter.UInt8ToParameter(const pParameter: TDBXParameter; const pValue: UInt8);
begin
  pParameter.DataType := TDBXDataTypes.UInt8Type;
  pParameter.Value.SetUInt8(pValue);
end;

{ TAqDBXCommand }

function TAqDBXCommand.Open(const pParametersHandler: TAqDBParametersHandlerMethod): TAqDBXReader;
begin
  if Assigned(pParametersHandler) then
  begin
    pParametersHandler(FParameters);
  end;

  Result := TAqDBXReader.Create(FConnection, Self);
end;

constructor TAqDBXCommand.Create(const pConnection: TAqDBXCustomConnection; const pDBXCommand: TDBXCommand);
begin
  FConnection := pConnection;
  FDBXCommand := pDBXCommand;
  FParameters := TAqDBXParameters.Create(FConnection, FDBXCommand);
end;

destructor TAqDBXCommand.Destroy;
begin
  FParameters.Free;
  FDBXCommand.Free;

  inherited;
end;

function TAqDBXCommand.Execute(const pParametersHandler: TAqDBParametersHandlerMethod): Int64;
begin
  if Assigned(pParametersHandler) then
  begin
    pParametersHandler(FParameters);
  end;

  FDBXCommand.ExecuteUpdate;
  Result := FDBXCommand.RowsAffected;
end;

procedure TAqDBXCommand.Prepare(const pParametersInitializer: TAqDBParametersHandlerMethod);
begin
  if Assigned(pParametersInitializer) then
  begin
    pParametersInitializer(FParameters);
  end;

  FPrepared := True;
end;

{ TAqDBXConnection }

function TAqDBXConnection.GetAutoIncrement(const pGeneratorName: string): Int64;
begin
  if Assigned(FGetterAutoIncrement) then
  begin
    Result := FGetterAutoIncrement;
  end else begin
    Result := inherited;
  end;
end;

{ TAqDBXAdapter }

constructor TAqDBXAdapter.Create;
begin
  inherited;

  SetDBXConverter(CreateConverter);
end;

function TAqDBXAdapter.CreateConverter: TAqDBXDataConverter;
begin
  Result := GetDefaultConverter.Create;
end;

destructor TAqDBXAdapter.Destroy;
begin
  FDBXConverter.Free;

  inherited;
end;

class function TAqDBXAdapter.GetDefaultConverter: TAqDBXDataConverterClass;
begin
  Result := TAqDBXDataConverter;
end;

procedure TAqDBXAdapter.SetDBXConverter(const pValue: TAqDBXDataConverter);
begin
  FreeAndNil(FDBXConverter);
  FDBXConverter := pValue;
end;

end.
