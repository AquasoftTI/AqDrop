unit AqDrop.Core.DataCursor;

interface

uses
  System.Generics.Collections,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.DataCursor.Intf;

type
  TAqBaseDataCursor<T> = class(TAqARCObject, IAqBaseDataCursor<T>)
  strict private
    FCurrentIndex: Int32;

    function GetCurrentIndex: Int32;
  strict protected
    procedure DoSetData(pData: IAqReadableList<T>); virtual; abstract;
    procedure DoAddData(pData: IAqReadableList<T>); virtual; abstract;
    function  DoGetData: IAqReadableList<T>; virtual; abstract;
    procedure DoSetCurrentIndex(const pNewIndex: Int32); virtual;

    procedure SetCurrentIndex(const pNewIndex: Int32); virtual;
    function IsValidCursorIndex(const pIndex: Int32): Boolean; virtual;
    procedure ValidateCurrentIndex;
    procedure ValidateCursorIndex(const pIndex: Int32);
    function GetCurrentItem: T; virtual;
    function DoGetItem(const pIndex: Integer): T; virtual; abstract;
    function GetCount: Int32; virtual; abstract;
    function VerifyCanMoveBackward: Boolean; virtual;
    function VerifyCanMoveForward: Boolean; virtual;
    procedure AdjustCurrentIndex; virtual;
    procedure ResetIndex; virtual;

    procedure DoDataChanged; virtual;
    procedure DoAfterSetData; virtual;
    procedure DoAfterAddData; virtual;
    procedure AfterSetData;
    procedure AfterAddData;
    procedure SetData(pData: IAqReadableList<T>);
    procedure AddData(pData: IAqReadableList<T>);
    function  GetData: IAqReadableList<T>;
  public
    constructor Create;

    function GetItem(const pIndex: Integer): T; virtual;

    function VerifyCanMoveToFirst: Boolean; virtual;
    function VerifyCanMoveToPrior: Boolean; virtual;
    function VerifyCanMoveToNext: Boolean; virtual;
    function VerifyCanMoveToLast: Boolean; virtual;

    procedure MoveToFirst; virtual;
    procedure MoveToPrior; virtual;
    procedure MoveToNext; virtual;
    procedure MoveToLast; virtual;

    function GetEnumerator: TEnumerator<T>; virtual; abstract;

    property CurrentIndex: Int32 read GetCurrentIndex write SetCurrentIndex;
    property CurrentItem: T read GetCurrentItem;
    property Count: Int32 read GetCount;
  end;

  TAqDataCursor<T> = class(TAqBaseDataCursor<T>, IAqDataCursor<T>)
  strict private
    FItems: IAqList<T>;
    procedure ImportDataFrom(pData: IAqExtractableList<T>);
  strict protected
    procedure DoSetData(pData: IAqReadableList<T>); override;
    procedure DoAddData(pData: IAqReadableList<T>); override;
    function  DoGetData: IAqReadableList<T>; override;
    function DoGetItem(const pIndex: Integer): T; override;
    function GetCount: Int32; override;
  public
    constructor Create; overload;
    constructor Create(const pFreeObjects: Boolean); overload;
    constructor Create(const pFreeObjects: Boolean; pList: IAqReadableList<T>); overload;
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Collections;

{ TAqBaseDataCursor<T> }

procedure TAqBaseDataCursor<T>.AddData(pData: IAqReadableList<T>);
begin
  DoAddData(pData);

  AfterAddData;
end;

procedure TAqBaseDataCursor<T>.AdjustCurrentIndex;
begin
  if Count = 0 then
  begin
    SetCurrentIndex(-1);
  end else begin
    SetCurrentIndex(Max(Min(CurrentIndex, Count - 1), 0));
  end;
end;

procedure TAqBaseDataCursor<T>.AfterAddData;
begin
  DoDataChanged;
  DoAfterAddData;
end;

procedure TAqBaseDataCursor<T>.AfterSetData;
begin
  DoDataChanged;
  DoAfterSetData;
end;

procedure TAqBaseDataCursor<T>.DoAfterAddData;
begin

end;

procedure TAqBaseDataCursor<T>.DoAfterSetData;
begin
  if Count > 0 then
  begin
    SetCurrentIndex(0);
  end else begin
    SetCurrentIndex(-1);
  end;
end;

constructor TAqBaseDataCursor<T>.Create;
begin
  FCurrentIndex := -1;
end;

procedure TAqBaseDataCursor<T>.DoDataChanged;
begin

end;

procedure TAqBaseDataCursor<T>.DoSetCurrentIndex(const pNewIndex: Int32);
begin
  ValidateCursorIndex(pNewIndex);

  FCurrentIndex := pNewIndex;
end;

function TAqBaseDataCursor<T>.GetCurrentIndex: Int32;
begin
  Result := FCurrentIndex;
end;

function TAqBaseDataCursor<T>.GetCurrentItem: T;
begin
  if not IsValidCursorIndex(CurrentIndex) then
  begin
    AdjustCurrentIndex;
  end;

  Result := GetItem(FCurrentIndex);
end;

function TAqBaseDataCursor<T>.GetData: IAqReadableList<T>;
begin
  Result := DoGetData;
end;

function TAqBaseDataCursor<T>.GetItem(const pIndex: Integer): T;
begin
  ValidateCursorIndex(pIndex);

  Result := DoGetItem(pIndex);
end;

function TAqBaseDataCursor<T>.IsValidCursorIndex(const pIndex: Int32): Boolean;
begin
  Result := (pIndex = -1) or ((pIndex >= 0) and (pIndex < Count));
end;

procedure TAqBaseDataCursor<T>.MoveToFirst;
begin
  SetCurrentIndex(0);
end;

procedure TAqBaseDataCursor<T>.MoveToLast;
begin
  if Count > 0 then
  begin
    SetCurrentIndex(Count - 1);
  end else begin
    SetCurrentIndex(0);
  end;
end;

procedure TAqBaseDataCursor<T>.MoveToNext;
begin
  SetCurrentIndex(FCurrentIndex + 1);
end;

procedure TAqBaseDataCursor<T>.MoveToPrior;
begin
  SetCurrentIndex(FCurrentIndex - 1);
end;

procedure TAqBaseDataCursor<T>.ResetIndex;
begin
  if Count > 0 then
  begin
    SetCurrentIndex(0);
  end else begin
    SetCurrentIndex(-1);
  end;
end;

procedure TAqBaseDataCursor<T>.SetCurrentIndex(const pNewIndex: Int32);
begin
  DoSetCurrentIndex(pNewIndex);
end;

procedure TAqBaseDataCursor<T>.SetData(pData: IAqReadableList<T>);
begin
  DoSetData(pData);

  AfterSetData;
end;

procedure TAqBaseDataCursor<T>.ValidateCurrentIndex;
begin
  ValidateCursorIndex(FCurrentIndex);
end;

procedure TAqBaseDataCursor<T>.ValidateCursorIndex(const pIndex: Int32);
begin
  if not IsValidCursorIndex(pIndex) then
  begin
    raise EAqInternal.CreateFmt('Invalid Cursor Index (%d).', [pIndex]);
  end;
end;

function TAqBaseDataCursor<T>.VerifyCanMoveBackward: Boolean;
begin
  Result := FCurrentIndex > 0;
end;

function TAqBaseDataCursor<T>.VerifyCanMoveForward: Boolean;
begin
  Result := FCurrentIndex < Count - 1;
end;

function TAqBaseDataCursor<T>.VerifyCanMoveToFirst: Boolean;
begin
  Result := VerifyCanMoveBackward;
end;

function TAqBaseDataCursor<T>.VerifyCanMoveToLast: Boolean;
begin
  Result := VerifyCanMoveForward;
end;

function TAqBaseDataCursor<T>.VerifyCanMoveToNext: Boolean;
begin
  Result := VerifyCanMoveForward;
end;

function TAqBaseDataCursor<T>.VerifyCanMoveToPrior: Boolean;
begin
  Result := VerifyCanMoveBackward;
end;

{ TAqDataCursor<T> }

constructor TAqDataCursor<T>.Create;
begin

end;

constructor TAqDataCursor<T>.Create(const pFreeObjects: Boolean);
begin

end;

constructor TAqDataCursor<T>.Create(const pFreeObjects: Boolean; pList: IAqReadableList<T>);
begin


end;

procedure TAqDataCursor<T>.DoAddData(pData: IAqReadableList<T>);
var
  lItem: T;
begin
  for lItem in pData do
  begin
    FItems.Add(lItem);
  end;
end;

function TAqDataCursor<T>.DoGetData: IAqReadableList<T>;
begin
  Result := FItems;
end;

function TAqDataCursor<T>.DoGetItem(const pIndex: Integer): T;
begin

end;

procedure TAqDataCursor<T>.DoSetData(pData: IAqReadableList<T>);
begin
  FItems.Clear;

  DoAddData(pData);
end;

procedure TAqDataCursor<T>.ImportDataFrom(pData: IAqExtractableList<T>);
begin
  FItems.Clear;

  pData.ExtractAllTo(FItems);

  AfterSetData;
end;

function TAqDataCursor<T>.GetCount: Int32;
begin
  Result := FItems.Count;
end;

end.
