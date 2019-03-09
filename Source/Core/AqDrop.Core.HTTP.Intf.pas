unit AqDrop.Core.HTTP.Intf;

interface

type
  IAqHTTPResult = interface
    ['{8B00A82F-0368-4D02-A421-9621E214F65E}']

    function GetStatusCode: Int32;
    function GetContent: string;

    property StatusCode: Int32 read GetStatusCode;
    property Content: string read GetContent;
  end;

implementation

end.
