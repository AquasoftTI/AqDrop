unit AqDrop.Core.Helpers.TRttiTypeName;

interface

type
  TAqRttiTypeName = class
    class procedure AssertIsGeneric(const pTypeName: string; out pLessIndex: Int32);
  public
    class function VerifyIfIsGeneric(const pTypeName: string; out pLessIndex: Int32): Boolean; overload;
    class function VerifyIfIsGeneric(const pTypeName: string): Boolean; overload;
    class function GetGenericName(const pTypeName: string): string;
    class function GetGenericTypeNames(const pTypeName: string): TArray<string>;
  end;

implementation

uses
  AqDrop.Core.Exceptions,
  AqDrop.Core.Helpers;

{ TAqRttiTypeName }

class procedure TAqRttiTypeName.AssertIsGeneric(const pTypeName: string; out pLessIndex: Int32);
begin
  if not VerifyIfIsGeneric(pTypeName, pLessIndex) then
  begin
    raise EAqInternal.CreateFmt('%s is not a generic type.', [pTypeName]);
  end;
end;

class function TAqRttiTypeName.GetGenericName(const pTypeName: string): string;
var
  lLessIndex: Int32;
begin
  AssertIsGeneric(pTypeName, lLessIndex);

  Result := pTypeName.LeftFromPosition(lLessIndex, True) + '>';
end;

class function TAqRttiTypeName.GetGenericTypeNames(const pTypeName: string): TArray<string>;
var
  lLessIndex: Int32;
  lGenericTypes: string;
  lStackCount: UInt8;
  lChar: Char;
  lType: string;

  procedure AddCharToType;
  begin
    lType := lType + lChar;
  end;

  procedure FinishType;
  begin
    if lType.IsEmpty then
    begin
      raise EAqInternal.CreateFmt('Invalid type name (%s) while getting the generic type names.', [pTypeName]);
    end;

    SetLength(Result, Length(Result) + 1);
    Result[Length(Result) - 1] := lType;
    lType.Clear;
  end;
begin
  AssertIsGeneric(pTypeName, lLessIndex);

  lGenericTypes := pTypeName.RightFromPosition(lLessIndex);
  lGenericTypes := lGenericTypes.LeftFromPosition(lGenericTypes.Length - 1);
  lStackCount := 0;
  lType := string.Empty;

  for lChar in lGenericTypes do
  begin
    case lChar of
      '<':
        Inc(lStackCount);
      '>':
        begin
          if lStackCount = 0 then
          begin
            raise EAqInternal.Create('Invalid Stack Count while getting the generic type names.');
          end;

          Dec(lStackCount);
        end;
      ',':
         begin
           if lStackCount = 0 then
           begin
             FinishType;
           end else begin
             AddCharToType;
           end;
         end;
    else
      AddCharToType;
    end;
  end;

  FinishType;
end;

class function TAqRttiTypeName.VerifyIfIsGeneric(const pTypeName: string; out pLessIndex: Int32): Boolean;
var
  lGreaterIndex: Int32;
begin
  Result := pTypeName.Contains('<', pLessIndex, False) and pTypeName.Contains('>', lGreaterIndex, False) and
    (pLessIndex < lGreaterIndex) and pTypeName.EndsWith('>');
end;

class function TAqRttiTypeName.VerifyIfIsGeneric(const pTypeName: string): Boolean;
var
  lLessIndex: Int32;
begin
  Result := VerifyIfIsGeneric(pTypeName, lLessIndex);
end;

end.
