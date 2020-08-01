unit AqDrop.Core.Helpers.TValue;

interface

uses
  System.TypInfo,
  System.Rtti,
  AqDrop.Core.Generics.Converters;

type
  TAqValueHelper = record helper for TValue
  strict private
    function VerifyIfIsDefault: Boolean;
  public
    function HasConverterTo<T>: Boolean;

    function TryConvertValueTo<T>(out pValue: T): Boolean;

    function ConvertValueTo<T>: T; inline;
    function ConvertTo<T>: TValue; overload;
    function ConvertTo(const pTargetType: PTypeInfo): TValue; overload;

    property IsDefault: Boolean read VerifyIfIsDefault;
  end;

implementation

uses
  AqDrop.Core.Types,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers.TArray;

{ TAqValueHelper }

function TAqValueHelper.ConvertTo(const pTargetType: PTypeInfo): TValue;
begin
  if Self.TypeInfo = pTargetType then
  begin
    Result := Self;
  end else begin
    Result := TAqTypeConverters.Default.Convert(Self, pTargetType);
  end;
end;

function TAqValueHelper.ConvertTo<T>: TValue;
begin
  if Self.IsEmpty then
  begin
    Result := TValue.From<T>(Default(T));
  end else begin
    Result := ConvertTo(System.TypeInfo(T));
  end;
end;

function TAqValueHelper.ConvertValueTo<T>: T;
begin
  Result := ConvertTo<T>.AsType<T>;
end;

function TAqValueHelper.HasConverterTo<T>: Boolean;
begin
  Result := TAqTypeConverters.Default.HasConverter<T>(Self);
end;

function TAqValueHelper.TryConvertValueTo<T>(out pValue: T): Boolean;
begin
  Result := TAqTypeConverters.Default.TryConvert<T>(Self, pValue);
end;

function TAqValueHelper.VerifyIfIsDefault: Boolean;
var
  lBuffer: TArray<Byte>;
begin
  Result := Self.Kind <> tkEnumeration;

  if Result then
  begin
    SetLength(lBuffer, Self.DataSize);
    Self.ExtractRawDataNoCopy(@lBuffer[0]);

    Result := not TAqArray<Byte>.Find(lBuffer,
      function(pItem: Byte): Boolean
      begin
        Result := pItem <> 0;
      end);
  end;
end;

end.
