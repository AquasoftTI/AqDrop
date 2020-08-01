unit AqDrop.Core.Generics.Converters;

interface

uses
  System.SysUtils,
  System.TypInfo,
  System.Rtti,
  AqDrop.Core.Collections.Intf;

type
  TAqTypeConverter = class
  strict protected
    function DoExecute(const pFrom: TValue): TValue; virtual; abstract;
  public
    function Execute(const pFrom: TValue): TValue;
  end;

  TAqTypeConverterByMethod<TFrom, TTo> = class(TAqTypeConverter)
  strict private
    FConverter: TFunc<TFrom, TTo>;
  strict protected
    function DoExecute(const pFrom: TValue): TValue; override;
  public
    constructor Create(const pConverter: TFunc<TFrom, TTo>);
  end;

  TAqTypeConverters = class
  strict private
    FConverters: IAqDictionary<string, TAqTypeConverter>;

    function GetStrTypeInfo(pType: PTypeInfo): string;
    function GetDictionaryKey(const pFromType, pToType: PTypeInfo): string; overload;
    function GetDictionaryKey<TFrom, TTo>: string; overload;

    class var FDefaultInstance: TAqTypeConverters;
    class function GetDefaultInstance: TAqTypeConverters; static;
  public
    constructor Create;

    procedure RegisterConverter<TFrom, TTo>(const pConverter: TFunc<TFrom, TTo>);

    function HasConverter(const pFromType, pToType: PTypeInfo): Boolean; overload;
    function HasConverter<TFrom, TTo>: Boolean; overload;
    function HasConverter<TTo>(const pFrom: TValue): Boolean; overload;

    function TryConvert(const pFrom: TValue; const pToType: PTypeInfo; out pValue: TValue): Boolean; overload;
    function TryConvert<TTo>(const pFrom: TValue; out pValue: TTo): Boolean; overload;
    function TryConvert<TFrom, TTo>(const pFrom: TFrom; out pValue: TTo): Boolean; overload;

    function Convert(const pFrom: TValue; const pToType: PTypeInfo): TValue; overload;
    function Convert<TTo>(const pFrom: TValue): TTo; overload;
    function Convert<TFrom, TTo>(const pFrom: TFrom): TTo; overload;

    {$region 'register standard converters'}
    procedure RegisterConvertersFromString;
    procedure RegisterConvertersFromBoolean;
    procedure RegisterConvertersFromUInt8;
    procedure RegisterConvertersFromInt8;
    procedure RegisterConvertersFromUInt16;
    procedure RegisterConvertersFromInt16;
    procedure RegisterConvertersFromUInt32;
    procedure RegisterConvertersFromInt32;
    procedure RegisterConvertersFromUInt64;
    procedure RegisterConvertersFromInt64;
    procedure RegisterConvertersFromEntityID;
    procedure RegisterConvertersFromDouble;
    procedure RegisterConvertersFromCurrency;
    procedure RegisterConvertersFromDateTime;
    procedure RegisterConvertersFromDate;
    procedure RegisterConvertersFromTime;

    procedure RegisterMinorStandarConverters;

    procedure RegisterStandardConverters;
    {$endregion}

    class procedure InitializeDefaultInstance;
    class procedure ReleaseDefaultInstance;

    class property Default: TAqTypeConverters read GetDefaultInstance;
  end;

implementation

uses
  System.Math,
  System.StrUtils,
  System.Variants,
  AqDrop.Core.Types,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Collections,
  AqDrop.Core.Helpers;

{ TAqTypeConverter }

function TAqTypeConverter.Execute(const pFrom: TValue): TValue;
begin
  Result := DoExecute(pFrom);
end;

{ TAqTypeConverters }

function TAqTypeConverters.Convert(const pFrom: TValue; const pToType: PTypeInfo): TValue;
begin
  if not TryConvert(pFrom, pToType, Result) then
  begin
    raise EAqInternal.CreateFmt('Converter not found (%s := %s).', [
      GetTypeName(pToType),
      GetTypeName(pFrom.TypeInfo)]);
  end;
end;

function TAqTypeConverters.Convert<TFrom, TTo>(const pFrom: TFrom): TTo;
begin
  Result := Convert<TTo>(TValue.From<TFrom>(pFrom));
end;

function TAqTypeConverters.Convert<TTo>(const pFrom: TValue): TTo;
begin
  Result := Convert(pFrom, TypeInfo(TTo)).AsType<TTo>;
end;

constructor TAqTypeConverters.Create;
begin
  FConverters := TAqDictionary<string, TAqTypeConverter>.Create([kvoValue], TAqLockerType.lktMultiReaderExclusiveWriter);
end;

class function TAqTypeConverters.GetDefaultInstance: TAqTypeConverters;
begin
  InitializeDefaultInstance;

  Result := FDefaultInstance;
end;

function TAqTypeConverters.GetDictionaryKey(const pFromType, pToType: PTypeInfo): string;
begin
  Result := GetStrTypeInfo(pFromType) + '|' + GetStrTypeInfo(pToType);
end;

function TAqTypeConverters.GetDictionaryKey<TFrom, TTo>: string;
begin
  Result := GetDictionaryKey(TypeInfo(TFrom), TypeInfo(TTo));
end;

function TAqTypeConverters.GetStrTypeInfo(pType: PTypeInfo): string;
begin
  Result := IntToHex(NativeInt(pType), 2);
end;

function TAqTypeConverters.HasConverter(const pFromType, pToType: PTypeInfo): Boolean;
begin
  Result := FConverters.LockAndCheckIfContainsKey(GetDictionaryKey(pFromType, pToType));
end;

function TAqTypeConverters.HasConverter<TFrom, TTo>: Boolean;
begin
  Result := HasConverter(TypeInfo(TFrom), TypeInfo(TTo));
end;

function TAqTypeConverters.HasConverter<TTo>(const pFrom: TValue): Boolean;
begin
  Result := HasConverter(pFrom.TypeInfo, TypeInfo(TTo));
end;

class procedure TAqTypeConverters.InitializeDefaultInstance;
begin
  if not Assigned(FDefaultInstance) then
  begin
    FDefaultInstance := TAqTypeConverters.Create;
  end;
end;

procedure TAqTypeConverters.RegisterConverter<TFrom, TTo>(const pConverter: TFunc<TFrom, TTo>);
begin
  FConverters.LockAndAddOrSetValue(GetDictionaryKey<TFrom, TTo>,
    TAqTypeConverterByMethod<TFrom,TTo>.Create(pConverter));
end;

procedure TAqTypeConverters.RegisterConvertersFromBoolean;
begin
  RegisterConverter<Boolean, string>(
    function(pValue: Boolean): string
    begin
      Result := pValue.ToString;
    end);
  RegisterConverter<Boolean, Boolean>(
    function(pValue: Boolean): Boolean
    begin
      Result := pValue;
    end);
  RegisterConverter<Boolean, UInt8>(
    function(pValue: Boolean): UInt8
    begin
      Result := pValue.ToInt8;
    end);
  RegisterConverter<Boolean, Int8>(
    function(pValue: Boolean): Int8
    begin
      Result := pValue.ToInt8;
    end);
  RegisterConverter<Boolean, UInt16>(
    function(pValue: Boolean): UInt16
    begin
      Result := pValue.ToInt8;
    end);
  RegisterConverter<Boolean, Int16>(
    function(pValue: Boolean): Int16
    begin
      Result := pValue.ToInt8;
    end);
  RegisterConverter<Boolean, UInt32>(
    function(pValue: Boolean): UInt32
    begin
      Result := pValue.ToInt32;
    end);
  RegisterConverter<Boolean, Int32>(
    function(pValue: Boolean): Int32
    begin
      Result := pValue.ToInt32;
    end);
  RegisterConverter<Boolean, UInt64>(
    function(pValue: Boolean): UInt64
    begin
      Result := pValue.ToInt32;
    end);
  RegisterConverter<Boolean, Int64>(
    function(pValue: Boolean): Int64
    begin
      Result := pValue.ToInt32;
    end);
  RegisterConverter<Boolean, TAqEntityID>(
    function(pValue: Boolean): TAqEntityID
    begin
      Result := pValue.ToInt32;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromCurrency;
begin
  RegisterConverter<Currency, string>(
    function(pValue: Currency): string
    begin
{$IF CompilerVersion >= 29} // bug no XE7
      Result := pValue.ToString;
{$ELSE}
      Result := CurrToStr(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, UInt8>(
    function(pValue: Currency): UInt8
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, Int8>(
    function(pValue: Currency): Int8
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, UInt16>(
    function(pValue: Currency): UInt16
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, Int16>(
    function(pValue: Currency): Int16
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, UInt32>(
    function(pValue: Currency): UInt32
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, Int32>(
    function(pValue: Currency): Int32
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, UInt64>(
    function(pValue: Currency): UInt64
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, Int64>(
    function(pValue: Currency): Int64
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, TAqEntityID>(
    function(pValue: Currency): TAqEntityID
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Currency, Double>(
    function(pValue: Currency): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<Currency, Currency>(
    function(pValue: Currency): Currency
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromDate;
begin
  RegisterConverter<TDate, string>(
    function(pValue: TDate): string
    begin
{$IF CompilerVersion >= 29} // bug no XE7
      Result := pValue.ToString;
{$ELSE}
      Result := DateToStr(pValue);
{$ENDIF}
    end);
  RegisterConverter<TDate, Double>(
    function(pValue: TDate): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<TDate, TDateTime>(
    function(pValue: TDate): TDateTime
    begin
      Result := pValue;
    end);
  RegisterConverter<TDate, TDate>(
    function(pValue: TDate): TDate
    begin
      Result := pValue;
    end);
  RegisterConverter<TDate, Variant>(
    function(pValue: TDate): Variant
    begin
      if pValue = 0 then
      begin
        Result := System.Variants.Null;
      end else
      begin
        Result := pValue;
      end;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromDateTime;
begin
  RegisterConverter<TDateTime, string>(
    function(pValue: TDateTime): string
    begin
{$IF CompilerVersion >= 29} // bug no XE7
      Result := pValue.ToString;
{$ELSE}
      Result := DateTimeToStr(pValue);
{$ENDIF}
    end);
  RegisterConverter<TDateTime, Double>(
    function(pValue: TDateTime): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<TDateTime, TDateTime>(
    function(pValue: TDateTime): TDateTime
    begin
      Result := pValue;
    end);
  RegisterConverter<TDateTime, TDate>(
    function(pValue: TDateTime): TDate
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.DateOf;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<TDateTime, TTime>(
    function(pValue: TDateTime): TTime
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.TimeOf;
{$ELSE}
      Result := System.Frac(pValue);
{$ENDIF}
    end);
  RegisterConverter<TDateTime, Variant>(
    function(pValue: TDateTime): Variant
    begin
      if pValue = 0 then
      begin
        Result := System.Variants.Null;
      end else
      begin
        Result := pValue;
      end;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromDouble;
begin
  RegisterConverter<Double, string>(
    function(pValue: Double): string
    begin
{$IF CompilerVersion >= 29} // bug no XE7
      Result := pValue.ToString;
{$ELSE}
      Result := FloatToStr(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, UInt8>(
    function(pValue: Double): UInt8
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, Int8>(
    function(pValue: Double): Int8
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, UInt16>(
    function(pValue: Double): UInt16
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, Int16>(
    function(pValue: Double): Int16
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, UInt32>(
    function(pValue: Double): UInt32
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, Int32>(
    function(pValue: Double): Int32
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, UInt64>(
    function(pValue: Double): UInt64
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, Int64>(
    function(pValue: Double): Int64
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, TAqEntityID>(
    function(pValue: Double): TAqEntityID
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.Trunc;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, Double>(
    function(pValue: Double): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<Double, Currency>(
    function(pValue: Double): Currency
    begin
      Result := pValue;
    end);
  RegisterConverter<Double, TDateTime>(
    function(pValue: Double): TDateTime
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.ToDateTime;
{$ELSE}
      Result := pValue;
{$ENDIF}
    end);
  RegisterConverter<Double, TDate>(
    function(pValue: Double): TDate
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.ToDateTime.DateOf;
{$ELSE}
      Result := System.Trunc(pValue);
{$ENDIF}
    end);
  RegisterConverter<Double, TTime>(
    function(pValue: Double): TTime
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.ToDateTime.TimeOf;
{$ELSE}
      Result := System.Frac(pValue);
{$ENDIF}
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromEntityID;
begin
  RegisterConverter<TAqEntityID, string>(
    function(pValue: TAqEntityID): string
    begin
{$IF CompilerVersion >= 29} // bug no XE7
      Result := pValue.ToString;
{$ELSE}
      Result := System.StrUtils.IfThen(pValue > 0, IntToStr(pValue));
{$ENDIF}
    end);
  RegisterConverter<TAqEntityID, Boolean>(
    function(pValue: TAqEntityID): Boolean
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.ToBoolean;
{$ELSE}
      Result := pValue <> 0;
{$ENDIF}
    end);
  RegisterConverter<TAqEntityID, UInt8>(
    function(pValue: TAqEntityID): UInt8
    begin
      Result := pValue;
    end);
  RegisterConverter<TAqEntityID, Int8>(
    function(pValue: TAqEntityID): Int8
    begin
      Result := pValue;
    end);
  RegisterConverter<TAqEntityID, UInt16>(
    function(pValue: TAqEntityID): UInt16
    begin
      Result := pValue;
    end);
  RegisterConverter<TAqEntityID, Int16>(
    function(pValue: TAqEntityID): Int16
    begin
      Result := pValue;
    end);
  RegisterConverter<TAqEntityID, UInt32>(
    function(pValue: TAqEntityID): UInt32
    begin
      Result := pValue;
    end);
  RegisterConverter<TAqEntityID, Int32>(
    function(pValue: TAqEntityID): Int32
    begin
      Result := pValue;
    end);
  RegisterConverter<TAqEntityID, UInt64>(
    function(pValue: TAqEntityID): UInt64
    begin
      Result := pValue;
    end);
  RegisterConverter<TAqEntityID, TAqEntityID>(
    function(pValue: TAqEntityID): TAqEntityID
    begin
      Result := pValue;
    end);
  RegisterConverter<TAqEntityID, Double>(
    function(pValue: TAqEntityID): Double
    begin
      Result := System.Math.IfThen(pValue > 0, pValue);
    end);
  RegisterConverter<TAqEntityID, Currency>(
    function(pValue: TAqEntityID): Currency
    begin
      Result := pValue;
    end);
  RegisterConverter<TAqEntityID, Variant>(
    function(pValue: TAqEntityID): Variant
    begin
      if pValue > 0 then
      begin
        Result := pValue;
      end else
      begin
        Result := System.Variants.Null;
      end;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromInt16;
begin
  RegisterConverter<Int16, string>(
    function(pValue: Int16): string
    begin
      Result := pValue.ToString;
    end);
  RegisterConverter<Int16, Boolean>(
    function(pValue: Int16): Boolean
    begin
      Result := pValue.ToBoolean;
    end);
  RegisterConverter<Int16, UInt8>(
    function(pValue: Int16): UInt8
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, Int8>(
    function(pValue: Int16): Int8
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, UInt16>(
    function(pValue: Int16): UInt16
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, Int16>(
    function(pValue: Int16): Int16
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, UInt32>(
    function(pValue: Int16): UInt32
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, Int32>(
    function(pValue: Int16): Int32
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, UInt64>(
    function(pValue: Int16): UInt64
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, Int64>(
    function(pValue: Int16): Int64
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, TAqEntityID>(
    function(pValue: Int16): TAqEntityID
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, Double>(
    function(pValue: Int16): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<Int16, Currency>(
    function(pValue: Int16): Currency
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromInt32;
begin
  RegisterConverter<Int32, string>(
    function(pValue: Int32): string
    begin
      Result := pValue.ToString;
    end);
  RegisterConverter<Int32, Boolean>(
    function(pValue: Int32): Boolean
    begin
      Result := pValue.ToBoolean;
    end);
  RegisterConverter<Int32, UInt8>(
    function(pValue: Int32): UInt8
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, Int8>(
    function(pValue: Int32): Int8
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, UInt16>(
    function(pValue: Int32): UInt16
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, Int16>(
    function(pValue: Int32): Int16
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, UInt32>(
    function(pValue: Int32): UInt32
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, Int32>(
    function(pValue: Int32): Int32
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, UInt64>(
    function(pValue: Int32): UInt64
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, Int64>(
    function(pValue: Int32): Int64
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, TAqEntityID>(
    function(pValue: Int32): TAqEntityID
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, Double>(
    function(pValue: Int32): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<Int32, Currency>(
    function(pValue: Int32): Currency
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromInt64;
begin
  RegisterConverter<Int64, string>(
    function(pValue: Int64): string
    begin
{$IF CompilerVersion >= 29} // bug no XE7
      Result := pValue.ToString;
{$ELSE}
      Result := IntToStr(pValue);
{$ENDIF}
    end);
  RegisterConverter<Int64, Boolean>(
    function(pValue: Int64): Boolean
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.ToBoolean;
{$ELSE}
      Result := pValue <> 0;
{$ENDIF}
    end);
  RegisterConverter<Int64, UInt8>(
    function(pValue: Int64): UInt8
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, Int8>(
    function(pValue: Int64): Int8
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, UInt16>(
    function(pValue: Int64): UInt16
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, Int16>(
    function(pValue: Int64): Int16
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, UInt32>(
    function(pValue: Int64): UInt32
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, Int32>(
    function(pValue: Int64): Int32
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, UInt64>(
    function(pValue: Int64): UInt64
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, Int64>(
    function(pValue: Int64): Int64
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, TAqEntityID>(
    function(pValue: Int64): TAqEntityID
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, Double>(
    function(pValue: Int64): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<Int64, Currency>(
    function(pValue: Int64): Currency
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromInt8;
begin
  RegisterConverter<Int8, string>(
    function(pValue: Int8): string
    begin
      Result := pValue.ToString;
    end);
  RegisterConverter<Int8, Boolean>(
    function(pValue: Int8): Boolean
    begin
      Result := pValue.ToBoolean;
    end);
  RegisterConverter<Int8, UInt8>(
    function(pValue: Int8): UInt8
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, Int8>(
    function(pValue: Int8): Int8
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, UInt16>(
    function(pValue: Int8): UInt16
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, Int16>(
    function(pValue: Int8): Int16
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, UInt32>(
    function(pValue: Int8): UInt32
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, Int32>(
    function(pValue: Int8): Int32
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, UInt64>(
    function(pValue: Int8): UInt64
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, Int64>(
    function(pValue: Int8): Int64
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, TAqEntityID>(
    function(pValue: Int8): TAqEntityID
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, Double>(
    function(pValue: Int8): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<Int8, Currency>(
    function(pValue: Int8): Currency
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromString;
begin
  RegisterConverter<string, Boolean>(
    function(pValue: string): Boolean
    begin
      Result := pValue.ToBoolean;
    end);
  RegisterConverter<string, UInt8>(
    function(pValue: string): UInt8
    begin
      Result := pValue.ToUIntZeroIfEmpty;
    end);
  RegisterConverter<string, Int8>(
    function(pValue: string): Int8
    begin
      Result := pValue.ToIntZeroIfEmpty;
    end);
  RegisterConverter<string, UInt16>(
    function(pValue: string): UInt16
    begin
      Result := pValue.ToUIntZeroIfEmpty;
    end);
  RegisterConverter<string, Int16>(
    function(pValue: string): Int16
    begin
      Result := pValue.ToIntZeroIfEmpty;
    end);
  RegisterConverter<string, UInt32>(
    function(pValue: string): UInt32
    begin
      Result := pValue.ToUIntZeroIfEmpty;
    end);
  RegisterConverter<string, Int32>(
    function(pValue: string): Int32
    begin
      Result := pValue.ToIntZeroIfEmpty;
    end);
  RegisterConverter<string, UInt64>(
    function(pValue: string): UInt64
    begin
      Result := pValue.ToUIntZeroIfEmpty;
    end);
  RegisterConverter<string, Int64>(
    function(pValue: string): Int64
    begin
      Result := pValue.ToIntZeroIfEmpty;
    end);
  RegisterConverter<string, TAqEntityID>(
    function(pValue: string): TAqEntityID
    begin
      Result := pValue.ToIntZeroIfEmpty;
    end);
  RegisterConverter<string, Double>(
    function(pValue: string): Double
    begin
      Result := pValue.ToDouble;
    end);
  RegisterConverter<string, Currency>(
    function(pValue: string): Currency
    begin
      Result := pValue.ToCurrency;
    end);
  RegisterConverter<string, TDateTime>(
    function(pValue: string): TDateTime
    begin
      Result := pValue.ToDateTime;
    end);
  RegisterConverter<string, TDate>(
    function(pValue: string): TDate
    begin
      Result := pValue.ToDate;
    end);
  RegisterConverter<string, TTime>(
    function(pValue: string): TTime
    begin
      Result := pValue.ToTime;
    end);

  RegisterConverter<string, TGUID>(
    function(pValue: string): TGUID
    begin
      Result := TGUID.Create(pValue);
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromTime;
begin
  RegisterConverter<TTime, string>(
    function(pValue: TTime): string
    begin
{$IF CompilerVersion >= 29} // bug no XE7
      Result := pValue.ToString;
{$ELSE}
      Result := TimeToStr(pValue);
{$ENDIF}
    end);
  RegisterConverter<TTime, Double>(
    function(pValue: TTime): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<TTime, TDateTime>(
    function(pValue: TTime): TDateTime
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromUInt16;
begin
  RegisterConverter<UInt16, string>(
    function(pValue: UInt16): string
    begin
      Result := pValue.ToString;
    end);
  RegisterConverter<UInt16, Boolean>(
    function(pValue: UInt16): Boolean
    begin
      Result := pValue.ToBoolean;
    end);
  RegisterConverter<UInt16, UInt8>(
    function(pValue: UInt16): UInt8
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, Int8>(
    function(pValue: UInt16): Int8
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, UInt16>(
    function(pValue: UInt16): UInt16
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, Int16>(
    function(pValue: UInt16): Int16
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, UInt32>(
    function(pValue: UInt16): UInt32
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, Int32>(
    function(pValue: UInt16): Int32
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, UInt64>(
    function(pValue: UInt16): UInt64
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, Int64>(
    function(pValue: UInt16): Int64
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, TAqEntityID>(
    function(pValue: UInt16): TAqEntityID
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, Double>(
    function(pValue: UInt16): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt16, Currency>(
    function(pValue: UInt16): Currency
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromUInt32;
begin
  RegisterConverter<UInt32, string>(
    function(pValue: UInt32): string
    begin
      Result := pValue.ToString;
    end);
  RegisterConverter<UInt32, Boolean>(
    function(pValue: UInt32): Boolean
    begin
      Result := pValue.ToBoolean;
    end);
  RegisterConverter<UInt32, UInt8>(
    function(pValue: UInt32): UInt8
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, Int8>(
    function(pValue: UInt32): Int8
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, UInt16>(
    function(pValue: UInt32): UInt16
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, Int16>(
    function(pValue: UInt32): Int16
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, UInt32>(
    function(pValue: UInt32): UInt32
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, Int32>(
    function(pValue: UInt32): Int32
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, UInt64>(
    function(pValue: UInt32): UInt64
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, Int64>(
    function(pValue: UInt32): Int64
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, TAqEntityID>(
    function(pValue: UInt32): TAqEntityID
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, Double>(
    function(pValue: UInt32): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt32, Currency>(
    function(pValue: UInt32): Currency
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromUInt64;
begin
  RegisterConverter<UInt64, string>(
    function(pValue: UInt64): string
    begin
{$IF CompilerVersion >= 29} // bug no XE7
      Result := pValue.ToString;
{$ELSE}
      Result := IntToStr(pValue);
{$ENDIF}
    end);
  RegisterConverter<UInt64, Boolean>(
    function(pValue: UInt64): Boolean
    begin
{$IF CompilerVersion >= 29}
      Result := pValue.ToBoolean;
{$ELSE}
      Result := pValue <> 0;
{$ENDIF}
    end);
  RegisterConverter<UInt64, UInt8>(
    function(pValue: UInt64): UInt8
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, Int8>(
    function(pValue: UInt64): Int8
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, UInt16>(
    function(pValue: UInt64): UInt16
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, Int16>(
    function(pValue: UInt64): Int16
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, UInt32>(
    function(pValue: UInt64): UInt32
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, Int32>(
    function(pValue: UInt64): Int32
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, UInt64>(
    function(pValue: UInt64): UInt64
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, Int64>(
    function(pValue: UInt64): Int64
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, TAqEntityID>(
    function(pValue: UInt64): TAqEntityID
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, Double>(
    function(pValue: UInt64): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt64, Currency>(
    function(pValue: UInt64): Currency
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterConvertersFromUInt8;
begin
  RegisterConverter<UInt8, string>(
    function(pValue: UInt8): string
    begin
      Result := pValue.ToString;
    end);
  RegisterConverter<UInt8, Boolean>(
    function(pValue: UInt8): Boolean
    begin
      Result := pValue.ToBoolean;
    end);
  RegisterConverter<UInt8, UInt8>(
    function(pValue: UInt8): UInt8
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, Int8>(
    function(pValue: UInt8): Int8
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, UInt16>(
    function(pValue: UInt8): UInt16
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, Int16>(
    function(pValue: UInt8): Int16
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, UInt32>(
    function(pValue: UInt8): UInt32
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, Int32>(
    function(pValue: UInt8): Int32
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, UInt64>(
    function(pValue: UInt8): UInt64
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, Int64>(
    function(pValue: UInt8): Int64
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, TAqEntityID>(
    function(pValue: UInt8): TAqEntityID
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, Double>(
    function(pValue: UInt8): Double
    begin
      Result := pValue;
    end);
  RegisterConverter<UInt8, Currency>(
    function(pValue: UInt8): Currency
    begin
      Result := pValue;
    end);
end;

procedure TAqTypeConverters.RegisterMinorStandarConverters;
begin
  RegisterConverter<TGUID, string>(
    function(pValue: TGUID): string
    begin
      Result := pValue.ToString;
    end);
end;

procedure TAqTypeConverters.RegisterStandardConverters;
begin
  RegisterConvertersFromString;
  RegisterConvertersFromBoolean;
  RegisterConvertersFromUInt8;
  RegisterConvertersFromInt8;
  RegisterConvertersFromUInt16;
  RegisterConvertersFromInt16;
  RegisterConvertersFromUInt32;
  RegisterConvertersFromInt32;
  RegisterConvertersFromUInt64;
  RegisterConvertersFromInt64;
  RegisterConvertersFromDouble;
  RegisterConvertersFromCurrency;
  RegisterConvertersFromDateTime;
  RegisterConvertersFromDate;
  RegisterConvertersFromTime;
  RegisterConvertersFromEntityID;
  RegisterMinorStandarConverters;
end;

class procedure TAqTypeConverters.ReleaseDefaultInstance;
begin
  FreeAndNil(FDefaultInstance);
end;

function TAqTypeConverters.TryConvert(const pFrom: TValue; const pToType: PTypeInfo; out pValue: TValue): Boolean;
var
  lConverter: TAqTypeConverter;
begin
  Result := pFrom.TypeInfo = pToType;

  if Result then
  begin
    pValue := pFrom;
  end else
  begin
    FConverters.BeginRead;

    try
      Result := FConverters.TryGetValue(GetDictionaryKey(pFrom.TypeInfo, pToType), lConverter);

      if Result then
      begin
        pValue := lConverter.Execute(pFrom);
      end;
    finally
      FConverters.EndRead;
    end;
  end;
end;

function TAqTypeConverters.TryConvert<TFrom, TTo>(const pFrom: TFrom; out pValue: TTo): Boolean;
begin
  Result := TryConvert<TTo>(TValue.From<TFrom>(pFrom), pValue);
end;

function TAqTypeConverters.TryConvert<TTo>(const pFrom: TValue; out pValue: TTo): Boolean;
var
  lValue: TValue;
begin
  Result := TryConvert(pFrom, TypeInfo(TTo), lValue);

  if Result then
  begin
    pValue := lValue.AsType<TTo>;
  end;
end;

{ TAqTypeConverterByMethod<TFrom, TTo> }

constructor TAqTypeConverterByMethod<TFrom, TTo>.Create(const pConverter: TFunc<TFrom, TTo>);
begin
  FConverter := pConverter;
end;

function TAqTypeConverterByMethod<TFrom, TTo>.DoExecute(const pFrom: TValue): TValue;
begin
  Result := TValue.From<TTo>(FConverter(pFrom.AsType<TFrom>));
end;

initialization
  TAqTypeConverters.Default.RegisterStandardConverters;

finalization
  TAqTypeConverters.ReleaseDefaultInstance;

end.
