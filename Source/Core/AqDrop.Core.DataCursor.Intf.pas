unit AqDrop.Core.DataCursor.Intf;

interface

uses
  System.Generics.Collections,
  AqDrop.Core.Collections.Intf;

type
  IAqBaseDataCursor<T> = interface
    ['{072E587A-B3FF-40DE-BBB6-9FC810EAB7DA}']

    function GetCurrentIndex: Int32;
    procedure SetCurrentIndex(const pNewIndex: Int32);
    function GetCurrentItem: T;
    function GetCount: Int32;
    function GetItem(const pIndex: Int32): T;

    function VerifyCanMoveToFirst: Boolean;
    function VerifyCanMoveToPrior: Boolean;
    function VerifyCanMoveToNext: Boolean;
    function VerifyCanMoveToLast: Boolean;

    procedure MoveToFirst;
    procedure MoveToPrior;
    procedure MoveToNext;
    procedure MoveToLast;

    function GetEnumerator: TEnumerator<T>;

    property CurrentIndex: Int32 read GetCurrentIndex write SetCurrentIndex;
    property CurrentItem: T read GetCurrentItem;
    property Count: Int32 read GetCount;
    property Items[const pIndex: Int32]: T read GetItem;
  end;

  IAqDataCursor<T> = interface(IAqBaseDataCursor<T>)
    ['{38111CAF-E199-408E-96E2-875B2C4502A4}']

    procedure SetData(pData: IAqReadableList<T>);
    procedure AddData(pData: IAqReadableList<T>);
    procedure ImportDataFrom(pData: IAqExtractableList<T>);
  end;

implementation

end.
