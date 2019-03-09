unit AqDrop.DB.Base.Detail;

interface

uses
  System.Generics.Collections,
  AqDrop.Core.Types,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Collections,
  AqDrop.DB.ORM.Attributes,
  AqDrop.DB.ORM.Manager,
  AqDrop.DB.Base;

type
  TAqDBDetail = class(TAqDBBaseObject)
  strict private
    [weak] FORMManager: TAqDBORMManager;
  strict protected
    function GetORMManager: TAqDBORMManager; override;
  public
    constructor Create(const pORMManager: TAqDBORMManager);
  end;

  TAqDBDetailAutoID = class(TAqDBDetail)
  public
    const ID_COLUMN = 'ID';
  strict private
    [AqAutoIncrementColumn(ID_COLUMN)]
    FID: TAqEntityID;
  strict protected
    function GetID: TAqEntityID; override;
  end;

  TAqDBDetailRegularID = class(TAqDBDetail)
  public
    const ID_COLUMN = 'ID';
  strict private
    [AqPrimaryKey(ID_COLUMN)]
    FID: TAqEntityID;
  strict protected
    function GetID: TAqEntityID; override;
  end;

  TAqDBDetailList<T: TAqDBDetail> = class(TAqManagedList<T>)
  strict private
    FMaster: TAqDBBaseObject;
    FLoaded: Boolean;
    FReadableObjectList: IAqReadableList<TObject>;
    FDeletedItens: IAqList<TObject>;
  private
    function GetReadableObjectList: IAqReadableList<TObject>;
    function GetDeletedItens: IAqReadableList<TObject>;
  strict protected
    function GetInternalList: TList<T>; override;
    procedure ListNotifier(pSender: TObject; const pItem: T; pAction: TCollectionNotification); override;

    class function _EnableARCForClass: Boolean; override;
  public
    constructor Create(const pMaster: TAqDBBaseObject; const pFreeDetails: Boolean = True);
    destructor Destroy; override;

    procedure Load;
    procedure Unload;

    property Loaded: Boolean read FLoaded;
  end;

implementation

uses
  System.Rtti,
  AqDrop.Core.Exceptions,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.Helpers.TArray,
  AqDrop.Core.Helpers.TRttiObject,
  AqDrop.Core.Helpers.TRttiMember,
  AqDrop.Core.Helpers.TRttiType,
  AqDrop.Core.Helpers.Rtti,
  AqDrop.DB.ORM.Reader;

type
  TAqDBORMDetail = class(TAqARCObject, IAqDBORMDetail)
  strict private
    FORM: TAqDBORM;
    FMasterMember: TRttiMember;

    function GetORM: TAqDBORM;
    function VerifyIfLazyLoadingIsAvailable: Boolean;

    function GetMemberValueAsList(const pMaster: TObject): TAqDBDetailList<TAqDBDetail>;

    function VerifyIfDetailsAreLoaded(const pMaster: TObject): Boolean;
    function GetItems(const pMaster: TObject): IAqReadableList<TObject>;
    function AddItem(const pMaster: TObject): TObject;
    function VerifyIfDeletedItensAreManaged: Boolean;
    function GetDeletedItens(const pMaster: TObject): IAqReadableList<TObject>;
  public
    constructor Create(const pORM: TAqDBORM; const pMasterMember: TRttiMember);
  end;

  TAqDBORMDetailInterpreter = class(TAqDBORMBaseDetailInterpreter)
  public
    function Interpret(const pRttiMember: TRttiMember; out pORMDetail: IAqDBORMDetail): Boolean; override;
  end;


{ TAqDBORMDetailInterpreter }

function TAqDBORMDetailInterpreter.Interpret(const pRttiMember: TRttiMember;
  out pORMDetail: IAqDBORMDetail): Boolean;
var
  lMemberType: TRttiType;
  lGenericTypeNames: TArray<string>;
  lInternalType: TRttiType;

  function CheckDetailType: Boolean;
  begin
    Result := False;
    lMemberType := pRttiMember.MemberType;

    while not Result and Assigned(lMemberType) do
    begin
      Result := lMemberType.IsGeneric and (lMemberType.GetGenericName = Self.UnitName +  '.TAqDBDetailList<>');

      if not Result then
      begin
        lMemberType := lMemberType.BaseType;
      end;
    end;
  end;

  function CheckUniqueGenericTypeName: Boolean;
  begin
    lGenericTypeNames := lMemberType.GetGenericTypeNames;
    Result := Length(lGenericTypeNames) = 1;
  end;

  function FindInternalType: Boolean;
  begin
    lInternalType := TAqRtti.&Implementation.FindType(lGenericTypeNames[0]);
    Result := Assigned(lInternalType);
  end;
begin
  Result := CheckDetailType and
    CheckUniqueGenericTypeName and
    FindInternalType;

  if Result then
  begin
    pORMDetail := TAqDBORMDetail.Create(
      TAqDBORMReader.Instance.GetORM(lInternalType.AsInstance.MetaclassType),
      pRttiMember);
  end;
end;

{ TAqDBORMDetail }

function TAqDBORMDetail.AddItem(const pMaster: TObject): TObject;
begin
  Result := GetMemberValueAsList(pMaster).Add;
end;

constructor TAqDBORMDetail.Create(const pORM: TAqDBORM; const pMasterMember: TRttiMember);
begin
  FORM := pORM;
  FMasterMember := pMasterMember;
end;

function TAqDBORMDetail.GetDeletedItens(const pMaster: TObject): IAqReadableList<TObject>;
begin
  Result := GetMemberValueAsList(pMaster).GetDeletedItens;
end;

function TAqDBORMDetail.GetItems(const pMaster: TObject): IAqReadableList<TObject>;
begin
  Result := GetMemberValueAsList(pMaster).GetReadableObjectList;
end;

function TAqDBORMDetail.GetMemberValueAsList(const pMaster: TObject): TAqDBDetailList<TAqDBDetail>;
begin
  Result := TAqDBDetailList<TAqDBDetail>(FMasterMember.UniversalGetValue(pMaster).AsObject);
end;

function TAqDBORMDetail.GetORM: TAqDBORM;
begin
  Result := FORM;
end;

function TAqDBORMDetail.VerifyIfDeletedItensAreManaged: Boolean;
begin
  Result := True;
end;

function TAqDBORMDetail.VerifyIfDetailsAreLoaded(const pMaster: TObject): Boolean;
begin
  Result := GetMemberValueAsList(pMaster).Loaded;
end;

function TAqDBORMDetail.VerifyIfLazyLoadingIsAvailable: Boolean;
begin
  Result := True;
end;

{ TAqDBDetailList<T> }

constructor TAqDBDetailList<T>.Create(const pMaster: TAqDBBaseObject; const pFreeDetails: Boolean);
var
  lMethods: TArray<TRttiMethod>;
  lIndex: Int32;
  lConstructor: TRttiMethod;
  lType: TRttiType;
begin
  FMaster := pMaster;
  FDeletedItens := TAqList<TObject>.Create(True);

  lType := TAqRtti.&Implementation.GetType(T);
  lMethods := lType.GetMethods;

  if not TAqArray<TRttiMethod>.SearchItem(lMethods,
    function(pItem: TRttiMethod): Boolean
    var
      lParams: TArray<TRttiParameter>;
    begin
      Result := pItem.IsConstructor;

      if Result then
      begin
        lParams := pItem.GetParameters;
        Result := (Length(lParams) = 1) and (lParams[0].ParamType.QualifiedName = TAqDBORMManager.QualifiedClassName);
      end;
    end, lIndex) then
  begin
    raise EAqInternal.Create('Constructor with a TAqDBORMManager as parameter not found.');
  end;

  lConstructor := lMethods[lIndex];

  inherited Create(
    function: T
    begin
      Result := lConstructor.Invoke(
        lType.AsInstance.MetaclassType, [TValue.From<TAqDBORMManager>(FMaster.ORMManager)]).AsType<T>;
    end, pFreeDetails);
end;

destructor TAqDBDetailList<T>.Destroy;
begin
  FDeletedItens := nil;

  inherited;
end;

function TAqDBDetailList<T>.GetDeletedItens: IAqReadableList<TObject>;
begin
  Result := FDeletedItens;
end;

function TAqDBDetailList<T>.GetInternalList: TList<T>;
begin
  Load;

  Result := inherited;
end;

function TAqDBDetailList<T>.GetReadableObjectList: IAqReadableList<TObject>;
begin
  if not Assigned(FReadableObjectList) then
  begin
    FReadableObjectList := TAqReadableList<TObject>.Create(TList<TObject>(Self.GetInternalList));
  end;

  Result := FReadableObjectList;
end;

procedure TAqDBDetailList<T>.ListNotifier(pSender: TObject; const pItem: T; pAction: TCollectionNotification);
begin
  if Assigned(FDeletedItens) and (pAction = TCollectionNotification.cnRemoved) and (pItem.ID > 0) then
  begin
    FDeletedItens.Add(pItem);
  end else begin
    inherited;
  end;
end;

procedure TAqDBDetailList<T>.Load;
begin
  if not FLoaded then
  begin
    FLoaded := True;

    FMaster.ORMManager.LoadDetails(FMaster, TAqDBORMReader.Instance.GetORM(T),
      function: TObject
      begin
        Result := Self.Add;
      end);
  end;
end;

procedure TAqDBDetailList<T>.Unload;
begin
  if FLoaded then
  begin
    FLoaded := False;
    Clear;
    FDeletedItens.Clear;
  end;
end;

class function TAqDBDetailList<T>._EnableARCForClass: Boolean;
begin
  Result := False;
end;

{ TAqDBDetailAutoID }

function TAqDBDetailAutoID.GetID: TAqEntityID;
begin
  Result := FID;;
end;

{ TAqDBDetailRegularID }

function TAqDBDetailRegularID.GetID: TAqEntityID;
begin
  Result := FID;
end;

{ TAqDBDetail }

constructor TAqDBDetail.Create(const pORMManager: TAqDBORMManager);
begin
  FORMManager := pORMManager;

  inherited Create;
end;

function TAqDBDetail.GetORMManager: TAqDBORMManager;
begin
  Result := FORMManager;
end;

initialization
  TAqDBORMReader.Instance.AddDetailInterpreter(TAqDBORMDetailInterpreter.Create);

end.
