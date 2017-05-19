unit fPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Controls.Presentation, FMX.TabControl,
  AqDrop.DB.FD.SQLite, AqDrop.DB.FD.Ora, AqDrop.DB.FD.MSSQL, AqDrop.DB.FD.PG, FireDAC.UI.Intf, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Intf, FireDAC.Comp.UI, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, Data.DB, FireDAC.Comp.Client, FireDAC.DApt, AqDrop.DB.SQL, AqDrop.DB.SQL.Intf,
  AqDrop.DB.ORM.Manager, FMX.Edit, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.ObjectScope, FMX.ListView, System.Generics.Collections, uVariacoesMapeamentos, uMapeamentos;

type
  TForm1 = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    Button1: TButton;
    ToolBar1: TToolBar;
    Label1: TLabel;
    Button2: TButton;
    FDConnection1: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Pessoa: TTabItem;
    Button6: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    ListView1: TListView;
    Button7: TButton;
    AdapterBindSource1: TAdapterBindSource;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    TabItem2: TTabItem;
    Button8: TButton;
    Button9: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  strict private
    FConexao: TAqFDSQLiteConnection;
    FManager: TAqDBORMManager;

    FPessoas: TObjectList<TPessoa>;
    FPessoasAdapter: TListBindSourceAdapter<TPessoa>;

    procedure ConectarAoBD(const pNotificarSucesso: Boolean);
    procedure GarantirExistenciaRequisitosBD;

    function GetManager: TAqDBORMManager;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.IOUtils, AqDrop.DB.Types, AqDrop.Core.Collections.Intf;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ConectarAoBD(True);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
// Criando a estrutura do banco de dados no SQLite
  GarantirExistenciaRequisitosBD;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  lSelect: IAqDBSQLSelect;
  lReader: IAqDBReader;
  lSL: TStringList;
begin
  GarantirExistenciaRequisitosBD;

// Este exemplo mostra a estrutura intermediária de trabalho do DROP,
// que abstrai comandos de SQL em objetos, de forma a traduzí-los da
// melhor forma possível para cada banco de dados e suas diferenças

// IMPORTANTE, não é obrigatório o uso deste aproach! Há maneiras mais simples de chegar até o SGBD ;)

  lSelect := TAqDBSQLSelect.Create('CIDADE');
  lSelect.AddColumn('NOME');
  lSelect.CustomizeCondition().AddColumnEqual('ATIVA', True);
  lSelect.Limit := 2;

  lSL := TStringList.Create;

  try
// Conexões do DROP retornam readers ao abrir um select.
    lReader := FConexao.OpenQuery(lSelect);

    while lReader.Next do
    begin
      lSL.Add(lReader['NOME'].AsString);
    end;

    ShowMessage(lSL.Text);
  finally
    lSL.Free;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  lCidades: IAqResultList<uVariacoesMapeamentos.TCidade>;
begin
  GarantirExistenciaRequisitosBD;

// Usa o Manager para interpretar o ORM da classe TCidade,
// recuperar os registros do SGBD, e devolver estes na forma
// de objetos de TCidade
  lCidades := GetManager.Get<uVariacoesMapeamentos.TCidade>;

  if Assigned(lCidades) then
  begin
    ShowMessage(lCidades.First.Nome);
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  lCidades: IAqResultList<uVariacoesMapeamentos.TCidade>;
begin
  GarantirExistenciaRequisitosBD;

// Demonstração de um overload do método Get que permite
// escrever o próprio SQL para recuperar os objetos de TCidade
  lCidades := GetManager.Get<uVariacoesMapeamentos.TCidade>('select * from cidade where ativa = 0');

  if Assigned(lCidades) then
  begin
    ShowMessage(lCidades.First.Nome);
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  lPessoa: TPessoa;
begin
// Exemplo de como utilizar um Manager de Objetos base (TPessoas)
// e deste solicitar um novo objeto...
  lPessoa := GetManager.GetClient<TPessoas>.New;

  try
// ... que é preenchido...
    lPessoa.Nome := Edit1.Text;
    lPessoa.IDCidade := Edit2.Text.ToInteger;
  except
    lPessoa.Free;
    raise;
  end;

// ... e persistido no SGBD.
  lPessoa.Save;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  lPessoas: IAqResultList<TPessoa>;
begin
// Exemplo de recuperação dos objetos persisitidos na tabela PESSOA...
  lPessoas := GetManager.GetClient<TPessoas>.Get;

  if Assigned(lPessoas) then
  begin
// ... e preenchimento de um listview via LiveBinding.
    FPessoas.Clear;
    lPessoas.ExtractAllTo(FPessoas);
    FPessoasAdapter.Refresh;
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  lProjetos: IAqResultList<TProjeto>;
begin
// Novo exemplo de obtenção de todos os registros de uma tabela (ou objetos).
  lProjetos := GetManager.GetClient<TProjetos>.Get;

  if Assigned(lProjetos) then
  begin
    ShowMessage(lProjetos.Count.ToString);
  end;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  lProjetos: IAqResultList<TProjeto>;
begin
// Demonstração de chamada de método que customiza a busca no SGBD.

  lProjetos := GetManager.GetClient<TProjetos>.GetProjetosDoRecurso(1);

  if Assigned(lProjetos) then
  begin
    ShowMessage(lProjetos.Count.ToString);
    ShowMessage(lProjetos.First.Nome);
  end;
end;

procedure TForm1.ConectarAoBD(const pNotificarSucesso: Boolean);
begin
// O primeiro passo para utilizar o ORM do DROP,
// é estabelecer a conexão com o BD usando as classes de conexão do DROP.
  if not Assigned(FConexao) then
  begin
// Exemplos de outros tipos de conexão que estão disponíveis.
//    TAqFDOraConnection.Create;
//    TAqFDMSSQLConnection.Create;
//    TAqFDPGConnection.Create;

    FConexao := TAqFDSQLiteConnection.Create;
{$IFDEF MSWINDOWS}
    FConexao.DataBase := '.\EC2015.sqlite3';
{$ELSE}
    FConexao.DataBase := TPath.Combine(TPath.GetDocumentsPath, 'EC2015.sqlite3');
{$ENDIF}
    FConexao.OpenMode := TAqFDSQLiteOpenMode.somCreateUTF16;
    FConexao.Connect;

    if pNotificarSucesso and FConexao.Active then
    begin
      ShowMessage('Conexão estabelecida');
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FPessoas := TObjectList<TPessoa>.Create(False);
  FPessoasAdapter := TListBindSourceAdapter<TPessoa>.Create(Self, FPessoas, False);
  AdapterBindSource1.Adapter := FPessoasAdapter;
  AdapterBindSource1.Active := True;
end;

procedure TForm1.GarantirExistenciaRequisitosBD;
var
  lReader: IAqDBReader;
begin
  ConectarAoBD(False);

  FConexao.ExecuteCommand(
    'CREATE TABLE IF NOT EXISTS CIDADE(' + sLineBreak +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT,' + sLineBreak +
    'NOME TEXT NOT NULL,' + sLineBreak +
    'ATIVA INTEGER NOT NULL)');

  FConexao.ExecuteCommand(
    'CREATE TABLE IF NOT EXISTS PESSOA(' + sLineBreak +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT,' + sLineBreak +
    'NOME TEXT NOT NULL,' + sLineBreak +
    'ID_CIDADE INTEGER NOT NULL)');

  FConexao.ExecuteCommand(
    'CREATE TABLE IF NOT EXISTS PESSOA_FISICA(' + sLineBreak +
    'ID INTEGER PRIMARY KEY,' + sLineBreak +
    'CPF INTEGER,' + sLineBreak +
    'NASCIMENTO REAL NOT NULL)');

  FConexao.ExecuteCommand(
    'CREATE TABLE IF NOT EXISTS PROJETO(' + sLineBreak +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT,' + sLineBreak +
    'NOME TEXT NOT NULL)');

  FConexao.ExecuteCommand(
    'CREATE TABLE IF NOT EXISTS PROJETO_PESSOA(' + sLineBreak +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT,' + sLineBreak +
    'ID_PROJETO INTEGER NOT NULL,' + sLineBreak +
    'ID_PESSOA INTEGER NOT NULL)');

  lReader := FConexao.OpenQuery('SELECT * FROM CIDADE');

  if not lReader.Next then
  begin
    FConexao.ExecuteCommand('INSERT INTO CIDADE (NOME, ATIVA) VALUES (''Porto Alegre'', 1)');
    FConexao.ExecuteCommand('INSERT INTO CIDADE (NOME, ATIVA) VALUES (''Porto dos Casais'', 0)');
    FConexao.ExecuteCommand('INSERT INTO CIDADE (NOME, ATIVA) VALUES (''Florianópolis'', 1)');
    FConexao.ExecuteCommand('INSERT INTO CIDADE (NOME, ATIVA) VALUES (''Curitiba'', 1)');
    FConexao.ExecuteCommand('INSERT INTO CIDADE (NOME, ATIVA) VALUES (''São Paulo'', 1)');
    FConexao.ExecuteCommand('INSERT INTO CIDADE (NOME, ATIVA) VALUES (''Rio de Janeiro'', 1)');
  end;

  lReader := FConexao.OpenQuery('SELECT * FROM PROJETO');

  if not lReader.Next then
  begin
    FConexao.ExecuteCommand('INSERT INTO PROJETO (NOME) VALUES (''DROP'')');
    FConexao.ExecuteCommand('INSERT INTO PROJETO (NOME) VALUES (''DELPHI'')');
    FConexao.ExecuteCommand('INSERT INTO PROJETO (NOME) VALUES (''EC2015'')');
    FConexao.ExecuteCommand('INSERT INTO PROJETO_PESSOA (ID_PROJETO, ID_PESSOA) VALUES (2, 1)');
  end;
end;

function TForm1.GetManager: TAqDBORMManager;
begin
// Método que cria um ORMManager, se este ainda não existir.
// O ORM Manager une a capacidade de conversa com o SGBD e
// leitura dos atributos de ORM das classes. Logo, ele é
// capaz de gerar SQLs de CRUD a partir de classes mapeadas
// e disparar contra o banco de dados, persistindo as inforações,
// ou recuperando registros na forma de objetos.

  if not Assigned(FManager) then
  begin
    GarantirExistenciaRequisitosBD;
    FManager := TAqDBORMManager.Create(FConexao);
  end;

  Result := FManager;
end;

end.
