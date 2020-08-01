unit AqDrop.Core.Cache.Intf;

interface

uses
  System.TypInfo,
  AqDrop.Core.Types,
  AqDrop.Core.Collections.Intf;

type
  IAqMonitorableCache = interface
    ['{9B4D142C-9DC3-4BFC-88E8-304B3E996531}']

    procedure LinkToType(const pType: PTypeInfo);
    function GetLinkedTypesNames: IAqReadableList<string>;
    procedure DiscardCache(const pID: TAqEntityID);
    procedure DiscardExpiredItems;
  end;

implementation

end.
