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
    function DoGetType(pType: PTypeInfo): TRttiType; virtual; abstract;
    function DoFindType(pQualifiedName: string): TRttiType; virtual; abstract;
  public
    function GetType(pClass: TClass): TRttiType; overload;
    function GetType(pType: PTypeInfo): TRttiType; overload;
    function FindType(pQualifiedName: string): TRttiType;

    class procedure SetImplementation(const pImplementation: TAqRtti);

    class property &Implementation: TAqRtti read GetImplementation;
  end;

implementation

uses
  System.SysUtils,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Generics.Releaser;

{ TAqRtti }

function TAqRtti.FindType(pQualifiedName: string): TRttiType;
begin
  Result := DoFindType(pQualifiedName);
end;

function TAqRtti.GetType(pClass: TClass): TRttiType;
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

function TAqRtti.GetType(pType: PTypeInfo): TRttiType;
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

initialization

finalization
  TAqRtti.ReleaseImplementation;


end.
