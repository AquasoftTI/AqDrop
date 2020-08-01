unit AqDrop.Core.Helpers.TArray;

interface

uses
  System.SysUtils,
  System.Classes;

type
  TAqArray<T> = class
  strict private
    class procedure InternalForIn(const pArray: array of T; const pProcessingMethod: TFunc<T, Boolean>;
      out pIndex: Int32; const pAscendingProcessing: Boolean = True); overload;
  public
    class procedure ForIn(const pArray: array of T; const pProcessingMethod: TProc<T>;
      const pAscendingProcessing: Boolean = True); overload;
    class procedure ForIn(const pArray: array of T; const pProcessingMethod: TFunc<T, Boolean>;
      const pAscendingProcessing: Boolean = True); overload;
    class function Find(const pArray: array of T; const pMatchFunction: TFunc<T, Boolean>; out pIndex: Int32;
      const pAscendingSearch: Boolean = True): Boolean; overload;
    class function Find(const pArray: array of T; const pMatchFunction: TFunc<T, Boolean>;
      const pAscendingSearch: Boolean = True): Boolean; overload;

    class procedure FillStrings(const pSource: array of T; const pTarget: TStrings);

    class function FindItemEnum<TEnum {enum}>(const pValue: T; const pArray: array of T; out pEnum: TEnum): Boolean;
  end;

implementation

uses
  System.TypInfo,
  System.Math,
  System.Rtti,
  System.Generics.Defaults,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers,
  AqDrop.Core.Generics.Converters;

{ TAqArray<T> }

class procedure TAqArray<T>.InternalForIn(const pArray: array of T; const pProcessingMethod: TFunc<T, Boolean>;
  out pIndex: Int32; const pAscendingProcessing: Boolean);
var
  lEndIndex: Int32;
begin
  if pAscendingProcessing then
  begin
    pIndex := 0;
    lEndIndex := Length(pArray);
  end else begin
    pIndex := Length(pArray) - 1;
    lEndIndex := 0;
  end;

  while (pAscendingProcessing xor (pIndex >= lEndIndex)) and pProcessingMethod(pArray[pIndex]) do
  begin
    Inc(pIndex, IfThen(pAscendingProcessing, 1, -1));
  end;
end;

class procedure TAqArray<T>.FillStrings(const pSource: array of T; const pTarget: TStrings);
var
  lValue: T;
begin
  pTarget.Clear;

  for lValue in pSource do
  begin
    pTarget.Add(TAqTypeConverters.Default.Convert<T, string>(lValue));
  end;
end;

class function TAqArray<T>.Find(const pArray: array of T; const pMatchFunction: TFunc<T, Boolean>;
  const pAscendingSearch: Boolean): Boolean;
var
  lIndice: Int32;
begin
  Result := Find(pArray, pMatchFunction, lIndice, pAscendingSearch);
end;

class function TAqArray<T>.FindItemEnum<TEnum>(const pValue: T; const pArray: array of T; out pEnum: TEnum): Boolean;
var
  lTypeInfo: PTypeInfo;
  lIndex: Int32;
begin
  lTypeInfo := TypeInfo(TEnum);

  if lTypeInfo^.Kind <> tkEnumeration then
  begin
    raise EAqInternal.Create('Uso inválido da função BuscarValorArray');
  end;

  Result := Find(pArray,
    function(pItem: T): Boolean
    var
      lComparer: IComparer<T>;
    begin
      if TypeInfo(T) = TypeInfo(string) then
      begin
        lComparer := TDelegatedComparer<T>.Create(
          function(const pLeft, pRight: T): Int32
          begin
            Result := IfThen(string.SameText(TValue.From<T>(pLeft).AsString, TValue.From<T>(pRight).AsString), 0, 1);
          end);
      end else
      begin
        lComparer := TComparer<T>.Default;
      end;
      Result := lComparer.Compare(pValue, pItem) = 0;
    end, lIndex) and (lIndex >= lTypeInfo^.TypeData^.MinValue) and (lIndex <= lTypeInfo^.TypeData^.MaxValue);

  if Result then
  begin
    case SizeOf(TEnum) of
      1: pByte(@pEnum)^ := lIndex;
      2: pWord(@pEnum)^ := lIndex;
      4: pCardinal(@pEnum)^ := lIndex;
    end;
  end;
end;

class procedure TAqArray<T>.ForIn(const pArray: array of T; const pProcessingMethod: TProc<T>;
  const pAscendingProcessing: Boolean);
begin
  ForIn(pArray,
    function(pItem: T): Boolean
    begin
      pProcessingMethod(pItem);
      Result := True;
    end, pAscendingProcessing);
end;

class procedure TAqArray<T>.ForIn(const pArray: array of T; const pProcessingMethod: TFunc<T, Boolean>;
  const pAscendingProcessing: Boolean);
var
  lIndex: Int32;
begin
  InternalForIn(pArray, pProcessingMethod, lIndex, pAscendingProcessing);
end;

class function TAqArray<T>.Find(const pArray: array of T; const pMatchFunction: TFunc<T, Boolean>;
  out pIndex: Int32; const pAscendingSearch: Boolean): Boolean;
var
  lResult: Boolean;
begin
  lResult := False;

  InternalForIn(pArray,
    function(pItem: T): Boolean
    begin
      lResult := pMatchFunction(pItem);
      Result := not lResult;
    end, pIndex, pAscendingSearch);

  Result := lResult;
end;

end.
