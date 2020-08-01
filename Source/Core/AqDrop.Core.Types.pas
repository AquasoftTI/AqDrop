unit AqDrop.Core.Types;

interface

{$I 'AqDrop.Core.Defines.inc'}

uses
  System.TypInfo;

type
  TAqID = type NativeUInt;

  TAqIDHelper = record helper for TAqID
  strict private
    function VerifyIfIsEmpty: Boolean; inline;
  public
    function ToString: string;

    class function GetEmptyID: TAqID; static; inline;

    property IsEmpty: Boolean read VerifyIfIsEmpty;
  end;

{$IFNDEF AQMOBILE}
  TAqAnsiCharSet = set of AnsiChar;
{$ENDIF}

  TAqDataType = (
    adtUnknown,
    adtBoolean,
    adtEnumerated,
    adtUInt8,
    adtInt8,
    adtUInt16,
    adtInt16,
    adtUInt32,
    adtInt32,
    adtUInt64,
    adtInt64,
    adtCurrency,
    adtDouble,
    adtSingle,
    adtDatetime,
    adtDate,
    adtTime,
    adtAnsiChar,
    adtChar,
    adtAnsiString,
    adtString,
    adtWideString,
    adtSet,
    adtClass,
    adtMethod,
    adtVariant,
    adtRecord,
    adtInterface,
    adtGUID);

  TAqDataTypeHelper = record helper for TAqDataType
    function ToString: string;
    class function FromTypeInfo(const pType: PTypeInfo): TAqDataType; static;
    class function FromType<T>: TAqDataType; static;
  end;

const
  adtIntTypes = [adtUInt8..adtInt64];
  adtCharTypes = [adtAnsiChar, adtChar];
  adtStringTypes = [adtAnsiString, adtString, adtWideString];

type
  TAqEntityID = type Int64;

  TAqUnixDateTime = type Int64;

  TAqGenericEvent<T> = procedure(pArg: T) of object;

implementation

uses
  System.SysUtils,
  AqDrop.Core.Helpers,
  AqDrop.Core.Exceptions;

{ TAqDataTypeHelper }

class function TAqDataTypeHelper.FromType<T>: TAqDataType;
begin
  Result := FromTypeInfo(TypeInfo(T));
end;

class function TAqDataTypeHelper.FromTypeInfo(const pType: PTypeInfo): TAqDataType;
begin
  case pType^.Kind of
    tkUnknown:
      Result := TAqDataType.adtUnknown;
    tkInteger:
      Result := TAqDataType.adtInt32;
    tkChar:
      Result := TAqDataType.adtAnsiChar;
    tkEnumeration:
      begin
        if pType = TypeInfo(Boolean) then
        begin
          Result := TAqDataType.adtBoolean;
        end else begin
          Result := TAqDataType.adtEnumerated;
        end;
      end;
    tkFloat:
      begin
        if pType = TypeInfo(TDateTime) then
        begin
          Result := TAqDataType.adtDatetime;
        end else if pType = TypeInfo(TDate) then
        begin
          Result := TAqDataType.adtDate;
        end else if pType = TypeInfo(TTime) then
        begin
          Result := TAqDataType.adtTime;
        end else if pType = TypeInfo(Currency) then
        begin
          Result := TAqDataType.adtCurrency;
        end else begin
          Result := TAqDataType.adtDouble;
        end;
      end;
    tkSet:
      Result := TAqDataType.adtSet;
    tkClass:
      Result := TAqDataType.adtClass;
    tkMethod:
      Result := TAqDataType.adtMethod;
    tkWChar:
      Result := TAqDataType.adtChar;
    tkLString:
      Result := TAqDataType.adtAnsiString;
    tkWString:
      Result := TAqDataType.adtWideString;
    tkVariant:
      Result := TAqDataType.adtVariant;
    tkRecord:
      begin
        if pType = TypeInfo(TGUID) then
        begin
          Result := TAqDataType.adtGUID;
        end else
        begin
          Result := TAqDataType.adtRecord;
        end;
      end;
    tkInterface:
      Result := TAqDataType.adtInterface;
    tkInt64:
      Result := TAqDataType.adtInt64;
    tkUString:
      Result := TAqDataType.adtString;
  else
    raise EAqInternal.CreateFmt('Unexpected data type while getting the AqDataType (%s - %s)',
      [pType^.Name, GetEnumName(TypeInfo(TTypeKind), Integer(pType^.Kind))]);
  end;
end;

function TAqDataTypeHelper.ToString: string;
begin
  Result := GetEnumName(TypeInfo(TAqDataType), Integer(Self));
end;

{ TAqIDHelper }

class function TAqIDHelper.GetEmptyID: TAqID;
begin
  Result := 0;
end;

function TAqIDHelper.ToString: string;
begin
  Result := NativeInt(Self).ToString;
end;

function TAqIDHelper.VerifyIfIsEmpty: Boolean;
begin
  Result := Self = GetEmptyID;
end;

end.
