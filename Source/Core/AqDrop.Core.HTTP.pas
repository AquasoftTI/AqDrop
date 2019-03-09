unit AqDrop.Core.HTTP;

interface

uses
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.HTTP.Intf;

type
  TAqHTTPResult = class(TAqARCObject, IAqHTTPResult)
  strict private
    FStatusCode: Int32;
    FContent: string;

    function GetStatusCode: Int32;
    function GetContent: string;
  public
    constructor Create(const pStatusCode: Int32; const pContent: string);
  end;

implementation

{ TAqHTTPResult }

constructor TAqHTTPResult.Create(const pStatusCode: Int32; const pContent: string);
begin
  FStatusCode := pStatusCode;
  FContent := pContent;
end;

function TAqHTTPResult.GetContent: string;
begin
  Result := FContent;
end;

function TAqHTTPResult.GetStatusCode: Int32;
begin
  Result := FStatusCode;
end;

end.
