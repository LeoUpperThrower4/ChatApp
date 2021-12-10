program ChatApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmMainViewU in 'frmMainViewU.pas' {frmMainView};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMainView, frmMainView);
  Application.Run;
end.
