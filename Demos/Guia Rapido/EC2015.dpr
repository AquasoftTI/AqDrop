program EC2015;

uses
  System.StartUpCopy,
  FMX.Forms,
  fPrincipal in 'fPrincipal.pas' {Form1},
  uVariacoesMapeamentos in 'uVariacoesMapeamentos.pas',
  uMapeamentos in 'uMapeamentos.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
