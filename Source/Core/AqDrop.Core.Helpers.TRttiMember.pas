unit AqDrop.Core.Helpers.TRttiMember;

interface

uses
  System.SysUtils,
  System.Rtti;

type
  TAqRttiMemberHelper = class helper for TRttiMember
  strict private
    procedure NotifyUnexpectedRttiMember;
    function GetMemberType: TRttiType;
  public
    procedure Disambiguate(const pCaseField: TProc<TRttiField>; const pCaseProperty: TProc<TRttiProperty>);

    function UniversalGetValue(const pInstance: Pointer): TValue;

    property MemberType: TRttiType read GetMemberType;
  end;

implementation

uses
  AqDrop.Core.Exceptions;

{ TAqRttiMemberHelper }

procedure TAqRttiMemberHelper.Disambiguate(const pCaseField: TProc<TRttiField>;
  const pCaseProperty: TProc<TRttiProperty>);
begin
  if Self is TRttiField then
  begin
    pCaseField(TRttiField(Self));
  end else if Self is TRttiProperty then
  begin
    pCaseProperty(TRttiProperty(Self));
  end else begin
    NotifyUnexpectedRttiMember;
  end;
end;

function TAqRttiMemberHelper.GetMemberType: TRttiType;
var
  lResult: TRttiType;
begin
  Disambiguate(
    procedure(pField: TRttiField)
    begin
      lResult := pField.FieldType;
    end,
    procedure(pProperty: TRttiProperty)
    begin
      lResult := pProperty.PropertyType;
    end);

  Result := lResult;
end;

procedure TAqRttiMemberHelper.NotifyUnexpectedRttiMember;
begin
  raise EAqInternal.CreateFmt('Unexpected Rtti Member (%s).', [Self.QualifiedClassName]);
end;

function TAqRttiMemberHelper.UniversalGetValue(const pInstance: Pointer): TValue;
var
  lResult: TValue;
begin
  Disambiguate(
    procedure(pField: TRttiField)
    begin
      lResult := pField.GetValue(pInstance);
    end,
    procedure(pProperty: TRttiProperty)
    begin
      lResult := pProperty.GetValue(pInstance);
    end);

  Result := lResult;
end;

end.
