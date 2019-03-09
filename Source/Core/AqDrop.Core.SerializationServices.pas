unit AqDrop.Core.SerializationServices;

interface

uses
  System.Classes;

type
{TODO: passar para o padrao Instance ou DefaultInstance}
  TAqSerializationServices = class
  public
    class function Serialize(const pComponent: TComponent): string;
  end;

implementation

{ TAqSerializationServices }

class function TAqSerializationServices.Serialize(const pComponent: TComponent): string;
var
  lMemoryStream: TMemoryStream;
  lStringStream: TStringStream;
begin
  lMemoryStream := TMemoryStream.Create;

  try
    lMemoryStream.WriteComponent(pComponent);
    lMemoryStream.Position := 0;

    lStringStream := TStringStream.Create;

    try
      ObjectBinaryToText(lMemoryStream, lStringStream);
      Result := lStringStream.DataString;
    finally
      lStringStream.Free;
    end;
  finally
    lMemoryStream.Free;
  end;
end;

end.
