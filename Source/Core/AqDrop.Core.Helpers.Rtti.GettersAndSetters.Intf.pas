unit AqDrop.Core.Helpers.Rtti.GettersAndSetters.Intf;

interface

uses
  System.Rtti;

type
  IAqRttiValueGetter = interface
    ['{A56F8C55-CDD0-42AA-9662-316B82B35F30}']

    function GetValue(const pInstance: Pointer): TValue;
  end;

  IAqRttiValueSetter = interface
    ['{12B97C79-184A-47D5-9EB3-C1D22731F540}']

    procedure SetValue(const pInstance: Pointer; const pValue: TValue);
  end;


implementation

end.
