unit AqDrop.Core.RegisterDefaultImplementations;

interface

type
  TAqDropDefaultImplementations = class
  public
    class procedure RegisterDefaultImplementations;
  end;

implementation

uses
  AqDrop.Core.Generics.Releaser.Impl,
  AqDrop.Core.Helpers.Rtti.Impl;

{ TAqDropDefaultImplementations }

class procedure TAqDropDefaultImplementations.RegisterDefaultImplementations;
begin
  TAqGenericReleaserImplementation.RegisterAsDefaultImplementation;
  TAqRttiImplementation.RegisterAsDefaultImplementation;
end;

end.
