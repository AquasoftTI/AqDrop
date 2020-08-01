unit AqDrop.Core.ResourcesControl;

interface

uses
  System.SysUtils,
  System.TypInfo;

type
  TAqResourceProtectionType = (RelesaseTestLocker, HoldTestLocker);

  TAqResourcesControl = class
  strict private
    class procedure CheckResourceType(const pType: PTypeInfo);
  public
    class function CreateIfNotExists<T>(var pResource: T; const pCreateResourceMethod: TFunc<T>): T;
    class procedure ExecuteIfExists<T>(const [ref] pResource: T; const pThreadSafeResourceMethod: TProc;
      const pResourceProtectionType: TAqResourceProtectionType = TAqResourceProtectionType.RelesaseTestLocker);
  end;

implementation

uses
  AqDrop.Core.Exceptions,
  AqDrop.Core.Monitor;

{ TAqResourcesControl }

class procedure TAqResourcesControl.CheckResourceType(const pType: PTypeInfo);
begin
  if not (pType^.Kind in [TTypeKind.tkClass, TTypeKind.tkInterface]) then
  begin
    raise EAqInternal.Create('Resource type not supported by Resource Control.');
  end;
end;

class function TAqResourcesControl.CreateIfNotExists<T>(var pResource: T; const pCreateResourceMethod: TFunc<T>): T;
begin
  CheckResourceType(TypeInfo(T));

  TAqMonitor.Enter(@pResource);

  try
    if PPointer(@pResource)^ = nil then
    begin
      pResource := pCreateResourceMethod();
    end;
  finally
    TAqMonitor.Exit(@pResource);
  end;

  Result := pResource;
end;

class procedure TAqResourcesControl.ExecuteIfExists<T>(const [ref] pResource: T; const pThreadSafeResourceMethod: TProc;
  const pResourceProtectionType: TAqResourceProtectionType);
var
  lResourceExists: Boolean;
begin
  CheckResourceType(TypeInfo(T));

  TAqMonitor.Enter(@pResource);

  try
    lResourceExists := PPointer(@pResource)^ <> nil;

    if lResourceExists and (pResourceProtectionType = TAqResourceProtectionType.HoldTestLocker) then
    begin
      pThreadSafeResourceMethod();
    end;
  finally
    TAqMonitor.Exit(@pResource);
  end;

  if lResourceExists and (pResourceProtectionType = TAqResourceProtectionType.RelesaseTestLocker) then
  begin
    pThreadSafeResourceMethod();
  end;
end;

end.
