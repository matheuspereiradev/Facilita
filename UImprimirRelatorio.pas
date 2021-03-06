unit UImprimirRelatorio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, Data.Win.ADODB,
  frxClass, frxDBSet, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TfrmGerarRelatorio = class(TForm)
    cbxCrianca: TComboBox;
    cbxMes: TComboBox;
    cbxAno: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    btnImprimirRelatorio: TButton;
    lblTitulo: TLabel;
    qryRelatorio: TADOQuery;
    qryReport: TADOQuery;
    dtsReport: TDataSource;
    relatorio: TfrxReport;
    dtsFrx: TfrxDBDataset;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure pesquisarCriancas;
    procedure btnImprimirRelatorioClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGerarRelatorio: TfrmGerarRelatorio;

implementation

{$R *.dfm}

uses UMenu;

procedure TfrmGerarRelatorio.btnImprimirRelatorioClick(Sender: TObject);
    begin
      if (cbxMes.ItemIndex<>0) and (cbxAno.ItemIndex<>0) then
       begin
        qryReport.Close;
        with qryReport do
        begin
          qryReport.SQL.Clear;
          qryReport.SQL.Add('select g.idGrupo,g.nomeGrupo');
	        qryReport.SQL.Add(',v.idVisita,v.acolhimento,v.desenvolvimento,v.momentoFinal,v.objetivo, v.mesVisita,v.anoVisita');
	        qryReport.SQL.Add(',c.nomeCrianca,c.nisCrianca,c.dtNascCrianca, C.territorioCrianca');
	        qryReport.SQL.Add(',DATEDIFF(YEAR,c.dtNascCrianca,GETDATE()) as idadeCrianca');
	        qryReport.SQL.Add(',s.nomeSupervisor');
	        qryReport.SQL.Add(',vi.nomeVisitador');
          qryReport.SQL.Add('from grupo g');
          qryReport.SQL.Add('inner join visita v on v.idGrupo=g.idGrupo');
          qryReport.SQL.Add('inner join crianca c on g.idGrupo=c.idGrupo');
          qryReport.SQL.Add('inner join supervisor s on g.idVisitador=s.idSupervisor');
          qryReport.SQL.Add('inner join visitador vi on g.idVisitador=vi.idVisitador');
          qryReport.SQL.Add('where g.idVisitador='+frmMenu.idUsuario);
          qryReport.SQL.Add('and c.idCrianca='+inttostr(Integer(cbxCrianca.items.objects[cbxCrianca.ItemIndex])));
          qryReport.SQL.Add('and v.mesVisita='+QuotedStr(cbxMes.Text));
          qryReport.SQL.Add('and v.anoVisita='+QuotedStr(cbxAno.Text));
       end;
       relatorio.ShowReport;
      end
      else
        ShowMessage('Escolha o mes e ano');

    end;

procedure TfrmGerarRelatorio.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Action := caFree;
end;

procedure TfrmGerarRelatorio.FormCreate(Sender: TObject);
    begin
        pesquisarCriancas;
    end;

procedure TfrmGerarRelatorio.pesquisarCriancas;
var i:integer;
    begin
        qryRelatorio.Close;
        with   qryRelatorio do
        begin
          qryRelatorio.SQL.Add('select c.idCrianca, c.nomeCrianca, c.territorioCrianca from crianca c')
        end;
        qryRelatorio.Open;

        i:=0;
       while i<qryRelatorio.RecordCount do
       begin
         cbxCrianca.Items.AddObject( qryRelatorio.FieldByName('nomeCrianca').asString+'-'+qryRelatorio.FieldByName('territorioCrianca').asString,
          tObject(qryRelatorio.FieldByName('idCrianca').asInteger) );
         qryRelatorio.Next;
         i:=i+1;
       end;
       cbxCrianca.ItemIndex:=0;
    end;

end.
