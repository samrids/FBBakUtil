program BakupFBUtil;

uses
  Vcl.Forms,
  fmain in 'fmain.pas' {frmMainBak};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainBak, frmMainBak);
  Application.Run;
end.
