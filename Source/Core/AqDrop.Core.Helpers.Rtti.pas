unit AqDrop.Core.Helpers.Rtti;

interface

uses
  System.TypInfo,
  System.Rtti;

type
  TAqRtti = class
  strict private
    class var FImplementation: TAqRtti;
    class function GetImplementation: TAqRtti; static;
  private
    class procedure ReleaseImplementation;
  strict protected
    function DoGetType(const pType: PTypeInfo): TRttiType; virtual; abstract;
    function DoTryFindType(const pQualifiedName: string; out pType: TRttiType): Boolean; virtual; abstract;
  public
    function GetType(const pClass: TClass): TRttiType; overload;
    function GetType(const pType: PTypeInfo): TRttiType; overload;
    function FindType(const pQualifiedName: string): TRttiType;
    function TryFindType(const pQualifiedName: string; out pType: TRttiType): Boolean;

    class procedure SetImplementation(const pImplementation: TAqRtti);
    class function VerifyIfHasImplementationSetted: Boolean;

    class property &Implementation: TAqRtti read GetImplementation;
  end;

  {TODO -oTatu: levar esse helper para a sua própria unit}
  TRttiInterfaceTypeHelper = class helper for TRttiInterfaceType
  public
    function IsType(const pTypeInfo: PTypeInfo): Boolean;
  end;

implementation

uses
  System.SysUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Generics.Releaser;

{ TAqRtti }

function TAqRtti.FindType(const pQualifiedName: string): TRttiType;
begin
  if not DoTryFindType(pQualifiedName, Result) then
  begin
    raise EAqInternal.CreateFmt('It wasn''t possible to find the type %s.', [pQualifiedName]);
  end;
end;

function TAqRtti.GetType(const pClass: TClass): TRttiType;
begin
  Result := GetType(pClass.ClassInfo);
end;

class function TAqRtti.GetImplementation: TAqRtti;
begin
  if not Assigned(FImplementation) then
  begin
    raise EAqInternal.Create('No implementation provided for TAqRtti features.');
  end;

  Result := FImplementation;
end;

function TAqRtti.GetType(const pType: PTypeInfo): TRttiType;
begin
  Result := DoGetType(pType);
end;

class procedure TAqRtti.ReleaseImplementation;
begin
  FreeAndNil(FImplementation);
end;

class procedure TAqRtti.SetImplementation(const pImplementation: TAqRtti);
begin
  ReleaseImplementation;

  FImplementation := pImplementation;
end;

function TAqRtti.TryFindType(const pQualifiedName: string; out pType: TRttiType): Boolean;
begin
  Result := DoTryFindType(pQualifiedName, pType);
end;

class function TAqRtti.VerifyIfHasImplementationSetted: Boolean;
begin
  Result := Assigned(FImplementation);
end;

{ TRttiInterfaceTypeHelper }

function TRttiInterfaceTypeHelper.IsType(const pTypeInfo: PTypeInfo): Boolean;
begin
  Result := (Handle = pTypeInfo) or (Assigned(BaseType) and BaseType.IsType(pTypeInfo));
end;

initialization

finalization
  TAqRtti.ReleaseImplementation;


end.
