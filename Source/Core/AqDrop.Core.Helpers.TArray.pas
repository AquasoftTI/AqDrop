unit AqDrop.Core.Helpers.TArray;

interface

uses
  System.SysUtils;

type
  TAqArray<T> = class
  strict private
    class procedure InternalForIn(const pArray: TArray<T>; const pProcessingMethod: TFunc<T, Boolean>;
      out pIndex: Int32; const pAscendingProcessing: Boolean = True); overload;
  public
    class procedure ForIn(const pArray: TArray<T>; const pProcessingMethod: TProc<T>;
      const pAscendingProcessing: Boolean = True); overload;
    class procedure ForIn(const pArray: TArray<T>; const pProcessingMethod: TFunc<T, Boolean>;
      const pAscendingProcessing: Boolean = True); overload;
    class function SearchItem(const pArray: TArray<T>; const pMatchFunction: TFunc<T, Boolean>; out pIndex: Int32;
      const pAscendingSearch: Boolean = True): Boolean; overload;
    class function SearchItem(const pArray: TArray<T>; const pMatchFunction: TFunc<T, Boolean>;
      const pAscendingSearch: Boolean = True): Boolean; overload;
  end;

implementation

uses
  System.Math;

{ TAqArray<T> }

class procedure TAqArray<T>.InternalForIn(const pArray: TArray<T>; const pProcessingMethod: TFunc<T, Boolean>;
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

class function TAqArray<T>.SearchItem(const pArray: TArray<T>; const pMatchFunction: TFunc<T, Boolean>;
  const pAscendingSearch: Boolean): Boolean;
var
  lIndice: Int32;
begin
  Result := SearchItem(pArray, pMatchFunction, lIndice, pAscendingSearch);
end;

class procedure TAqArray<T>.ForIn(const pArray: TArray<T>; const pProcessingMethod: TProc<T>;
  const pAscendingProcessing: Boolean);
begin
  ForIn(pArray,
    function(pItem: T): Boolean
    begin
      pProcessingMethod(pItem);
      Result := True;
    end, pAscendingProcessing);
end;

class procedure TAqArray<T>.ForIn(const pArray: TArray<T>; const pProcessingMethod: TFunc<T, Boolean>;
  const pAscendingProcessing: Boolean);
var
  lIndex: Int32;
begin
  InternalForIn(pArray, pProcessingMethod, lIndex, pAscendingProcessing);
end;

class function TAqArray<T>.SearchItem(const pArray: TArray<T>; const pMatchFunction: TFunc<T, Boolean>;
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
