unit AqDrop.Core.Helpers.TRttiObject;

interface

uses
  System.Rtti,
  System.SysUtils,
  AqDrop.Core.Collections.Intf;

type
  TAqRttiObjectHelper = class helper for TRttiObject
  strict private
    procedure ForEachAttribute<T: TCustomAttribute>(const pProcessing: TFunc<T, Boolean>);
  public
    function GetAttribute<T: TCustomAttribute>(out pAttribute: T; const pOccurrence: UInt32 = 0): Boolean;
    function GetAttributes<T: TCustomAttribute>(out pAttributes: IAqResultList<T>): Boolean; overload;
    function HasAttribute<T: TCustomAttribute>: Boolean;
  end;

implementation

uses
  AqDrop.Core.Helpers.TArray,
  AqDrop.Core.Collections;

{ TAqRttiObjectHelper }

function TAqRttiObjectHelper.GetAttribute<T>(out pAttribute: T; const pOccurrence: UInt32): Boolean;
var
  lResult: Boolean;
  lAttribute: T;
  lOccurrence: UInt32;
begin
  lResult := False;
  lOccurrence := pOccurrence;
  ForEachAttribute<T>(
    function(pAttribute: T): Boolean
    begin
      lResult := lOccurrence = 0;
      if lResult then
      begin
        lAttribute := pAttribute;
      end else begin
        Dec(lOccurrence);
      end;

      Result := not lResult;
    end);

  Result := lResult;

  if Result then
  begin
    pAttribute := lAttribute;
  end;
end;

function TAqRttiObjectHelper.GetAttributes<T>(out pAttributes: IAqResultList<T>): Boolean;
var
  lResult: Boolean;
  lList: TAqResultList<T>;
begin
  lResult := False;
  lList := nil;

  try
    ForEachAttribute<T>(
      function(pProcessingAttribute: T): Boolean
      begin
        Result := True;

        if not lResult then
        begin
          lList := TAqResultList<T>.Create;
        end;

        lResult := True;
        lList.Add(pProcessingAttribute);
      end);
  except
    lList.Free;
    raise;
  end;

  Result := lResult;

  if Result then
  begin
    pAttributes := lList;
  end;
end;

function TAqRttiObjectHelper.HasAttribute<T>: Boolean;
var
  lAttribute: T;
begin
  Result := GetAttribute<T>(lAttribute);
end;

procedure TAqRttiObjectHelper.ForEachAttribute<T>(const pProcessing: TFunc<T, Boolean>);
begin
  TAqArray<TCustomAttribute>.ForIn(GetAttributes,
    function(pItem: TCustomAttribute): Boolean
    begin
      Result := not pItem.InheritsFrom(T) or pProcessing(T(pItem));
    end);
end;

end.

