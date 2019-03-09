unit AqDrop.Core.Helpers.Rtti.Impl;

interface

uses
  System.TypInfo,
  System.Rtti,
  AqDrop.Core.Collections.Intf,
  AqDrop.Core.Helpers.Rtti;

type
  TAqRttiImplementation = class(TAqRtti)
  strict private
    FContext: TRttiContext;
    FTypesCache: IAqDictionary<PTypeInfo, TRttiType>;
    FTypesPerName: IAqDictionary<string, PTypeInfo>;
  strict protected
    function DoGetType(pType: PTypeInfo): TRttiType; override;
    function DoFindType(pQualifiedName: string): TRttiType; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  AqDrop.Core.Collections;

{ TAqRttiImplementation }

constructor TAqRttiImplementation.Create;
begin
  FContext := TRttiContext.Create;
  FTypesCache := TAqDictionary<PTypeInfo, TRttiType>.Create([kvoValue], TAqLockerType.lktMultiReadeExclusiveWriter);
  FTypesPerName := TAqDictionary<string, PTypeInfo>.Create(TAqLockerType.lktMultiReadeExclusiveWriter);
end;

destructor TAqRttiImplementation.Destroy;
begin
  FTypesCache := nil; // força a eliminação do dicionário antes da liberação do contexto.
  FContext.Free;

  inherited;
end;

function TAqRttiImplementation.DoFindType(pQualifiedName: string): TRttiType;
var
  lTypeInfo: PTypeinfo;
begin
  Result := nil;

  lTypeInfo := FTypesPerName.GetOrCreate(pQualifiedName,
    function: PTypeInfo
    var
      lRttiType: TRttiType;
    begin
      Result := nil;
      lRttiType := FContext.FindType(pQualifiedName);

      if Assigned(lRttiType) then
      begin
        Result := lRttiType.Handle;
      end;
    end, TAqCreateItemLockerBehaviour.RelaseAndIgnoreNewIfClonflicted);

  if Assigned(lTypeInfo) then
  begin
    Result := GetType(lTypeInfo);
  end;
end;

function TAqRttiImplementation.DoGetType(pType: PTypeInfo): TRttiType;
begin
  Result := FTypesCache.GetOrCreate(pType,
    function: TRttiType
    begin
      Result := FContext.GetType(pType);
    end, TAqCreateItemLockerBehaviour.HoldLockerWhileCreating);
end;

initialization
  TAqRtti.SetImplementation(TAqRttiImplementation.Create);

end.
