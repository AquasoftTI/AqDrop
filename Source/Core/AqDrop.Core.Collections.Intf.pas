unit AqDrop.Core.Collections.Intf;

interface

uses
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections,
  AqDrop.Core.Types;

type
  IAqKeyValuePair<K, V> = interface
    ['{FF1F3ECB-DE5B-47E5-AB59-B512FB5AE003}']

    function GetKey: K;
    function GetValue: V;

    property Key: K read GetKey;
    property Value: V read GetValue;
  end;

  IAqLocker = interface
    ['{52F78214-8838-471E-9C75-9AF6BF5FE354}']

    procedure BeginRead;
    procedure EndRead;
    procedure BeginWrite;
    procedure EndWrite;
  end;

  IAqList<T> = interface;

  {TODO 3 -oTatu -cMelhoria: procurar possíveis pontos do código que podem ter laços baseados em índices e podem ser alterados por iterators}
  IAqIterator<T> = interface
    ['{E832C3D8-62FB-414F-A7C7-A01ADC21829B}']

    function MoveToNext: Boolean;
    function VerifyIfIsFinished: Boolean;
    procedure Reset;
    function GetCurrentItem: T;

    property CurrentItem: T read GetCurrentItem;
    property IsFinished: Boolean read VerifyIfIsFinished;
  end;

  IAqReadableList<T> = interface
    ['{9A3301DE-8746-43F4-8E8B-4E46E2C1B771}']
    /// <returns>
    ///   EN-US:
    ///     Returns the items count of the list.
    ///   PT-BR:
    ///     Retorna a quantidade de itens da lista.
    /// </returns>
    function GetCount: Int32;
    /// <summary>
    ///   EN-US:
    ///     Allows the access to the items by their indexes.
    ///   PT-BR:
    ///     Permite o acesso aos itens através de seus respectivos índices.
    /// </summary>
    /// <returns>
    ///   EN-US:
    ///     Returns the item of the gived index.
    ///   PT-BR:
    ///     Retorna o item correspondente ao índice informado.
    /// </returns>
    function GetItem(const pIndex: Int32): T;

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
    function IndexOf(const pValue: T): Int32; overload;
    function Contains(const pValue: T): Boolean;

    function Find(const pMatchFunction: TFunc<T, Boolean>): Boolean; overload;
    function Find(const pMatchFunction: TFunc<T, Boolean>; out pIndex: Int32): Boolean; overload;
    function Find(const pItem: T; out pIndex: Int32): Boolean; overload;

    /// <summary>
    ///   EN-US:
    ///     Function to obtain the first item of the list.
    ///   PT-BR:
    ///     Função para obtenção do primeiro item da lista.
    /// </summary>
    /// <returns>
    ///   EN-US:
    ///     First item of the list.
    ///   PT-BR:
    ///     Primeiro item da lista.
    /// </returns>
    function GetFirst: T;
    /// <summary>
    ///   EN-US:
    ///     Function to obtain the last item of the list.
    ///   PT-BR:
    ///     Função para obtenção do último item da lista.
    /// </summary>
    /// <returns>
    ///   EN-US:
    ///     Last item of the list.
    ///   PT-BR:
    ///     Último item da lista.
    /// </returns>
    function GetLast: T;

    function GetItemTypeName: string;
    function GetEnumerator: TEnumerator<T>;
    function GetIterator: IAqIterator<T>;

    /// <summary>
    ///   EN-US:
    ///     Returns the items count of the list.
    ///   PT-BR:
    ///     Retorna a lista de itens da lista.
    /// </summary>
    property Count: Int32 read GetCount;

    /// <summary>
    ///   EN-US:
    ///     Allows the access to the items by their indexes.
    ///   PT-BR:
    ///     Permite o acesso aos itens através de seus respectivos índices.
    /// </summary>
    property Items[const pIndex: Int32]: T read GetItem; default;

    property First: T read GetFirst;
    property Last: T read GetLast;
  end;

  IAqExtractableList<T> = interface
    ['{AF93B4F7-071B-4431-8594-051A02C6BBF8}']

    function Extract(const pIndex: Int32 = 0): T;
    procedure ExtractAllTo(pList: IAqList<T>);
  end;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Interface for read only lists returned by methods, but with some data manipulation methods,
  ///       like sort and extract.
  ///   PT-BR:
  ///     Interface para listas somente leitura retornada por métodos, mas com alguns métodos de manipulação dos dados,
  ///       como ordenar e extrair.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  IAqResultList<T> = interface(IAqReadableList<T>)
    ['{1574A9A4-0650-4E43-AF08-5147A6068E35}']

    function GetOnwsResults: Boolean;
    procedure SetOnwsResults(const pValue: Boolean);
    function GetComparer: IComparer<T>;
    procedure SetComparer(pValue: IComparer<T>);

    function Extract(const pIndex: Int32 = 0): T;
    procedure ExtractAllTo(pList: IAqList<T>);

    procedure Sort; overload;
    procedure Sort(const pComparerFunction: TFunc<T, T, Int32>); overload;
    procedure Sort(pComparer: IComparer<T>); overload;

    function GetExtractableList: IAqExtractableList<T>;

    property Comparer: IComparer<T> read GetComparer write SetComparer;
    property OnwsResults: Boolean read GetOnwsResults write SetOnwsResults;
    property ExtractableList: IAqExtractableList<T> read GetExtractableList;
  end;

  IAqWritableList<T> = interface(IAqReadableList<T>)
    ['{111B4C3F-EE96-4EE4-BFA3-09456C050A99}']
    procedure Delete(const pIndex: Int32);
    procedure DeleteItem(const pItem: T);
    procedure Exchange(const pIndex1, pIndex2: Int32);

    procedure Clear;

    function GetComparer: IComparer<T>;
    procedure SetComparer(pValue: IComparer<T>);

    function GetReadOnlyList: IAqReadableList<T>;

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
  end;

  IAqList<T> = interface(IAqWritableList<T>)
    ['{AE2187BA-592A-4D0B-8C31-5FDEB6025341}']

    procedure SetItem(const pIndex: Int32; const pItem: T);
    procedure Insert(const pIndex: Int32; const pItem: T);

    function Add(const pItem: T): Int32;

    function Extract(const pIndex: Int32 = 0): T;
    procedure ExtractAllTo(pList: IAqList<T>);

    function GetExtractableList: IAqExtractableList<T>;

    property Items[const pIndex: Int32]: T read GetItem write SetItem; default;
    property ExtractableList: IAqExtractableList<T> read GetExtractableList;
  end;

  IAqManagedList<T> = interface(IAqWritableList<T>)
    ['{704294BF-F55C-42F6-8833-5FEFB5519055}']

    function CreateNew: T;
    function Add: T;
  end;

  TAqCreateItemLockerBehaviour = (
    GoStraightToWriteRights,
    HoldLockerWhileCreating,
    RelaseAndIgnorePreviousIfClonflicted,
    RelaseAndIgnoreNewIfClonflicted);

  IAqDictionary<TKey, TValue> = interface
    ['{F6E7723C-1B3A-4114-8713-6FED5F2098E9}']

    procedure Clear;
    function ContainsKey(const Key: TKey): Boolean;
    function GetItem(const Key: TKey): TValue;
    procedure SetItem(const Key: TKey; const Value: TValue);
    function TryGetValue(const Key: TKey; out Value: TValue): Boolean;
    procedure Remove(const Key: TKey);
    function GetKeys: TDictionary<TKey, TValue>.TKeyCollection;
    function GetValues: TDictionary<TKey, TValue>.TValueCollection;
    procedure AddOrSetValue(const Key: TKey; const Value: TValue);
    function GetCount: Int32;

    function VerifyIfHasLocker: Boolean;

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

    function GetOrCreate(const pKey: TKey; const pCreateItemMethod: TFunc<TValue>;
      const pCreateItemLockerBehaviour: TAqCreateItemLockerBehaviour = HoldLockerWhileCreating): TValue;

    function Add(const pKey: Tkey; const pValue: TValue): Boolean;

    property HasLocker: Boolean read VerifyIfHasLocker;
    property Keys: TDictionary<TKey,TValue>.TKeyCollection read GetKeys;
    property Values: TDictionary<TKey,TValue>.TValueCollection read GetValues;
    property Items[const Key: TKey]: TValue read GetItem write SetItem; default;
    property Count: Int32 read GetCount;
  end;

  IAqIDDictionary<TValue> = interface(IAqDictionary<TAqID, TValue>)
    ['{BCAE60F6-F78E-4E5D-B2C4-0906FD8E6C14}']

    function Add(const pValue: TValue): TAqID; overload;
    function Add(const pCreateItemMethod: TFunc<TAqID, TValue>): TAqID; overload;
  end;

{TODO 3 -oTatu -cDesejável: criar interface específica para cache, com controle de descarte de cache (cache expire) built in}

implementation

end.
