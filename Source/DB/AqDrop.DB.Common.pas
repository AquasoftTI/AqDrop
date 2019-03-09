unit AqDrop.DB.Common;

{$I '..\Core\AqDrop.Core.Defines.Inc'}

interface

uses
  System.TypInfo,
  System.Rtti,
  AqDrop.Core.Types,
  AqDrop.DB.Types;

type
  TAqDBValueConverter = class
  public
    class function ConvertToTValue(pValue: IAqDBReadValue; const pAsType: PTypeInfo): TValue;
  end;

implementation

uses
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers;

{ TAqDBValueConverter }

class function TAqDBValueConverter.ConvertToTValue(pValue: IAqDBReadValue; const pAsType: PTypeInfo): TValue;
var
  lDROPType: TAqDataType;
begin
  lDROPType := TAqDataType.FromTypeInfo(pAsType);

  case lDROPType of
    TAqDataType.adtBoolean:
      Result := TValue.From<Boolean>(pValue.AsBoolean);
    TAqDataType.adtEnumerated:
      Result := TValue.FromOrdinal(pAsType, pValue.AsInt64);
    TAqDataType.adtUInt8:
      Result := TValue.From<UInt8>(pValue.AsUInt8);
    TAqDataType.adtInt8:
      Result := TValue.From<Int8>(pValue.AsInt8);
    TAqDataType.adtUInt16:
      Result := TValue.From<UInt16>(pValue.AsUInt16);
    TAqDataType.adtInt16:
      Result := TValue.From<Int16>(pValue.AsInt16);
    TAqDataType.adtUInt32:
      Result := TValue.From<UInt32>(pValue.AsUInt32);
    TAqDataType.adtInt32:
      Result := TValue.From<Int32>(pValue.AsInt32);
    TAqDataType.adtUInt64:
      Result := TValue.From<UInt64>(pValue.AsUInt64);
    TAqDataType.adtInt64:
      Result := TValue.From<Int64>(pValue.AsInt64);
    TAqDataType.adtCurrency:
      Result := TValue.From<Currency>(pValue.AsCurrency);
    TAqDataType.adtDouble:
      Result := TValue.From<Double>(pValue.AsDouble);
    TAqDataType.adtSingle:
      Result := TValue.From<Single>(pValue.AsSingle);
    TAqDataType.adtDatetime:
      Result := TValue.From<TDateTime>(pValue.AsDateTime);
    TAqDataType.adtDate:
      Result := TValue.From<TDate>(pValue.AsDate);
    TAqDataType.adtTime:
      Result := TValue.From<TTime>(pValue.AsTime);
{$IFNDEF AQMOBILE}
    TAqDataType.adtAnsiChar:
      Result := TValue.From<AnsiChar>(AnsiChar(pValue.AsString.Chars[0]));
{$ENDIF}
    TAqDataType.adtChar:
      Result := TValue.From<Char>(pValue.AsString.Chars[0]);
{$IFNDEF AQMOBILE}
    TAqDataType.adtAnsiString:
      Result := TValue.From<AnsiString>(pValue.AsAnsiString);
{$ENDIF}
    TAqDataType.adtString, TAqDataType.adtWideString:
      Result := TValue.From<string>(pValue.AsString);
  else
    raise EAqInternal.CreateFmt('Unexpected type while converting IAqDBReadValue to TValue (%s).',
      [lDROPType.ToString]);
  end;
end;

end.
