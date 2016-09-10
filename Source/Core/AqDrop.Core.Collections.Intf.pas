unit AqDrop.Core.Collections.Intf;

interface

uses
  System.Generics.Collections, AqDrop.Core.AnonymousMethods;

type
  IAqReadList<T> = interface
    /// <returns>
    ///   EN-US:
    ///     Returns the items count of the list.
    ///   PT-BR:
    ///     Retorna a lista de itens da lista.
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
    function GetItem(pIndex: Int32): T;

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

    function Find(const pMatchFunction: TAqFunctionGenericParameterReturnBoolean<T>; out pValue: T): Boolean; overload;

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
    property Items[pIndex: Int32]: T read GetItem; default;

    property First: T read GetFirst;
    property Last: T read GetLast;

    function GetEnumerator: TEnumerator<T>;
  end;

  /// ------------------------------------------------------------------------------------------------------------------
  /// <summary>
  ///   EN-US:
  ///     Interface for lists returned by methods. Used to automatically release lists by references counting.
  ///   PT-BR:
  ///     Interface para listas retornadas por métodos. Utilizada para liberar listas automaticamente através da
  ///     contagem de referências de interfaces.
  /// </summary>
  /// ------------------------------------------------------------------------------------------------------------------
  IAqResultList<T> = interface(IAqReadList<T>)
    ['{1574A9A4-0650-4E43-AF08-5147A6068E35}']
  end;

implementation

end.
