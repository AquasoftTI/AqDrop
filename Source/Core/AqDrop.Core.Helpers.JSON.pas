unit AqDrop.Core.Helpers.JSON;

interface

uses
{$IF CompilerVersion >= 27} // DXE6+
  System.JSON;
{$ELSE}
  Data.DBXJSON;
{$ENDIF}

type
  TAqJSONValueHelper = class helper for TJSONValue
  public
    function TryAs<T: class>(out pObjeto: T; const pAcceptNull: Boolean = False): Boolean;
    function &As<T: class>: T;

    function AsJSONObject: TJSONObject;
    function AsJSONString: TJSONString;
    function AsInteger: Integer;
    function AsInt64: Int64;
    function AsBoolean: Boolean;
  end;

implementation

{ TAqJSONValueHelper }

uses
  AqDrop.Core.Exceptions,
  Data.DBXJSONReflect;

function TAqJSONValueHelper.&As<T>: T;
begin
  if not TryAs<T>(Result, True) then
  begin
    raise EAqInternal.Create('Incompatible classes.');
  end;
end;

function TAqJSONValueHelper.AsBoolean: Boolean;
begin
  Result := Self is TJSONTrue;

  if not Result then
  begin
    Result := not (Self is TJSONFalse);

    if Result then
    begin
      raise EAqInternal.Create('Invalid type to use as boolean value.');
    end;
  end;
end;

function TAqJSONValueHelper.AsInt64: Int64;
begin
  Result := (Self as TJSONNumber).AsInt64;
end;

function TAqJSONValueHelper.AsInteger: Integer;
begin
  Result := (Self as TJSONNumber).AsInt;
end;

function TAqJSONValueHelper.AsJSONObject: TJSONObject;
begin
  Result := (Self as TJSONObject);
end;

function TAqJSONValueHelper.AsJSONString: TJSONString;
begin
  Result := (Self as TJSONString);
end;

function TAqJSONValueHelper.TryAs<T>(out pObjeto: T; const pAcceptNull: Boolean): Boolean;
var
  lUnMarshal: TJSONUnMarshal;
  lObjeto: TObject;
begin
  pObjeto := nil;

  if not Assigned(Self) or (Self is TJSONNull) then
  begin
    Result := pAcceptNull;
  end else begin
    lUnMarshal := TJSONUnMarshal.Create;

    try
      lObjeto := lUnMarshal.Unmarshal(Self);

      try
        Result := lObjeto.InheritsFrom(T);

        if Result then
        begin
          pObjeto := T(lObjeto);
        end;
      finally
        if not Result then
        begin
          lObjeto.Free;
        end;
      end;
    finally
      lUnMarshal.Free;
    end;
  end;
end;

end.
