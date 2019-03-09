unit AqDrop.Core.Clonable.Intf;

interface

uses
  AqDrop.Core.Attributes;

type
  AqCloneOff = class(TAqAttribute);

  IAqClonable = interface
    ['{988A784B-4793-4724-8C39-4B8E352148C7}']

    procedure CloneTo(pClonable: IAqClonable);
  end;

implementation

end.
