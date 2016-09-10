unit AqDrop.Register.Splash;

interface

uses
  Winapi.Windows, Vcl.Graphics, ToolsAPI;

type
  TAqIDESplash = class
  public
    class procedure Install;
  end;

procedure Register;

implementation

procedure Register;
begin
  TAqIDESplash.Install;
end;

{ TAqIDESplash }

class procedure TAqIDESplash.Install;
var
  lBitmap: TBitmap;
begin
  lBitmap := TBitmap.Create;

  try
    lBitmap.LoadFromResourceName(HInstance, 'BMP_DROP_24');

    SplashScreenServices.AddPluginBitmap('DROP by Aquasoft', lBitmap.Handle);
  finally
    lBitmap.Free;
  end;
end;

end.
