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
    FTypesPerName: IAqDictionary<string, TRttiType>;
  strict protected
    function DoGetType(const pType: PTypeInfo): TRttiType; override;
    function DoTryFindType(const pQualifiedName: string; out pType: TRttiType): Boolean; override;
  public
    constructor Create;
    destructor Destroy; override;

    class procedure RegisterAsDefaultImplementation;
  end;

implementation

uses
  AqDrop.Core.Collections;

{ TAqRttiImplementation }

constructor TAqRttiImplementation.Create;
begin
  FContext := TRttiContext.Create;
  FTypesCache := TAqDictionary<PTypeInfo, TRttiType>.Create([kvoValue], TAqLockerType.lktMultiReaderExclusiveWriter);
  FTypesPerName := TAqDictionary<string, TRttiType>.Create(TAqLockerType.lktMultiReaderExclusiveWriter);
end;

destructor TAqRttiImplementation.Destroy;
begin
  FTypesCache := nil; // força a eliminação do dicionário antes da liberação do contexto.
  FContext.Free;

  inherited;
end;

function TAqRttiImplementation.DoTryFindType(const pQualifiedName: string; out pType: TRttiType): Boolean;
begin
  pType := FTypesPerName.GetOrCreate(pQualifiedName,
    function: TRttiType
    begin
      Result := FContext.FindType(pQualifiedName);
    end, TAqCreateItemLockerBehaviour.RelaseAndIgnoreNewIfClonflicted);

  Result := Assigned(pType);
end;

class procedure TAqRttiImplementation.RegisterAsDefaultImplementation;
begin
  if not TAqRtti.VerifyIfHasImplementationSetted then
  begin
    TAqRtti.SetImplementation(TAqRttiImplementation.Create);
  end;
end;

function TAqRttiImplementation.DoGetType(const pType: PTypeInfo): TRttiType;
begin
  Result := FTypesCache.GetOrCreate(pType,
    function: TRttiType
    begin
      Result := FContext.GetType(pType);
    end, TAqCreateItemLockerBehaviour.HoldLockerWhileCreating);
end;

initialization
  TAqRttiImplementation.RegisterAsDefaultImplementation;

end.
