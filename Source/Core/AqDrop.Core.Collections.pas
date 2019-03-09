unit AqDrop.Core.Collections;

interface

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections,
  System.SyncObjs,
  AqDrop.Core.Types,
  AqDrop.Core.Clonable.Intf,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.InterfacedObject;

type
  TAqKeyValueOwnership = (kvoKey, kvoValue);
  TAqKeyValueOwnerships = set of TAqKeyValueOwnership;
  TAqLockerType = (lktNone, lktCriticalSection, lktMultiReadeExclusiveWriter);

  TAqKeyValuePair<K, V> = class(TAqARCObject, IAqKeyValuePair<K, V>)
  strict private
    FOwnerships: TAqKeyValueOwnerships;
    FKey: K;
    FValue: V;

    function GetKey: K;
    function GetValue: V;
  public
    constructor Create(const pKey: K; const pValue: V; const pOwnerships: TAqKeyValueOwnerships = []);
    destructor Destroy; override;

    property Key: K read GetKey;
    property Value: V read GetValue;
  end;

  TAqLocker = class abstract(TAqARCObject, IAqLocker)
  public
    procedure BeginRead; virtual; abstract;
    procedure BeginWrite; virtual; abstract;
    procedure EndRead; virtual; abstract;
    procedure EndWrite; virtual; abstract;
  end;

  TAqCriticalSectionLocker = class(TAqLocker)
  strict private
    FCriticalSection: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginRead; override;
    procedure EndRead; override;
    procedure BeginWrite; override;
    procedure EndWrite; override;
  end;

  TAqMultiReadExclusiveWriteLocker = class(TAqLocker)
  strict private
    FMultiReadeExclusiveWriterSynchronizer: TMultiReadExclusiveWriteSynchronizer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginRead; override;
    procedure EndRead; override;
    procedure BeginWrite; override;
    procedure EndWrite; override;
  end;

  TAqLockerFactory = class
  public
    class function CreateLocker(const pLockerType: TAqLockerType): IAqLocker;
  end;

  TAqIterator<T> = class(TAqARCObject, IAqIterator<T>)
  strict private
    FList: IAqReadableList<T>;
    FCurrentPosition: Int32;
  public
    constructor Create(pList: IAqReadableList<T>);

    function MoveToNext: Boolean;
    function VerifyIfIsFinished: Boolean;
    procedure Reset;
    function GetCurrentItem: T;
  end;

  ///-------------------------------------------------------------------------------------------------------------------
  /// TAqComparisonResult
  ///-------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Type used to return the comparison result between two items.
  ///   PT-BR:
  ///     Tipo utilizado para retornar o resultado da comparação entre dois itens.
  /// </summary>
  ///-------------------------------------------------------------------------------------------------------------------
  TAqComparisonResult = (acrEqual, acrGreater, acrLess);

  TAqComparerFunction<T> = reference to function(const pValue1, pValue2: T): TAqComparisonResult;

  TAqBaseList<TFrom, TTo> = class abstract(TAqARCObject, IAqReadableList<TTo>)
  public type
    TEnumerator = class(TEnumerator<TTo>)
    private
      FList: TAqBaseList<TFrom, TTo>;
      FIndex: Int32;
      function GetCurrent: TTo;
    protected
      function DoGetCurrent: TTo; override;
      function DoMoveNext: Boolean; override;
    public
      constructor Create(const pList: TAqBaseList<TFrom, TTo>);
      function MoveNext: Boolean;

      property Current: TTo read GetCurrent;
    end;
  strict private
    FInternalList: TList<TFrom>;
    FOwnsList: Boolean;

    function GetCount: Int32;
    function GetItem(const pIndex: Int32): TTo;
    function GetFirst: TTo;
    function GetLast: TTo;
  strict protected
    function GetInternalList: TList<TFrom>; virtual;
    function ConvertFromTo(pFrom: TFrom): TTo; virtual; abstract;
    function ConvertToFrom(pTo: TTo): TFrom; virtual; abstract;
  public
    constructor Create(const pList: TList<TFrom>; const pOwnsList: Boolean = False);
    destructor Destroy; override;

    function Contains(const pValue: TTo): Boolean; inline;

    /// <summary>
    ///   EN-US:
    ///     Finds the index of an item in the list.
    ///   PT-BR:
    ///     Localiza o índice de um item na lista.
    /// </summary>
    /// <param name="pValue">
    ///   EN-US:
    ///     Value that should be found.
    ///   PT-BR:
    ///     Valor que deve ser encontrado.
    /// </param>
    /// <returns>
    ///   EN-US:
    ///     Returns the index fo the searched value. If the value is not found, the function returns -1.
    ///   PT-BR:
    ///     Retorna o índice do valor procurado na lista. Caso o valor não seja encontrado, a função retornará -1.
    /// </returns>
    function IndexOf(const pValue: TTo): Int32; overload;

    function Find(const pMatchFunction: TFunc<TTo, Boolean>): Boolean; overload; inline;
    function Find(const pMatchFunction: TFunc<TTo, Boolean>; out pIndex: Int32): Boolean; overload;
    function Find(const pItem: TTo; out pIndex: Int32): Boolean; overload; inline;

    function GetItemTypeName: string;
    function GetEnumerator: TEnumerator<TTo>;
    function GetIterator: IAqIterator<TTo>;

    property Count: Int32 read GetCount;
    property Items[const pIndex: Int32]: TTo read GetItem; default;

    property First: TTo read GetFirst;
    property Last: TTo read GetLast;
  end;

  TAqReadableList<T> = class(TAqBaseList<T, T>)
  strict protected
    function ConvertFromTo(pFrom: T): T; override;
    function ConvertToFrom(pTo: T): T; override;
  end;

  TAqWritableList<T> = class(TAqReadableList<T>, IAqWritableList<T>)
  strict private
    FFreeObjects: Boolean;
    FComparer: IComparer<T>;
    FLocker: IAqLocker;

    function GetComparer: IComparer<T>;
    procedure SetComparer(pValue: IComparer<T>);

    function VerifyIfHasLocker: Boolean;
    procedure AssertUsingLocker;

    function GetReadOnlyList: IAqReadableList<T>;
  strict protected
    procedure ListNotifier(pSender: TObject; const pItem: T; pAction: TCollectionNotification); virtual;

    procedure ExecWithReleaseOff(const pMethod: TProc);

    property FreeObjects: Boolean read FFreeObjects write FFReeObjects;
  public
    constructor Create; overload;
    constructor Create(const pFreeObjects: Boolean); overload;
    constructor Create(const pFreeObjects: Boolean; const pLockerType: TAqLockerType); overload;
    constructor Create(const pLockerType: TAqLockerType); overload;

    /// <summary>
    ///   EN-US:
    ///     Deletes an item from the list.
    ///   PT-BR:
    ///     Exclui um item da lista.
    /// </summary>
    /// <param name="pIndex">
    ///   EN-US:
    ///     Index of the item to be deleted.
    ///   PT-BR:
    ///     Índice do item que deve ser excluído.
    /// </param>
    procedure Delete(const pIndex: Int32); virtual;

    procedure DeleteItem(const pItem: T);

    /// <summary>
    ///   EN-US:
    ///     Exchange the position of two items in the list.
    ///   PT-BR:
    ///     Troca de posição dois itens da lista.
    /// </summary>
    /// <param name="pIndex1">
    ///   EN-US:
    ///     Index of the first item.
    ///   PT-BR:
    ///     Índice do primeiro item.
    /// </param>
    /// <param name="pIndex2">
    ///   EN-US:
    ///     Index of the second item.
    ///   PT-BR:
    ///     Índice do segundo item.
    /// </param>
    procedure Exchange(const pIndex1, pIndex2: Int32); virtual;

    /// <summary>
    ///   EN-US:
    ///     Deletes all items of the list.
    ///   PT-BR:
    ///     Exclui todos os itens da lista.
    /// </summary>
    procedure Clear;

    procedure Sort; overload;
    procedure Sort(const pComparerFunction: TFunc<T, T, Int32>); overload;
    procedure Sort(pComparer: IComparer<T>); overload;

    procedure BeginRead;
    procedure EndRead;
    procedure BeginWrite;
    procedure EndWrite;

    procedure ExecuteLockedForReading(const pMethod: TProc); overload;
    procedure ExecuteLockedForReading(const pMethod: TProc<IAqWritableList<T>>); overload;
    procedure ExecuteLockedForWriting(const pMethod: TProc); overload;
    procedure ExecuteLockedForWriting(const pMethod: TProc<IAqWritableList<T>>); overload;

    property Comparer: IComparer<T> read GetComparer write SetComparer;

    property HasLocker: Boolean read VerifyIfHasLocker;
  end;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Base class for lists of Aquasoft packages.
  ///   PT-BR:
  ///     Classe base para listas nos pacotes Aquasoft.
  ///</summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqList<T> = class(TAqWritableList<T>, IAqList<T>, IAqExtractableList<T>)
  public
    procedure SetItem(const pIndex: Int32; const pItem: T);
    /// <summary>
    ///   EN-US:
    ///     Insert a new item to the list, in a specific position.
    ///   PT-BR:
    ///     Insere um novo item, em uma posição específica da lista.
    /// </summary>
    /// <param name="pIndex">
    ///   EN-US:
    ///     Index which the new item must assume.
    ///   PT-BR:
    ///     Posição onde deve ser inserido o novo item.
    /// </param>
    /// <param name="pItem">
    ///   EN-US:
    ///     Item that must be entered.
    ///   PT-BR:
    ///     Item que deve ser inserido.
    /// </param>
    procedure Insert(const pIndex: Int32; const pItem: T); virtual;

    /// <summary>
    ///   EN-US:
    ///     Removes a specific item and add it to another list.
    ///   PT-BR:
    ///     Retira um item específico e o adiciona outra lista.
    /// </summary>
    /// <param name="pIndex">
    ///   EN-US:
    ///     Index of the item in the current list.
    ///   PT-BR:
    ///     Índice do item que deve ser removido da lista corrente.
    /// </param>
    /// <param name="pNewList">
    ///   EN-US:
    ///     List where the item removed will now be added.
    ///   PT-BR:
    ///     Lista onde o item retirado será agora adicionado.
    /// </param>
    procedure ExchangeList(const pIndex: Int32; const pNewList: TAqList<T>); virtual;

    /// <summary>
    ///   EN-US:
    ///     Adds a new item to the list.
    ///   PT-BR:
    ///     Adiciona um novo item à lista.
    /// </summary>
    /// <param name="pItem">
    ///   EN-US:
    ///     Item that must be added to the list.
    ///   PT-BR:
    ///     Item que deve ser adicionado à lista.
    /// </param>
    /// <returns>
    ///   EN-US:
    ///     Returns the index os the item added to the list.
    ///   PT-BR:
    ///     Retorna o índice do item adicionado à lista.
    /// </returns>
    function Add(const pItem: T): Int32; virtual;

    function Extract(const pIndex: Int32 = 0): T;
    procedure ExtractAllTo(pList: IAqList<T>);
    function GetExtractableList: IAqExtractableList<T>; inline;
  end;

  TAqManagedList<T> = class(TAqWritableList<T>, IAqManagedList<T>)
  strict private
    [AqCloneOff]
    FNewItemMethod: TFunc<T>;
  strict protected
    function CreateNew: T;
  public
    constructor Create(const pNewItemMethod: TFunc<T>); overload;
    constructor Create(const pNewItemMethod: TFunc<T>; const pFreeObjects: Boolean); overload;
    constructor Create(const pNewItemMethod: TFunc<T>; const pFreeObjects: Boolean;
      const pLockerType: TAqLockerType); overload;
    constructor Create(const pNewItemMethod: TFunc<T>; const pLockerType: TAqLockerType); overload;

    procedure AfterConstruction; override;

    function Add: T;
  end;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Class that implements the interface IAqResultList<T>.
  ///   PT-BR:
  ///     Classe que implementa a interface IAqResultList<T>.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  TAqResultList<T> = class(TAqList<T>, IAqResultList<T>)
  strict private
    function GetOnwsResults: Boolean;
    procedure SetOnwsResults(const pValue: Boolean);
  end;

  TAqFakeList<TFrom, TTo> = class(TAqBaseList<TFrom, TTo>)
  strict private
    FConvertFromToMethod: TFunc<TFrom, TTo>;
    FConvertToFromMethod: TFunc<TTo, TFrom>;
  strict protected
    function ConvertFromTo(pFrom: TFrom): TTo; override;
    function ConvertToFrom(pTo: TTo): TFrom; override;
  public
    constructor Create(const pList: TList<TFrom>;
      const pConvertFromToMethod: TFunc<TFrom, TTo>;
      const pConvertToFromMethod: TFunc<TTo, TFrom>;
      const pOwnsList: Boolean = False);
  end;

  TAqInterfacedDictionary<TKey, TValue> = class(TObjectDictionary<TKey, TValue>, IInterface)
  strict private
    FOwnerships: TAqKeyValueOwnerships;
    FDelegatedInterface: IInterface;

    property DelegatedInterface: IInterface read FDelegatedInterface implements IInterface;
  strict protected
    property Ownerships: TAqKeyValueOwnerships read FOwnerships;
  public
    constructor Create(const pOwnerships: TAqKeyValueOwnerships = []);
  end;

  /// ------------------------------------------------------------------------------------------------------------------
  TAqDictionary<TKey, TValue> = class(TAqInterfacedDictionary<TKey, TValue>, IAqDictionary<TKey, TValue>)
  strict private
    FLocker: IAqLocker;

    function VerifyIfHasLocker: Boolean;
    procedure AssertUsingLocker;

    procedure ReleaseValueIfNecessary(const pValue: TValue);
  public
    constructor Create; overload;
    constructor Create(const pOwnerships: TAqKeyValueOwnerships); overload;
    constructor Create(const pOwnerships: TAqKeyValueOwnerships; const pLockerType: TAqLockerType); overload;
    constructor Create(const pLockerType: TAqLockerType); overload;

    function GetCount: Int32;

    procedure BeginRead;
    procedure EndRead;
    procedure BeginWrite;
    procedure EndWrite;

    procedure ExecuteLockedForReading(const pMethod: TProc); overload;
    procedure ExecuteLockedForReading(const pMethod: TProc<IAqDictionary<TKey, TValue>>); overload;
    procedure ExecuteLockedForWriting(const pMethod: TProc); overload;
    procedure ExecuteLockedForWriting(const pMethod: TProc<IAqDictionary<TKey, TValue>>); overload;

    function LockAndTryGetValue(const pKey: TKey; out pValue: TValue): Boolean;
    function LockAndAdd(const pKey: TKey; const pValue: TValue): Boolean;
    procedure LockAndAddOrSetValue(const pKey: TKey; const pValue: TValue);

    function Add(const pKey: Tkey; const pValue: TValue): Boolean;

    function GetOrCreate(const pKey: TKey; const pCreateItemMethod: TFunc<TValue>;
      const pCreateItemLockerBehaviour: TAqCreateItemLockerBehaviour = HoldLockerWhileCreating): TValue;

    property HasLocker: Boolean read VerifyIfHasLocker;
  end;

  TAqIDGenerator = class
  public
    class function Generate: TAqID;
  end;

  TAqIDDictionary<TValue> = class(TAqDictionary<TAqID, TValue>, IAqIDDictionary<TValue>)
  public
    constructor Create; overload;
    constructor Create(const pOwnsValues: Boolean); overload;
    constructor Create(const pOwnsValues: Boolean; const pLockerType: TAqLockerType); overload;
    constructor Create(const pLockerType: TAqLockerType); overload;

    function Add(const pValue: TValue): TAqID; overload;
    function Add(const pCreateItemMethod: TFunc<TAqID, TValue>): TAqID; overload;
  end;

  TAqComparer<T> = class(TComparer<T>)
  strict private
    FComparerFunction: TFunc<T, T, Int32>;
  public
    constructor Create(const pComparerFunction: TFunc<T, T, Int32>);
    function Compare(const Left, Right: T): Int32; override;
  end;

resourcestring
  StrCouldNotAddTheItemToTheList = 'Could not add the item to the list.';
  StrCouldNotDeleteTheItemFromTheList = 'Could not delete the item from the list.';
  StrCouldNotInsertTheItemToTheList = 'Could not insert the item to the list.';
  StrCouldNotExchangeTheListItems = 'Could not exchange the list items.';
  StrItWasNotPossibleToGetTheItemFromIndexD = 'It was not possible to get the item from index %d.';
  StrItWasNotPossibleToGetTheFirstItemFromTheList = 'It was not possible to get the first item from the list.';
  StrItWasNotPossibleToGetTheLastItemFromTheList = 'It was not possible to get the last item from the list.';
  StrFailedToTraverseTheAVLTree = 'Failed to traverse the AVL tree.';
  StrFaliedWhenCleaningTheTree = 'Falied when cleaning the tree.';
  StrCouldNotAddTheValueToTheTree = 'Could not add the value to the tree.';
  StrFailedWhenTryingToFindAValueInTheTree = 'Failed when trying to find a value in the tree.';
  StrFailedWhenTryingToDeleteAValueInTheTree = 'Failed when trying to delete a value in the tree.';
  StrThisListDoesntHaveALocker = 'This list doesnt have a locker.';
  StrThisDictionaryDoesntHaveALocker = 'This dictionary doesnt have a locker.';
  StrFailedWhenGeneratingUniqueID = 'Failed when generating unitque ID.';

implementation

uses
  System.TypInfo,
  System.Math,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers.Rtti,
  AqDrop.Core.Generics.Releaser;

{ TAqWritableList<T> }

procedure TAqWritableList<T>.Delete(const pIndex: Int32);
begin
  try
    GetInternalList.Delete(pIndex);
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create(StrCouldNotDeleteTheItemFromTheList));
    end;
  end;
end;

procedure TAqWritableList<T>.DeleteItem(const pItem: T);
begin
  try
    Delete(IndexOf(pItem));
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create('It was not possible to delete the specified item.'));
    end;
  end;
end;

procedure TAqWritableList<T>.ExecuteLockedForReading(const pMethod: TProc<IAqWritableList<T>>);
begin
  ExecuteLockedForReading(
    procedure
    begin
      pMethod(Self);
    end);
end;

procedure TAqWritableList<T>.ExecuteLockedForReading(const pMethod: TProc);
begin
  AssertUsingLocker;

  BeginRead;

  try
    pMethod;
  finally
    EndRead;
  end;
end;

procedure TAqWritableList<T>.ExecuteLockedForWriting(const pMethod: TProc<IAqWritableList<T>>);
begin
  ExecuteLockedForWriting(
    procedure
    begin
      pMethod(Self);
    end);
end;

procedure TAqWritableList<T>.ExecuteLockedForWriting(const pMethod: TProc);
begin
  AssertUsingLocker;

  BeginWrite;

  try
    pMethod;
  finally
    EndWrite;
  end;
end;

procedure TAqWritableList<T>.ExecWithReleaseOff(const pMethod: TProc);
var
  lFreeObjects: Boolean;
begin
  lFreeObjects := FFreeObjects;

  try
    FFreeObjects := False;

    pMethod;
  finally
    FFreeObjects := lFreeObjects;
  end;
end;

function TAqWritableList<T>.GetComparer: IComparer<T>;
begin
  Result := FComparer;
end;

function TAqWritableList<T>.GetReadOnlyList: IAqReadableList<T>;
begin
//  if not Assigned(FReadOnlyList) then
//  begin
//    FReadOnlyList := TAqReadableList<T>.Create(List);
//  end;
//
//  Result := FReadOnlyList;
  Result := Self; {TODO 3 -oTatu -cMelhoria: estudar efeitos de remover esse método, uma vez que a lista agora preenche esse requisito por interface}
end;

procedure TAqWritableList<T>.AssertUsingLocker;
begin
  if not HasLocker then
  begin
    raise EAqInternal.Create(StrThisListDoesntHaveALocker);
  end;
end;

procedure TAqWritableList<T>.BeginRead;
begin
  AssertUsingLocker;

  FLocker.BeginRead;
end;

procedure TAqWritableList<T>.BeginWrite;
begin
  AssertUsingLocker;

  FLocker.BeginWrite;
end;

procedure TAqWritableList<T>.Clear;
begin
  GetInternalList.Clear;
end;

constructor TAqWritableList<T>.Create;
begin
  Create(False, TAqLockerType.lktNone);
end;

constructor TAqWritableList<T>.Create(const pFreeObjects: Boolean);
begin
  Create(pFreeObjects, TAqLockerType.lktNone);
end;

constructor TAqWritableList<T>.Create(const pLockerType: TAqLockerType);
begin
  Create(False, pLockerType);
end;

constructor TAqWritableList<T>.Create(const pFreeObjects: Boolean; const pLockerType: TAqLockerType);
var
  lInternalList: TList<T>;
begin
  lInternalList := TList<T>.Create;

  inherited Create(lInternalList, True);

  FLocker := TAqLockerFactory.CreateLocker(pLockerType);

  lInternalList.OnNotify := ListNotifier;
  FFreeObjects := pFreeObjects;
end;

procedure TAqWritableList<T>.ListNotifier(pSender: TObject; const pItem: T; pAction: TCollectionNotification);
begin
  if FFreeObjects and (pAction = cnRemoved) then
  begin
    TAqGenericReleaser.TryToRelease<T>(pItem);
  end;
end;

procedure TAqWritableList<T>.SetComparer(pValue: IComparer<T>);
begin
  FComparer := pValue;
end;

procedure TAqWritableList<T>.Sort;
begin
  GetInternalList.Sort(FComparer);
end;

procedure TAqWritableList<T>.Sort(const pComparerFunction: TFunc<T, T, Int32>);
var
  lComparer: IComparer<T>;
begin
  lComparer := TAqComparer<T>.Create(pComparerFunction);
  GetInternalList.Sort(lComparer);
end;

procedure TAqWritableList<T>.Sort(pComparer: IComparer<T>);
begin
  GetInternalList.Sort(pComparer);
end;

function TAqWritableList<T>.VerifyIfHasLocker: Boolean;
begin
  Result := Assigned(FLocker);
end;

procedure TAqWritableList<T>.EndRead;
begin
  AssertUsingLocker;

  FLocker.EndRead;
end;

procedure TAqWritableList<T>.EndWrite;
begin
  AssertUsingLocker;

  FLocker.EndWrite;
end;

procedure TAqWritableList<T>.Exchange(const pIndex1, pIndex2: Int32);
begin
  try
    GetInternalList.Exchange(pIndex1, pIndex2);
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create(StrCouldNotExchangeTheListItems));
    end;
  end;
end;

{ TAqList<T> }

function TAqList<T>.Add(const pItem: T): Int32;
begin
  try
    Result := GetInternalList.Add(pItem);
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create(StrCouldNotAddTheItemToTheList));
    end;
  end;
end;

function TAqList<T>.Extract(const pIndex: Int32): T;
var
  lResult: T;
begin
  ExecWithReleaseOff(
    procedure
    var
      lInternalList: TList<T>;
    begin
      lInternalList := GetInternalList;
      lResult := lInternalList[pIndex];
      lInternalList.Delete(pIndex);
    end);

  Result := lResult;
end;


procedure TAqList<T>.ExtractAllTo(pList: IAqList<T>);
var
  lItem: T;
begin
  FreeObjects := False;

  for lItem in Self do
  begin
    pList.Add(lItem);
  end;

  Clear;
end;

function TAqList<T>.GetExtractableList: IAqExtractableList<T>;
begin
  Result := Self;
end;

procedure TAqList<T>.Insert(const pIndex: Int32; const pItem: T);
begin
  try
    GetInternalList.Insert(pIndex, pItem);
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create(StrCouldNotInsertTheItemToTheList));
    end;
  end;
end;

procedure TAqList<T>.SetItem(const pIndex: Int32; const pItem: T);
begin
  try
    GetInternalList[pIndex] := pItem;;
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.CreateFmt('It was not possible to get the item from index %d.', [pIndex]));
    end;
  end;
end;

procedure TAqList<T>.ExchangeList(const pIndex: Int32; const pNewList: TAqList<T>);
begin
  pNewList.Add(Items[pIndex]);

  ExecWithReleaseOff(
    procedure
    begin
      Delete(pIndex);
    end);
end;

{ TAqResultList<T> }

function TAqResultList<T>.GetOnwsResults: Boolean;
begin
  Result := FreeObjects;
end;

procedure TAqResultList<T>.SetOnwsResults(const pValue: Boolean);
begin
  FreeObjects := pValue;
end;

{ TAqBaseList<TFrom, TTo> }

function TAqBaseList<TFrom, TTo>.Contains(const pValue: TTo): Boolean;
begin
  Result := IndexOf(pValue) >= 0;
end;

constructor TAqBaseList<TFrom, TTo>.Create(const pList: TList<TFrom>; const pOwnsList: Boolean);
begin
  FInternalList := pList;
  FOwnsList := pOwnsList;
end;

destructor TAqBaseList<TFrom, TTo>.Destroy;
begin
  if FOwnsList then
  begin
    FInternalList.Free;
  end;

  inherited;
end;

function TAqBaseList<TFrom, TTo>.GetEnumerator: TEnumerator<TTo>;
begin
  Result := TEnumerator.Create(Self);
end;

function TAqBaseList<TFrom, TTo>.GetInternalList: TList<TFrom>;
begin
  Result := FInternalList;
end;

function TAqBaseList<TFrom, TTo>.GetItem(const pIndex: Int32): TTo;
begin
  try
    Result := ConvertFromTo(GetInternalList[pIndex]);
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.CreateFmt(StrItWasNotPossibleToGetTheItemFromIndexD, [pIndex]));
    end;
  end;
end;

function TAqBaseList<TFrom, TTo>.GetItemTypeName: string;
begin
  Result := TAqRtti.&Implementation.GetType(TypeInfo(TTo)).QualifiedName;
end;

function TAqBaseList<TFrom, TTo>.GetIterator: IAqIterator<TTo>;
begin
  Result := TAqIterator<TTo>.Create(Self);
end;

function TAqBaseList<TFrom, TTo>.GetCount: Int32;
begin
  Result := GetInternalList.Count;
end;

function TAqBaseList<TFrom, TTo>.IndexOf(const pValue: TTo): Int32;
begin
  Result := GetInternalList.IndexOf(ConvertToFrom(pValue));
end;

function TAqBaseList<TFrom, TTo>.Find(const pMatchFunction: TFunc<TTo, Boolean>; out pIndex: Int32): Boolean;
var
  lI: Int32;
begin
  Result := False;
  lI := 0;

  while not Result and (lI < Count) do
  begin
    Result := pMatchFunction(Items[lI]);

    if Result then
    begin
      pIndex := lI;
    end;

    Inc(lI);
  end;
end;

function TAqBaseList<TFrom, TTo>.GetFirst: TTo;
begin
  try
    Result := ConvertFromTo(GetInternalList.First);
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create(StrItWasNotPossibleToGetTheFirstItemFromTheList));
    end;
  end;
end;

function TAqBaseList<TFrom, TTo>.GetLast: TTo;
begin
  try
    Result := ConvertFromTo(GetInternalList.Last);
  except
    on E: Exception do
    begin
      E.RaiseOuterException(EAqInternal.Create(StrItWasNotPossibleToGetTheLastItemFromTheList));
    end;
  end;
end;

function TAqBaseList<TFrom, TTo>.Find(const pItem: TTo; out pIndex: Int32): Boolean;
begin
  pIndex := IndexOf(pItem);
  Result := pIndex >= 0;
end;

function TAqBaseList<TFrom, TTo>.Find(const pMatchFunction: TFunc<TTo, Boolean>): Boolean;
var
  lIndex: Int32;
begin
  Result := Find(pMatchFunction, lIndex);
end;

{ TAqIDGenerator }

class function TAqIDGenerator.Generate: TAqID;
var
  lI: Int8;
begin
  repeat
    Result := 0;
    for lI := 1 to SizeOf(Result) do
    begin
      Result := (Result shl 8) + UInt8(Random(High(UInt8) + 1));
    end;
  until not Result.IsEmpty;
end;

{ TAqIDDictionary<TValue> }

function TAqIDDictionary<TValue>.Add(const pValue: TValue): TAqID;
begin
  Result := Add(
    function(pNewID: TAqID): TValue
    begin
      Result := pValue;
    end);
end;

function TAqIDDictionary<TValue>.Add(const pCreateItemMethod: TFunc<TAqID, TValue>): TAqID;
var
  lAttempts: UInt16;
  lContainsID: Boolean;
begin
  lAttempts := 1000;

  repeat
    Result := TAqIDGenerator.Generate;

    lContainsID := ContainsKey(Result);

    if lContainsID then
    begin
      Dec(lAttempts);
      if lAttempts = 0 then
      begin
        raise EAqInternal.Create('To many attempts while trying to generate a new ID to the dictionary.');
      end;
    end;
  until not lContainsID;

  inherited Add(Result, pCreateItemMethod(Result));
end;

constructor TAqIDDictionary<TValue>.Create;
begin
  Create(False, TAqLockerType.lktNone);
end;

constructor TAqIDDictionary<TValue>.Create(const pOwnsValues: Boolean);
begin
  Create(pOwnsValues, TAqLockerType.lktNone);
end;

constructor TAqIDDictionary<TValue>.Create(const pOwnsValues: Boolean; const pLockerType: TAqLockerType);
begin
  if pOwnsValues then
  begin
    inherited Create([TAqKeyValueOwnership.kvoValue], pLockerType);
  end else begin
    inherited Create([], pLockerType);
  end;
end;

constructor TAqIDDictionary<TValue>.Create(const pLockerType: TAqLockerType);
begin
  Create(False, pLockerType);
end;

{ TAqDictionary<TKey, TValue> }

function TAqDictionary<TKey, TValue>.Add(const pKey: Tkey; const pValue: TValue): Boolean;
begin
  Result := not ContainsKey(pKey);

  if Result then
  begin
    inherited Add(pKey, pValue);
  end;
end;

procedure TAqDictionary<TKey, TValue>.ExecuteLockedForReading(const pMethod: TProc);
begin
  AssertUsingLocker;

  BeginRead;

  try
    pMethod;
  finally
    EndRead;
  end;
end;

procedure TAqDictionary<TKey, TValue>.ExecuteLockedForReading(const pMethod: TProc<IAqDictionary<TKey, TValue>>);
begin
  ExecuteLockedForReading(
    procedure
    begin
      pMethod(Self);
    end);
end;

procedure TAqDictionary<TKey, TValue>.ExecuteLockedForWriting(const pMethod: TProc);
begin
  AssertUsingLocker;

  BeginWrite;

  try
    pMethod;
  finally
    EndWrite;
  end;
end;

procedure TAqDictionary<TKey, TValue>.ExecuteLockedForWriting(const pMethod: TProc<IAqDictionary<TKey, TValue>>);
begin
  ExecuteLockedForWriting(
    procedure
    begin
      pMethod(Self);
    end);
end;

function TAqDictionary<TKey, TValue>.GetCount: Int32;
begin
  Result := Self.Count;
end;

function TAqDictionary<TKey, TValue>.GetOrCreate(const pKey: TKey; const pCreateItemMethod: TFunc<TValue>;
  const pCreateItemLockerBehaviour: TAqCreateItemLockerBehaviour = HoldLockerWhileCreating): TValue;
var
  lItemFound: Boolean;
  lHasLocker: Boolean;
  lNewItem: TValue;
begin
  if not Assigned(pCreateItemMethod) then
  begin
    raise EAqInternal.Create('Create Item method not provided, in GetOrCreate.');
  end;

  lHasLocker := VerifyIfHasLocker;

  lItemFound := pCreateItemLockerBehaviour <> TAqCreateItemLockerBehaviour.GoStraightToWriteRights;

  if lItemFound then
  begin
    if lHasLocker then
    begin
      BeginRead;
    end;

    try
      lItemFound := TryGetValue(pKey, Result);
    finally
      if lHasLocker then
      begin
        EndRead;
      end;
    end;
  end;

  if not lItemFound then
  begin
    if lHasLocker then
    begin
      if pCreateItemLockerBehaviour in [TAqCreateItemLockerBehaviour.GoStraightToWriteRights,
        TAqCreateItemLockerBehaviour.HoldLockerWhileCreating] then
      begin
        BeginWrite;

        try
          if not TryGetValue(pKey, Result) then
          begin
            Result := pCreateItemMethod();
            Add(pKey, Result);
          end;
        finally
          EndWrite;
        end;
      end else begin
        lNewItem := pCreateItemMethod();

        try
          BeginWrite;

          try
            if ContainsKey(pKey) and
              (pCreateItemLockerBehaviour = TAqCreateItemLockerBehaviour.RelaseAndIgnoreNewIfClonflicted) then
            begin
              Result := Self.Items[pKey];
            end else begin
              Result := lNewItem;
              lNewItem := Default(TValue);
              AddOrSetValue(pKey, Result);
            end;
          finally
            EndWrite;
          end;
        finally
          ReleaseValueIfNecessary(lNewItem);
        end;
      end;
    end else begin
      Result := pCreateItemMethod();

      try
        Add(pKey, Result);
      except
        ReleaseValueIfNecessary(Result);
        raise;
      end;
    end;
  end;
end;

function TAqDictionary<TKey, TValue>.LockAndAdd(const pKey: TKey; const pValue: TValue): Boolean;
var
  lResult: Boolean;
begin
  ExecuteLockedForWriting(
    procedure
    begin
      lResult := Add(pKey, pValue);
    end);

  Result := lResult;
end;

procedure TAqDictionary<TKey, TValue>.LockAndAddOrSetValue(const pKey: TKey; const pValue: TValue);
begin
  ExecuteLockedForWriting(
    procedure
    begin
      AddOrSetValue(pKey, pValue);
    end);
end;

function TAqDictionary<TKey, TValue>.LockAndTryGetValue(const pKey: TKey; out pValue: TValue): Boolean;
var
  lResult: Boolean;
  lValue: TValue;
begin
  ExecuteLockedForReading(
    procedure
    begin
      lResult := TryGetValue(pKey, lValue);
    end);

  Result := lResult;
  pValue := lValue;
end;

procedure TAqDictionary<TKey, TValue>.ReleaseValueIfNecessary(const pValue: TValue);
begin
  if TAqKeyValueOwnership.kvoValue in Ownerships then
  begin
    TAqGenericReleaser.TryToRelease<TValue>(pValue);
  end;
end;

function TAqDictionary<TKey, TValue>.VerifyIfHasLocker: Boolean;
begin
  Result := Assigned(FLocker);
end;

procedure TAqDictionary<TKey, TValue>.BeginRead;
begin
  AssertUsingLocker;

  FLocker.BeginRead;
end;

procedure TAqDictionary<TKey, TValue>.BeginWrite;
begin
  AssertUsingLocker;

  FLocker.BeginWrite;
end;

constructor TAqDictionary<TKey, TValue>.Create;
begin
  Create([], TAqLockerType.lktNone);
end;

constructor TAqDictionary<TKey, TValue>.Create(const pOwnerships: TAqKeyValueOwnerships);
begin
  Create(pOwnerships, TAqLockerType.lktNone);
end;

constructor TAqDictionary<TKey, TValue>.Create(const pOwnerships: TAqKeyValueOwnerships;
  const pLockerType: TAqLockerType);
begin
  inherited Create(pOwnerships);

  FLocker := TAqLockerFactory.CreateLocker(pLockerType);
end;

constructor TAqDictionary<TKey, TValue>.Create(const pLockerType: TAqLockerType);
begin
  Create([], pLockerType);
end;

procedure TAqDictionary<TKey, TValue>.EndRead;
begin
  AssertUsingLocker;

  FLocker.EndRead;
end;

procedure TAqDictionary<TKey, TValue>.EndWrite;
begin
  AssertUsingLocker;

  FLocker.EndWrite;
end;

procedure TAqDictionary<TKey, TValue>.AssertUsingLocker;
begin
  if not HasLocker then
  begin
    raise EAqInternal.Create(StrThisDictionaryDoesntHaveALocker);
  end;
end;

{ TAqComparer<T> }

function TAqComparer<T>.Compare(const Left, Right: T): Int32;
begin
  Result := FComparerFunction(Left, Right);
end;

constructor TAqComparer<T>.Create(const pComparerFunction: TFunc<T, T, Int32>);
begin
  FComparerFunction := pComparerFunction;
end;

{ TAqKeyValuePair<K, V> }

constructor TAqKeyValuePair<K, V>.Create(const pKey: K; const pValue: V; const pOwnerships: TAqKeyValueOwnerships = []);
begin
  FOwnerships := pOwnerships;
  FKey := pKey;
  FValue := pValue;
end;

destructor TAqKeyValuePair<K, V>.Destroy;
begin
  if TAqKeyValueOwnership.kvoKey in FOwnerships then
  begin
    TAqGenericReleaser.TryToRelease<K>(FKey);
  end;

  if TAqKeyValueOwnership.kvoValue in FOwnerships then
  begin
    TAqGenericReleaser.TryToRelease<V>(FValue);
  end;

  inherited;
end;

function TAqKeyValuePair<K, V>.GetKey: K;
begin
  Result := FKey;
end;

function TAqKeyValuePair<K, V>.GetValue: V;
begin
  Result := FValue;
end;

{ TAqInterfacedDictionary<TKey, TValue> }

constructor TAqInterfacedDictionary<TKey, TValue>.Create(const pOwnerships: TAqKeyValueOwnerships);
var
  lSet: TDictionaryOwnerships;
begin
  FOwnerships := pOwnerships;
  FDelegatedInterface := TAqDelegatedInterface.Create(Self);

  lSet := [];

  if TAqKeyValueOwnership.kvoKey in pOwnerships then
  begin
    Include(lSet, doOwnsKeys);
  end;

  if TAqKeyValueOwnership.kvoValue in pOwnerships then
  begin
    Include(lSet, doOwnsValues);
  end;

  inherited Create(lSet);
end;

{ TAqManagedList<T> }

function TAqManagedList<T>.Add: T;
begin
  Result := CreateNew;
  GetInternalList.Add(Result);
end;

constructor TAqManagedList<T>.Create(const pNewItemMethod: TFunc<T>);
begin
  Create(pNewItemMethod, False, TAqLockerType.lktNone);
end;

constructor TAqManagedList<T>.Create(const pNewItemMethod: TFunc<T>; const pFreeObjects: Boolean);
begin
  Create(pNewItemMethod, pFreeObjects, TAqLockerType.lktNone);
end;

constructor TAqManagedList<T>.Create(const pNewItemMethod: TFunc<T>; const pFreeObjects: Boolean;
  const pLockerType: TAqLockerType);
begin
  inherited Create(pFreeObjects, pLockerType);

  FNewItemMethod := pNewItemMethod;
end;

procedure TAqManagedList<T>.AfterConstruction;
begin
  inherited;

  if not Assigned(FNewItemMethod) then
  begin
    raise EAqInternal.Create('Managed List created without new item callback mehtod.');
  end;
end;

constructor TAqManagedList<T>.Create(const pNewItemMethod: TFunc<T>; const pLockerType: TAqLockerType);
begin
  Create(pNewItemMethod, False, pLockerType);
end;

function TAqManagedList<T>.CreateNew: T;
begin
  Result := FNewItemMethod();
end;

{ TAqBaseList<TFrom, TTo>.TEnumerator }

constructor TAqBaseList<TFrom, TTo>.TEnumerator.Create(const pList: TAqBaseList<TFrom, TTo>);
begin
  inherited Create;

  FList := pList;
  FIndex := -1;
end;

function TAqBaseList<TFrom, TTo>.TEnumerator.DoGetCurrent: TTo;
begin
  Result := GetCurrent;
end;

function TAqBaseList<TFrom, TTo>.TEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function TAqBaseList<TFrom, TTo>.TEnumerator.GetCurrent: TTo;
begin
  Result := FList[FIndex];
end;

function TAqBaseList<TFrom, TTo>.TEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FList.Count - 1;

  if Result then
  begin
    Inc(FIndex);
  end;
end;

{ TAqReadableList<T> }

function TAqReadableList<T>.ConvertFromTo(pFrom: T): T;
begin
  Result := pFrom;
end;

function TAqReadableList<T>.ConvertToFrom(pTo: T): T;
begin
  Result := pTo;
end;

{ TAqFakeList<TFrom, TTo> }

function TAqFakeList<TFrom, TTo>.ConvertFromTo(pFrom: TFrom): TTo;
begin
  Result := FConvertFromToMethod(pFrom);
end;

function TAqFakeList<TFrom, TTo>.ConvertToFrom(pTo: TTo): TFrom;
begin
  Result := FConvertToFromMethod(pTo);
end;

constructor TAqFakeList<TFrom, TTo>.Create(const pList: TList<TFrom>; const pConvertFromToMethod: TFunc<TFrom, TTo>;
  const pConvertToFromMethod: TFunc<TTo, TFrom>; const pOwnsList: Boolean);
begin
  inherited Create(pList, pOwnsList);

  FConvertFromToMethod := pConvertFromToMethod;
  FConvertToFromMethod := pConvertToFromMethod;
end;

{ TAqIterator<T> }

constructor TAqIterator<T>.Create(pList: IAqReadableList<T>);
begin
  FList := pList;
  Reset;
end;

function TAqIterator<T>.GetCurrentItem: T;
begin
  Result := FList[FCurrentPosition];
end;

function TAqIterator<T>.MoveToNext: Boolean;
begin
  Inc(FCurrentPosition);
  Result := FCurrentPosition < FList.Count;
end;

procedure TAqIterator<T>.Reset;
begin
  FCurrentPosition := -1;
end;

function TAqIterator<T>.VerifyIfIsFinished: Boolean;
begin
  Result := FCurrentPosition >= FList.Count;
end;

{ TAqLockerFactory }

class function TAqLockerFactory.CreateLocker(const pLockerType: TAqLockerType): IAqLocker;
begin
  case pLockerType of
    lktNone:
      Result := nil;
    lktCriticalSection:
      Result := TAqCriticalSectionLocker.Create;
    lktMultiReadeExclusiveWriter:
      Result := TAqMultiReadExclusiveWriteLocker.Create;
  else
    raise EAqInternal.Create('Unexpected locker type.');
  end;
end;

{ TAqCriticalSectionLocker }

procedure TAqCriticalSectionLocker.BeginRead;
begin
  FCriticalSection.Enter;
end;

procedure TAqCriticalSectionLocker.BeginWrite;
begin
  FCriticalSection.Enter;
end;

constructor TAqCriticalSectionLocker.Create;
begin
  FCriticalSection := TCriticalSection.Create;
end;

destructor TAqCriticalSectionLocker.Destroy;
begin
  FCriticalSection.Free;

  inherited;
end;

procedure TAqCriticalSectionLocker.EndRead;
begin
  FCriticalSection.Leave;
end;

procedure TAqCriticalSectionLocker.EndWrite;
begin
  FCriticalSection.Leave;
end;

{ TAqMultiReadeExclusiveWriterSynchronizer }

procedure TAqMultiReadExclusiveWriteLocker.BeginRead;
begin
  FMultiReadeExclusiveWriterSynchronizer.BeginRead;
end;

procedure TAqMultiReadExclusiveWriteLocker.BeginWrite;
begin
  FMultiReadeExclusiveWriterSynchronizer.BeginWrite;
end;

constructor TAqMultiReadExclusiveWriteLocker.Create;
begin
  FMultiReadeExclusiveWriterSynchronizer := TMultiReadExclusiveWriteSynchronizer.Create;
end;

destructor TAqMultiReadExclusiveWriteLocker.Destroy;
begin
  FMultiReadeExclusiveWriterSynchronizer.Free;

  inherited;
end;

procedure TAqMultiReadExclusiveWriteLocker.EndRead;
begin
  FMultiReadeExclusiveWriterSynchronizer.EndRead;
end;

procedure TAqMultiReadExclusiveWriteLocker.EndWrite;
begin
  FMultiReadeExclusiveWriterSynchronizer.EndWrite;
end;

end.
