unit AqDrop.Core.REST;

interface

uses
  System.SysUtils,
  REST.Client,
  AqDrop.Core.InterfacedObject,
  AqDrop.Core.HTTP.Types,
  AqDrop.Core.HTTP.Intf,
  AqDrop.Core.REST.Intf;

type
  TAqRESTRequest = class(TAqARCObject, IAqRESTRequest)
  strict private
    FRESTClient: TRESTClient;
    FRESTResponse: TRESTResponse;
    FRESTRequest: TRESTRequest;

    procedure ExecuteRequest;
  public
    constructor Create;
    destructor Destroy; override;

    function SetURL(const pURL: string): IAqRESTRequest;
    function SetBasicAuth(const pUsername, pPassword: string): IAqRESTRequest;
    function SetResource(const pResource: string): IAqRESTRequest;
    function AddHeader(const pType: TAqHTTPHeaderType; const pValue: string;
      const pEncode: Boolean = True): IAqRESTRequest;
    function AddBody(const pValue: string): IAqRESTRequest;
    function AddURLSegment(const pName: string; const pValue: string): IAqRESTRequest;
    function SetTimeOut(const pTimeOut: Int32): IAqRESTRequest;
    function Customize(const pCustomizationMethod: TProc<IAqRESTRequest>): IAqRESTRequest;

    function ExecuteGet: IAqRESTRequest;
    function ExecutePost: IAqRESTRequest;
    function ExecutePut: IAqRESTRequest;
    function ExecuteDelete: IAqRESTRequest;
    function ExecutePatch: IAqRESTRequest;

    function GetResult: IAqHTTPResult;
    function GetResultContent: string;
  end;

  TAqRESTBuilder = class
  public
    class function CreateRequest: IAqRESTRequest;
  end;

implementation

uses
  REST.Types,
  REST.Authenticator.Basic,
  AqDrop.Core.HTTP;

{ TAqRESTBuilder }

class function TAqRESTBuilder.CreateRequest: IAqRESTRequest;
begin
  Result := TAqRESTRequest.Create;
end;

{ TAqRESTRequest }

function TAqRESTRequest.AddBody(const pValue: string): IAqRESTRequest;
var
  lParam: TRESTRequestParameter;
begin
  lParam :=  FRESTRequest.Params.AddItem;
  lParam.Kind := TRESTRequestParameterKind.pkREQUESTBODY;
  lParam.Value := pValue;
  lParam.ContentType := ctAPPLICATION_JSON;

  Result := Self;
end;

function TAqRESTRequest.AddHeader(const pType: TAqHTTPHeaderType; const pValue: string; const pEncode: Boolean): IAqRESTRequest;
var
  lParam: TRESTRequestParameter;
begin
  lParam := FRESTRequest.Params.AddHeader(pType.ToString, pValue);

  if not pEncode then
  begin
    lParam.Options := lParam.Options + [TRESTRequestParameterOption.poDoNotEncode];
  end;

  Result := Self;
end;

function TAqRESTRequest.AddURLSegment(const pName, pValue: string): IAqRESTRequest;
begin
  FRESTRequest.Params.AddUrlSegment(pName, pValue);
  Result := Self;
end;

constructor TAqRESTRequest.Create;
begin
  FRESTClient := TRESTClient.Create(nil);
  FRESTResponse := TRESTResponse.Create(nil);
  FRESTRequest := TRESTRequest.Create(nil);

  FRESTRequest.Client := FRESTClient;
  FRESTRequest.Response := FRESTResponse;
end;

function TAqRESTRequest.Customize(const pCustomizationMethod: TProc<IAqRESTRequest>): IAqRESTRequest;
begin
  if Assigned(pCustomizationMethod) then
  begin
    pCustomizationMethod(Self);
  end;

  Result := Self;
end;

function TAqRESTRequest.ExecuteDelete: IAqRESTRequest;
begin
  FRESTRequest.Method := TRESTRequestMethod.rmDELETE;
  ExecuteRequest;

  Result := Self;
end;

destructor TAqRESTRequest.Destroy;
begin
  FRESTRequest.Free;
  FRESTResponse.Free;
  FRESTClient.Free;

  inherited;
end;

procedure TAqRESTRequest.ExecuteRequest;
begin
  FRESTRequest.Execute;
end;

function TAqRESTRequest.ExecuteGet: IAqRESTRequest;
begin
  FRESTRequest.Method := TRESTRequestMethod.rmGET;
  ExecuteRequest;

  Result := Self;
end;

function TAqRESTRequest.GetResult: IAqHTTPResult;
begin
  Result := TAqHTTPResult.Create(FRESTResponse.StatusCode, FRESTResponse.Content);
end;

function TAqRESTRequest.GetResultContent: string;
begin
  Result := FRESTResponse.Content;
end;

function TAqRESTRequest.ExecutePatch: IAqRESTRequest;
begin
  FRESTRequest.Method := TRESTRequestMethod.rmDELETE;
  ExecuteRequest;

  Result := Self;
end;

function TAqRESTRequest.ExecutePost: IAqRESTRequest;
begin
  FRESTRequest.Method := TRESTRequestMethod.rmPOST;
  ExecuteRequest;

  Result := Self;
end;

function TAqRESTRequest.ExecutePut: IAqRESTRequest;
begin
  FRESTRequest.Method := TRESTRequestMethod.rmPUT;
  ExecuteRequest;

  Result := Self;
end;

function TAqRESTRequest.SetBasicAuth(const pUsername, pPassword: string): IAqRESTRequest;
var
  lAuthenticator: THTTPBasicAuthenticator;
begin
  if Assigned(FRESTClient.Authenticator) then
  begin
    FRESTClient.Authenticator.Free;
    FRESTClient.Authenticator := nil;
  end;

  lAuthenticator := THTTPBasicAuthenticator.Create(FRESTClient);
  FRESTClient.Authenticator := lAuthenticator;

  lAuthenticator.Username := pUsername;
  lAuthenticator.Password := pPassword;

  Result := Self;
end;

function TAqRESTRequest.SetResource(const pResource: string): IAqRESTRequest;
begin
  FRESTRequest.Resource := pResource;

  Result := Self;
end;

function TAqRESTRequest.SetTimeOut(const pTimeOut: Int32): IAqRESTRequest;
begin
  FRESTRequest.Timeout := pTimeOut;
  Result := Self;
end;

function TAqRESTRequest.SetURL(const pURL: string): IAqRESTRequest;
begin
  FRESTClient.BaseURL := pURL;

  Result := Self;
end;

end.
