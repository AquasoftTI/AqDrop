unit AqDrop.Core.REST.Intf;

interface

uses
  System.SysUtils,
  AqDrop.Core.HTTP.Types,
  AqDrop.Core.HTTP.Intf;

type
  IAqRESTRequest = interface
    ['{E6705500-B38E-4E1F-AF7E-64E20A4C8442}']

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


implementation

end.
