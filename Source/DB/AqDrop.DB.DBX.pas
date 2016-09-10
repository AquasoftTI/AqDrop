unit AqDrop.DB.DBX;

interface

uses
  System.Rtti,
  Data.DBXCommon,
  Data.SqlTimSt,
  Data.FmtBcd,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Collections,
  AqDrop.Core.AnonymousMethods,
  AqDrop.Core.Types,
  AqDrop.DB.Connection,
  AqDrop.DB.Types;

type
  TAqDBXMapper = class(TAqDBMapper)
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
    function Abrir(const pParametersHandler: TAqDBParametersHandlerMethod): TAqDBXReader;

    procedure Prepare;

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
    FTransactionCalls: UInt32;
    FProperties: TDBXProperties;
    FPreparedQueries: TAqIDDictionary<TAqDBXCommand>;

    function CreateCommand: TAqDBXCommand;
    function PrepareDBXCommand(pSQL: string): TAqDBXCommand;

    function GetProperty(pName: string): string;
    procedure SetProperty(pName: string; const pValue: string);
  strict protected
    procedure DoConnect; override;
    procedure DoDisconnect; override;

    function GetPropertyValueAsString(const pIndex: Int32): string; virtual;
    procedure SetPropertyValueAsString(const pIndex: Int32; const pValue: string); virtual;

    function GetActive: Boolean; override;
    function GetInTransaction: Boolean; override;

    function DoPrepareCommand(const pSQL: string): TAqID; override;
    procedure DoUnprepareCommand(const pCommandID: TAqID); override;

    function DoExecuteCommand(const pSQL: string;
      const pParametersHandler: TAqDBParametersHandlerMethod): Int64; override;
    function DoExecuteCommand(const pCommandID: TAqID;
      const pParametersHandler: TAqDBParametersHandlerMethod): Int64; override;

    function DoOpenQuery(const pSQL: string;
      const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader; override;
    function DoOpenQuery(const pCommandID: TAqID;
      const pParametersHandler: TAqDBParametersHandlerMethod): IAqDBReader; override;

    procedure SetMapper(const pMapper: TAqDBMapper); override;
    procedure SetDBXMapper(const pMapper: TAqDBXMapper); virtual;
    function GetDBXMapper: TAqDBXMapper; virtual;

    procedure DoStartTransaction; override;
    procedure DoCommitTransaction; override;
    procedure DoRollbackTransaction; overload; override;

    property DriverName: string index $00 read GetPropertyValueAsString write SetPropertyValueAsString;
    property VendorLib: string index $01 read GetPropertyValueAsString write SetPropertyValueAsString;
    property LibraryName: string index $02 read GetPropertyValueAsString write SetPropertyValueAsString;
    property GetDriverFunc: string index $03 read GetPropertyValueAsString write SetPropertyValueAsString;

    property Properties[Name: string]: string read GetProperty write SetProperty;

    class function GetDefaultMapper: TAqDBMapperClass; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure RollbackTransaction(const pRegardTransactionCalls: Boolean); reintroduce; overload;

    property DBXMapper: TAqDBXMapper read GetDBXMapper write SetDBXMapper;
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
    FGetterAutoIncrement: TAqAnonymousFunction<Int64>;
  public
    function GetAutoIncrement(const pGenerator: string = ''): Int64; override;

    property DriverName;
    property VendorLib;
    property LibraryName;
    property GetDriverFunc;
    property Properties;

    property GetterAutoIncrement: TAqAnonymousFunction<Int64> read FGetterAutoIncrement write FGetterAutoIncrement;
  end;

implementation

uses
  System.SysUtils,
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
      E.RaiseOuterException(EAqFriendly.Create('It wasn''t possible to stablish a connection to the DB.'));
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
  FPreparedQueries.Free;
  FDBXConnection.Free;
  FProperties.Free;

  inherited;
end;

function TAqDBXCustomConnection.GetDBXMapper: TAqDBXMapper;
begin
  Result := TAqDBXMapper(inherited Mapper);
end;

class function TAqDBXCustomConnection.GetDefaultMapper: TAqDBMapperClass;
begin
  Result := TAqDBXMapper;
end;

function TAqDBXCustomConnection.GetProperty(pName: string): string;
begin
  Result := FProperties.Values[pName];
end;

function TAqDBXCustomConnection.GetActive: Boolean;
begin
  Result := Assigned(FDBXConnection);
end;

function TAqDBXCustomConnection.GetInTransaction: Boolean;
begin
  Result := Assigned(FDBXTransaction);
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

procedure TAqDBXCustomConnection.SetMapper(const pMapper: TAqDBMapper);
begin
  if not (pMapper is TAqDBXMapper) then
  begin
    raise EAqInternal.Create('Mapper not suported.');
  end;

  inherited;
end;

procedure TAqDBXCustomConnection.SetDBXMapper(const pMapper: TAqDBXMapper);
begin
  SetMapper(pMapper);
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
    Result := lCommand.Abrir(pParametersHandler);
  end else begin
    raise EAqInternal.Create('Command of Index ' + pCommandID.ToString + ' not found.');
  end;
end;

procedure TAqDBXCustomConnection.DoStartTransaction;
begin
  inherited;

  if FTransactionCalls = 0 then
  begin
    FDBXTransaction := FDBXConnection.BeginTransaction;
  end;

  Inc(FTransactionCalls);
end;

procedure TAqDBXCustomConnection.DoCommitTransaction;
begin
  if FTransactionCalls = 0 then
  begin
    raise EAqInternal.Create('There is no transaction to commit.');
  end;

  Dec(FTransactionCalls);

  if FTransactionCalls = 0 then
  begin
    FDBXConnection.CommitFreeAndNil(FDBXTransaction);
  end;

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

function TAqDBXCustomConnection.DoPrepareCommand(const pSQL: string): TAqID;
var
  lCommand: TAqDBXCommand;
begin
  lCommand := nil;

  try
    lCommand := PrepareDBXCommand(pSQL);
    lCommand.Prepare;
    Result := FPreparedQueries.Add(lCommand);
  except
    lCommand.Free;
    raise;
  end;
end;

procedure TAqDBXCustomConnection.DoRollbackTransaction;
begin
  RollbackTransaction(True);

  inherited;
end;

procedure TAqDBXCustomConnection.RollbackTransaction(const pRegardTransactionCalls: Boolean);
begin
  if FTransactionCalls = 0 then
  begin
    raise EAqInternal.Create('There are no transaction to revert.');
  end;

  if not pRegardTransactionCalls or (FTransactionCalls = 1) then
  begin
    FDBXConnection.RollbackFreeAndNil(FDBXTransaction);
    FTransactionCalls := 0;
  end else begin
    Dec(FTransactionCalls);
  end;
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
  Result := Values.Connction.DBXMapper.DBToAnsiString(GetValue);
end;

function TAqDBXBaseValue.GetAsBCD: TBcd;
begin
  Result := Values.Connction.DBXMapper.DBToBCD(GetValue);
end;

function TAqDBXBaseValue.GetAsBoolean: Boolean;
begin
  Result := Values.Connction.DBXMapper.DBToBoolean(GetValue);
end;

function TAqDBXBaseValue.GetAsCurrency: Currency;
begin
  Result := Values.Connction.DBXMapper.DBToCurrency(GetValue);
end;

function TAqDBXBaseValue.GetAsDate: TDate;
begin
  Result := Values.Connction.DBXMapper.DBToDate(GetValue);
end;

function TAqDBXBaseValue.GetAsDateTime: TDateTime;
begin
  Result := Values.Connction.DBXMapper.DBToDateTime(GetValue);
end;

function TAqDBXBaseValue.GetAsDouble: Double;
begin
  Result := Values.Connction.DBXMapper.DBToDouble(GetValue);
end;

function TAqDBXBaseValue.GetAsInt16: Int16;
begin
  Result := Values.Connction.DBXMapper.DBToInt16(GetValue);
end;

function TAqDBXBaseValue.GetAsInt32: Int32;
begin
  Result := Values.Connction.DBXMapper.DBToInt32(GetValue);
end;

function TAqDBXBaseValue.GetAsInt64: Int64;
begin
  Result := Values.Connction.DBXMapper.DBToInt64(GetValue);
end;

function TAqDBXBaseValue.GetAsInt8: Int8;
begin
  Result := Values.Connction.DBXMapper.DBToInt8(GetValue);
end;

function TAqDBXBaseValue.GetAsSingle: Single;
begin
  Result := Values.Connction.DBXMapper.DBToSingle(GetValue);
end;

function TAqDBXBaseValue.GetAsString: string;
begin
  Result := Values.Connction.DBXMapper.DBToString(GetValue);
end;

function TAqDBXBaseValue.GetAsTime: TTime;
begin
  Result := Values.Connction.DBXMapper.DBToTime(GetValue);
end;

function TAqDBXBaseValue.GetAsTimeStamp: TSQLTimeStamp;
begin
  Result := Values.Connction.DBXMapper.DBToTimeStamp(GetValue);
end;

function TAqDBXBaseValue.GetAsTimeStampOffset: TSQLTimeStampOffset;
begin
  Result := Values.Connction.DBXMapper.DBToTimeStampOffset(GetValue);
end;

function TAqDBXBaseValue.GetAsUInt16: UInt16;
begin
  Result := Values.Connction.DBXMapper.DBToUInt16(GetValue);
end;

function TAqDBXBaseValue.GetAsUInt32: UInt32;
begin
  Result := Values.Connction.DBXMapper.DBToUInt32(GetValue);
end;

function TAqDBXBaseValue.GetAsUInt64: UInt64;
begin
  Result := Values.Connction.DBXMapper.DBToUInt64(GetValue);
end;

function TAqDBXBaseValue.GetAsUInt8: UInt8;
begin
  Result := Values.Connction.DBXMapper.DBToUInt8(GetValue);
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
  Values.Connction.DBXMapper.AnsiStringToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsBCD(const pValue: TBcd);
begin
  Values.Connction.DBXMapper.BCDToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsBoolean(const pValue: Boolean);
begin
  Values.Connction.DBXMapper.BooleanToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsCurrency(const pValue: Currency);
begin
  Values.Connction.DBXMapper.CurrencyToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsDate(const pValue: TDate);
begin
  Values.Connction.DBXMapper.DateToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsDateTime(const pValue: TDateTime);
begin
  Values.Connction.DBXMapper.DateTimeToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsDouble(const pValue: Double);
begin
  Values.Connction.DBXMapper.DoubleToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsInt16(const pValue: Int16);
begin
  Values.Connction.DBXMapper.Int16ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsInt32(const pValue: Int32);
begin
  Values.Connction.DBXMapper.Int32ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsInt64(const pValue: Int64);
begin
  Values.Connction.DBXMapper.Int64ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsInt8(const pValue: Int8);
begin
  Values.Connction.DBXMapper.Int8ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsSingle(const pValue: Single);
begin
  Values.Connction.DBXMapper.SingleToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsString(const pValue: string);
begin
  Values.Connction.DBXMapper.StringToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsTime(const pValue: TTime);
begin
  Values.Connction.DBXMapper.TimeToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsTimeStamp(const pValue: TSQLTimeStamp);
begin
  Values.Connction.DBXMapper.TimeStampToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsTimeStampOffset(const pValue: TSQLTimeStampOffset);
begin
  Values.Connction.DBXMapper.TimeStampOffsetToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsUInt16(const pValue: UInt16);
begin
  Values.Connction.DBXMapper.UInt16ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsUInt32(const pValue: UInt32);
begin
  Values.Connction.DBXMapper.UInt32ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsUInt64(const pValue: UInt64);
begin
  Values.Connction.DBXMapper.UInt64ToParameter(FDBXParameter, pValue);
end;

procedure TAqDBXParameter.SetAsUInt8(const pValue: UInt8);
begin
  Values.Connction.DBXMapper.UInt8ToParameter(FDBXParameter, pValue);
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

{ TAqDBXMapper }

procedure TAqDBXMapper.AnsiStringToParameter(const pParameter: TDBXParameter;
  const pValue: AnsiString);
begin
  pParameter.DataType := TDBXDataTypes.AnsiStringType;
  pParameter.Value.SetAnsiString(pValue);
end;

procedure TAqDBXMapper.BCDToParameter(const pParameter: TDBXParameter; const pValue: TBcd);
begin
  pParameter.DataType := TDBXDataTypes.BcdType;
  pParameter.Value.SetBcd(pValue);
end;

function TAqDBXMapper.DBToAnsiString(const pValue: TDBXValue): AnsiString;
begin
  case pValue.ValueType.DataType of
    TDBXDataTypes.AnsiStringType:
      Result := pValue.GetAnsiString;
  else
    Result := AnsiString(DBToString(pValue));
  end;
end;

function TAqDBXMapper.DBToBCD(const pValue: TDBXValue): TBcd;
begin
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

function TAqDBXMapper.DBToBoolean(const pValue: TDBXValue): Boolean;
begin
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

function TAqDBXMapper.DBToCurrency(const pValue: TDBXValue): Currency;
begin
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

function TAqDBXMapper.DBToDate(const pValue: TDBXValue): TDate;
var
  lTimeStamp: TSQLTimeStamp;
begin
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

function TAqDBXMapper.DBToDateTime(const pValue: TDBXValue): TDateTime;
var
  lTimeStamp: TSQLTimeStamp;
begin
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

function TAqDBXMapper.DBToDouble(const pValue: TDBXValue): Double;
begin
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

function TAqDBXMapper.DBToInt16(const pValue: TDBXValue): Int16;
begin
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

function TAqDBXMapper.DBToInt32(const pValue: TDBXValue): Int32;
begin
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

function TAqDBXMapper.DBToInt64(const pValue: TDBXValue): Int64;
begin
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

function TAqDBXMapper.DBToInt8(const pValue: TDBXValue): Int8;
begin
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

function TAqDBXMapper.DBToSingle(const pValue: TDBXValue): Single;
begin
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

function TAqDBXMapper.DBToString(const pValue: TDBXValue): string;
begin
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

function TAqDBXMapper.DBToTime(const pValue: TDBXValue): TTime;
var
  lTimeStamp: TSQLTimeStamp;
begin
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

function TAqDBXMapper.DBToTimeStamp(const pValue: TDBXValue): TSQLTimeStamp;
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

function TAqDBXMapper.DBToTimeStampOffset(const pValue: TDBXValue): TSQLTimeStampOffset;
begin
  case pValue.ValueType.DataType of
    TDBXDataTypes.TimeStampOffsetType:
      Result := pValue.GetTimeStampOffset;
  else
    raise EAqInternal.Create('Unexpectet type when trying to obtain a TimeStampOffset field.');
  end;
end;

function TAqDBXMapper.DBToUInt16(const pValue: TDBXValue): UInt16;
begin
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

function TAqDBXMapper.DBToUInt32(const pValue: TDBXValue): UInt32;
begin
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

function TAqDBXMapper.DBToUInt64(const pValue: TDBXValue): UInt64;
begin
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

function TAqDBXMapper.DBToUInt8(const pValue: TDBXValue): UInt8;
begin
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

procedure TAqDBXMapper.BooleanToParameter(const pParameter: TDBXParameter; const pValue: Boolean);
begin
  pParameter.DataType := TDBXDataTypes.BooleanType;
  pParameter.Value.SetBoolean(pValue);
end;

procedure TAqDBXMapper.CurrencyToParameter(const pParameter: TDBXParameter; const pValue: Currency);
begin
  BCDToParameter(pParameter, pValue.ToBcd);
end;

procedure TAqDBXMapper.DateToParameter(const pParameter: TDBXParameter; const pValue: TDate);
begin
  pParameter.DataType := TDBXDataTypes.DateType;
  pParameter.Value.AsDateTime := DateOf(pValue);
end;

procedure TAqDBXMapper.DateTimeToParameter(const pParameter: TDBXParameter; const pValue: TDateTime);
begin
  pParameter.DataType := TDBXDataTypes.TimeStampType;
  pParameter.Value.AsDateTime := pValue;
end;

procedure TAqDBXMapper.DoubleToParameter(const pParameter: TDBXParameter; const pValue: Double);
begin
  pParameter.DataType := TDBXDataTypes.DoubleType;
  pParameter.Value.SetDouble(pValue);
end;

procedure TAqDBXMapper.Int16ToParameter(const pParameter: TDBXParameter; const pValue: Int16);
begin
  pParameter.DataType := TDBXDataTypes.Int16Type;
  pParameter.Value.SetInt16(pValue);
end;

procedure TAqDBXMapper.Int32ToParameter(const pParameter: TDBXParameter; const pValue: Int32);
begin
  pParameter.DataType := TDBXDataTypes.Int32Type;
  pParameter.Value.SetInt32(pValue);
end;

procedure TAqDBXMapper.Int64ToParameter(const pParameter: TDBXParameter; const pValue: Int64);
begin
  pParameter.DataType := TDBXDataTypes.Int64Type;
  pParameter.Value.SetInt64(pValue);
end;

procedure TAqDBXMapper.Int8ToParameter(const pParameter: TDBXParameter; const pValue: Int8);
begin
  pParameter.DataType := TDBXDataTypes.Int8Type;
  pParameter.Value.SetInt8(pValue);
end;

procedure TAqDBXMapper.SingleToParameter(const pParameter: TDBXParameter; const pValue: Single);
begin
  raise EAqInternal.Create('The type Single wasn''t mapped in the DBX Framework.');
end;

procedure TAqDBXMapper.StringToParameter(const pParameter: TDBXParameter; const pValue: string);
begin
  pParameter.DataType := TDBXDataTypes.WideStringType;
  pParameter.Value.SetString(pValue);
end;

procedure TAqDBXMapper.TimeToParameter(const pParameter: TDBXParameter; const pValue: TTime);
begin
  pParameter.DataType := TDBXDataTypes.TimeType;
  pParameter.Value.AsDateTime := TimeOf(pValue);
end;

procedure TAqDBXMapper.TimeStampOffsetToParameter(const pParameter: TDBXParameter;
  const pValue: TSQLTimeStampOffset);
begin
  pParameter.DataType := TDBXDataTypes.TimeStampOffsetType;
  pParameter.Value.SetTimeStampOffset(pValue);
end;

procedure TAqDBXMapper.TimeStampToParameter(const pParameter: TDBXParameter; const pValue: TSQLTimeStamp);
begin
  pParameter.DataType := TDBXDataTypes.TimeStampType;
  pParameter.Value.SetTimeStamp(pValue);
end;

procedure TAqDBXMapper.UInt16ToParameter(const pParameter: TDBXParameter; const pValue: UInt16);
begin
  pParameter.DataType := TDBXDataTypes.UInt16Type;
  pParameter.Value.SetUInt16(pValue);
end;

procedure TAqDBXMapper.UInt32ToParameter(const pParameter: TDBXParameter; const pValue: UInt32);
begin
  pParameter.DataType := TDBXDataTypes.Int64Type;
  pParameter.Value.SetInt64(pValue);
end;

procedure TAqDBXMapper.UInt64ToParameter(const pParameter: TDBXParameter; const pValue: UInt64);
begin
  raise EAqInternal.Create('Type UInt64 wasn''t mapped in the DBX Framework.');
end;

procedure TAqDBXMapper.UInt8ToParameter(const pParameter: TDBXParameter; const pValue: UInt8);
begin
  pParameter.DataType := TDBXDataTypes.UInt8Type;
  pParameter.Value.SetUInt8(pValue);
end;

{ TAqDBXCommand }

function TAqDBXCommand.Abrir(const pParametersHandler: TAqDBParametersHandlerMethod): TAqDBXReader;
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

procedure TAqDBXCommand.Prepare;
begin
  FPrepared := True;
end;

{ TAqDBXConnection }

function TAqDBXConnection.GetAutoIncrement(const pGenerator: string): Int64;
begin
  if Assigned(FGetterAutoIncrement) then
  begin
    Result := FGetterAutoIncrement;
  end else begin
    Result := 0;
  end;
end;

end.
