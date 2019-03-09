unit AqDrop.Core.HTTP.Types;

interface

type
{TODO 3 -oTatu -cIncompleto: adicionar todos os tipos de headers}
  TAqHTTPHeaderType = (hhtContentType, hhtAuthorization);

{TODO 3 -oTatu -cIncompleto: adicionar todos os tipos de content type}
  TAqHTTPHeaderContentType = (hctApplicationJSON);

  TAqHTTPHeaderTypeHelper = record helper for TAqHTTPHeaderType
  public
    function ToString: string;
  end;

  TAqHTTPHeaderContentTypeHelper = record helper for TAqHTTPHeaderContentType
  public
    function ToString: string;
  end;

implementation

uses
  AqDrop.Core.Exceptions;

{ TAqHTTPHeaderTypeHelper }

function TAqHTTPHeaderTypeHelper.ToString: string;
begin
  case Self of
    hhtContentType:
      Result := 'Content-Type';
    hhtAuthorization:
      Result := 'Authorization';
  else
    raise EAqInternal.CreateFmt('Invalid HTTP Header type (%d).', [Int32(Self)]);
  end;
end;

{ TAqHTTPHeaderContentTypeHelper }

function TAqHTTPHeaderContentTypeHelper.ToString: string;
begin
  case Self of
    hctApplicationJSON:
      Result := 'application/json';
  else
    raise EAqInternal.CreateFmt('Invalid HTTP Header type (%d).', [Int32(Self)]);
  end;
end;

end.
