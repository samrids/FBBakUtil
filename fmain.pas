unit fmain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Stan.Def, FireDAC.Phys.IBWrapper, FireDAC.Phys.FBDef, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Phys, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB, FireDAC.Stan.Intf, dxGDIPlusClasses, Vcl.ComCtrls;

type
  TfrmMainBak = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button2: TButton;
    FDIBBackup1: TFDIBBackup;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    Image1: TImage;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    GroupBox1: TGroupBox;
    Chx_boIgnoreChecksum: TCheckBox;
    Chx_boIgnoreLimbo: TCheckBox;
    Chx_boMetadataOnly: TCheckBox;
    Chx_boNoGarbageCollect: TCheckBox;
    Chx_boOldDescriptions: TCheckBox;
    Chx_boConvert: TCheckBox;
    Chx_boExpand: TCheckBox;
    GroupBox2: TGroupBox;
    Chx_Verbose: TCheckBox;
    Cmb_Verbose: TComboBox;
    Edt_OutPutFile: TEdit;
    Btn_SelectOutputFile: TButton;
    Label1: TLabel;
    Cmb_boNonTransportable: TComboBox;
    GroupBox3: TGroupBox;
    Edt_Username: TEdit;
    Edt_Password: TEdit;
    Cmb_Protocol: TComboBox;
    Edt_Host: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label7: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label4: TLabel;
    Button5: TButton;
    FileOpenDialog1: TFileOpenDialog;
    FileSaveDialog1: TFileSaveDialog;
    GroupBox4: TGroupBox;
    Label8: TLabel;
    Edt_BackupFile: TEdit;
    Button4: TButton;
    Edt_Database: TEdit;
    Button1: TButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FDIBBackup1Progress(ASender: TFDPhysDriverService;
      const AMessage: string);
    procedure Btn_SelectOutputFileClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Cmb_VerboseChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Chx_VerboseClick(Sender: TObject);
  private
    start: cardinal;
    FStartTime, FCompleteTime: TDateTime;
    procedure EnableButtons(AEnabled: Boolean = true);
    procedure LogMsg(const AFilename, AMessage: string);
    procedure StartBackup;
  public
    { Public declarations }
  end;

var
  frmMainBak: TfrmMainBak;

implementation

{$R *.dfm}
{ TForm2 }

procedure TfrmMainBak.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMainBak.Button2Click(Sender: TObject);
begin
  if Trim(Edt_Host.Text) = '' then
    Abort;
  if Trim(Edt_Database.Text) = '' then
    Abort;
  if Trim(Edt_Username.Text) = '' then
    Abort;
  if Trim(Edt_Host.Text) = '' then
    Abort;

  if Chx_Verbose.Checked then
  begin
    if (Trim(Edt_OutPutFile.Text) = '') then
      Edt_OutPutFile.Text := 'C:\Temp\BakFbLog' + FormatDateTime('ddmmyyyy',
        Date) + '.txt';
  end;
  FStartTime := Now;
  start := GetTickCount;
  StartBackup;
end;

procedure TfrmMainBak.Btn_SelectOutputFileClick(Sender: TObject);
begin
  FileOpenDialog1.DefaultExtension := 'txt';
  if FileSaveDialog1.Execute then
  begin
    Edt_OutPutFile.Text := FileSaveDialog1.FileName;
  end;
end;

procedure TfrmMainBak.Button4Click(Sender: TObject);
begin
  FileOpenDialog1.DefaultExtension := 'fbk';
  if FileSaveDialog1.Execute then
  begin
    Edt_BackupFile.Text := FileSaveDialog1.FileName;
  end;

end;

procedure TfrmMainBak.Button5Click(Sender: TObject);
begin
  FileOpenDialog1.DefaultExtension := 'fdb';
  if FileOpenDialog1.Execute then
  begin
    Edt_Database.Text := FileOpenDialog1.FileName;
  end;
end;

procedure TfrmMainBak.Chx_VerboseClick(Sender: TObject);
begin
  Cmb_Verbose.Enabled := (Sender as TCheckBox).Checked;
end;

procedure TfrmMainBak.Cmb_VerboseChange(Sender: TObject);
begin
  if Chx_Verbose.Checked then
  begin
    Edt_OutPutFile.Visible := ((Sender as TComboBox).ItemIndex = 0);
    Btn_SelectOutputFile.Visible := Edt_OutPutFile.Visible;
  end;
end;

procedure TfrmMainBak.FDIBBackup1Progress(ASender: TFDPhysDriverService;
  const AMessage: string);
begin
  if Chx_Verbose.Checked then
  begin
    case Cmb_Verbose.ItemIndex of
      0:
        begin
          LogMsg(Trim(Edt_OutPutFile.Text), AMessage);
        end;
      1:
        begin
          Memo1.Lines.Add(AMessage);
        end;
    end;
  end;
end;

procedure TfrmMainBak.FormCreate(Sender: TObject);
begin
  Self.Width := Screen.Width - 200;
  Self.Height := Screen.Height - 200;
end;

procedure TfrmMainBak.LogMsg(const AFilename, AMessage: string);
var
  f: TextFile;
begin
  try
    AssignFile(f, AFilename);
    if FileExists(AFilename) then
      Append(f)
    else
      ReWrite(f);

    WriteLn(f, AMessage);

    CloseFile(f);
  except
  end;
end;

procedure TfrmMainBak.EnableButtons(AEnabled: Boolean);
begin
  Button1.Enabled := AEnabled;
  Button2.Enabled := AEnabled;
end;

procedure TfrmMainBak.StartBackup;
begin
  try
    EnableButtons(false);

    FDIBBackup1.UserName := Trim(Edt_Username.Text);
    FDIBBackup1.Password := Trim(Edt_Password.Text);
    FDIBBackup1.Host := Trim(Edt_Host.Text);
    case Cmb_Protocol.ItemIndex of
      0:
        FDIBBackup1.Protocol := ipLocal;
      1:
        FDIBBackup1.Protocol := ipTCPIP;
      2:
        FDIBBackup1.Protocol := ipNetBEUI;
      3:
        FDIBBackup1.Protocol := ipSPX;
    end;

    if Chx_boIgnoreChecksum.Checked then
      FDIBBackup1.Options := FDIBBackup1.Options + [boIgnoreChecksum];

    if Chx_boIgnoreLimbo.Checked then
      FDIBBackup1.Options := FDIBBackup1.Options + [boIgnoreLimbo];

    if Chx_boNoGarbageCollect.Checked then
      FDIBBackup1.Options := FDIBBackup1.Options + [boNoGarbageCollect];

    if Chx_boOldDescriptions.Checked then
      FDIBBackup1.Options := FDIBBackup1.Options + [boOldDescriptions];

    if Chx_boConvert.Checked then
      FDIBBackup1.Options := FDIBBackup1.Options + [boConvert];

    if Chx_boExpand.Checked then
      FDIBBackup1.Options := FDIBBackup1.Options + [boExpand];

    case Cmb_boNonTransportable.ItemIndex of
      0:
        FDIBBackup1.Options := FDIBBackup1.Options + [boNonTransportable];
      1:
        FDIBBackup1.Options := FDIBBackup1.Options - [boNonTransportable];
    end;

    FDIBBackup1.Verbose := Chx_Verbose.Checked;
    if ((Chx_Verbose.Checked) and (Cmb_Verbose.ItemIndex = 1)) then
      PageControl1.ActivePageIndex := 1;

    FDIBBackup1.Database := Trim(Edt_Database.Text);
    FDIBBackup1.BackupFiles.Clear;
    FDIBBackup1.BackupFiles.Add(Trim(Edt_BackupFile.Text));
    FDIBBackup1.Backup;

    FCompleteTime := ((GetTickCount - start) / 1000) / SecsPerDay;
    if ((Chx_Verbose.Checked) and (Cmb_Verbose.ItemIndex = 0)) then
    begin
      Memo1.Lines.Add('Creating log file ' + Edt_OutPutFile.Text);
      Memo1.Lines.Add('Starting Backup.Current time: ' +
        FormatDateTime('HH:MM:SS.', FStartTime));
      Memo1.Lines.Add('Backup complete Current time:)' +
        FormatDateTime('HH:MM:SS.', Now) + 'Elapsed time: ' +
        FormatDateTime('HH:MM:SS', FCompleteTime));
    end;
    PageControl1.ActivePageIndex := 1;

    EnableButtons();
  except
    on E: Exception do
    begin
      EnableButtons();
      Showmessage('Error ' + E.Message);
    end;
  end;
end;

end.
