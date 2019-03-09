unit AqDrop.Core.RequirementTests;

interface

uses
  AqDrop.Core.Exceptions;

type
  ERequirementFailure = class(EAqInternal);

  TAqRequirement = class
  public
    {TODO 3 -cMelhoria: localizar todos os asserts do Drop, TSF e restante do sistema, e verificar se deve ser assert realmente, ou se pode ser substituído pelo método Test}
    class procedure Test(const pCondition: Boolean; const pFailureMessage: string); inline;
  end;

implementation

{ TAqRequirement }

class procedure TAqRequirement.Test(const pCondition: Boolean; const pFailureMessage: string);
begin
  if not pCondition then
  begin
    raise ERequirementFailure.Create(pFailureMessage);
  end;
end;

end.
