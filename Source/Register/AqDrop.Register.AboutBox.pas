unit AqDrop.Register.AboutBox;

interface

uses
  Winapi.Windows, Vcl.Graphics, ToolsAPI;

type
  TAqIDEAboutBox = class
  strict private
    class var FBitmap: TBitmap;

    class function GetLogo: HBITMAP;
  public
    class procedure Install;
    class procedure Uninstall;
  end;

procedure Register;

implementation

uses
  System.SysUtils;

procedure Register;
begin
  TAqIDEAboutBox.Install;
end;

{ TAqIDEAboutBox }

class function TAqIDEAboutBox.GetLogo: HBITMAP;
begin
  if not Assigned(FBitmap) then
  begin
    FBitmap := TBitmap.Create;
    FBitmap.LoadFromResourceName(HINSTANCE, 'BMP_DROP_32');
  end;

  Result := FBitmap.Handle;
end;

class procedure TAqIDEAboutBox.Install;
begin
  (BorlandIDEServices as IOTAAboutBoxServices).AddPluginInfo('DROP by Aquasoft',
    'Developed by Aquasoft TI' + sLineBreak +
    'Porto Alegre - RS - Brazil' + sLineBreak +
    'www.aquasoft.com.br', GetLogo, False, 'Registered', 'DROP by Aquasoft');
end;

class procedure TAqIDEAboutBox.Uninstall;
begin
  FreeAndNil(FBitmap);
end;

initialization

finalization
  TAqIDEAboutBox.Uninstall;

end.
