unit AqDrop.Core.InterfaceSupport;

interface

uses
  AqDrop.Core.Collections.Intf;

type
  TAqGenericInterfaceSupport = class
  public
    class function Test<I: IInterface>(pInterface: IInterface; out pSupportedInterface: I): Boolean; overload;
    class function Test<I: IInterface>(pInterface: IInterface): Boolean; overload;
    class function Test<I: IInterface>(const pObject: TObject; out pSupportedInterface: I): Boolean; overload;
    class function Test<I: IInterface>(const pObject: TObject): Boolean; overload;
    class function Test<I: IInterface>(const pClass: TClass): Boolean; overload;
    class function ConvertTo<I: IInterface>(pInterface: IInterface): I; overload;
    class function ConvertTo<I: IInterface>(pObject: TObject): I; overload;
    class function CreateConvertedList<Source, Target: IInterface>(pOrigem: IAqReadableList<Source>): IAqList<Target>;
  end;

implementation

uses
  System.SysUtils,
  System.TypInfo,
  AqDrop.Core.Exceptions,
  AqDrop.Core.Collections;

{ TAqGenericInterfaceSupport }

class function TAqGenericInterfaceSupport.ConvertTo<I>(pInterface: IInterface): I;
begin
  if not Test<I>(pInterface, Result) then
  begin
    raise EAqInternal.Create('The provided interface does not support ' + GetTypeName(TypeInfo(I)) + '.');
  end;
end;

class function TAqGenericInterfaceSupport.ConvertTo<I>(pObject: TObject): I;
begin
  if not Test<I>(pObject, Result) then
  begin
    raise EAqInternal.Create('The provided interface does not support ' + GetTypeName(TypeInfo(I)) + '.');
  end;
end;

class function TAqGenericInterfaceSupport.CreateConvertedList<Source, Target>(
  pOrigem: IAqReadableList<Source>): IAqList<Target>;
var
  lObject: Source;
begin
  if Assigned(pOrigem) then
  begin
    Result := TAqList<Target>.Create;

    for lObject in pOrigem do
    begin
      Result.Add(ConvertTo<Target>(lObject));
    end;
  end else
  begin
    Result := nil;
  end;
end;

class function TAqGenericInterfaceSupport.Test<I>(const pClass: TClass): Boolean;
begin
  Result := System.SysUtils.Supports(pClass, GetTypeData(TypeInfo(I))^.GUID);
end;

class function TAqGenericInterfaceSupport.Test<I>(pInterface: IInterface; out pSupportedInterface: I): Boolean;
begin
  Result := System.SysUtils.Supports(pInterface, GetTypeData(TypeInfo(I))^.GUID, pSupportedInterface);
end;

class function TAqGenericInterfaceSupport.Test<I>(pInterface: IInterface): Boolean;
begin
  Result := System.SysUtils.Supports(pInterface, GetTypeData(TypeInfo(I))^.GUID);
end;

class function TAqGenericInterfaceSupport.Test<I>(const pObject: TObject; out pSupportedInterface: I): Boolean;
begin
  Result := System.SysUtils.Supports(pObject, GetTypeData(TypeInfo(I))^.GUID, pSupportedInterface);
end;

class function TAqGenericInterfaceSupport.Test<I>(const pObject: TObject): Boolean;
begin
  Result := System.SysUtils.Supports(pObject, GetTypeData(TypeInfo(I))^.GUID);
end;

end.
