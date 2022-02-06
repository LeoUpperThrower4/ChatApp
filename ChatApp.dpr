program ChatApp;
uses
  System.StartUpCopy,
  FMX.Forms,
  frmMainViewU          in 'frmMainViewU.pas' {frmMainView},
  AuthViewU             in 'Components\Auth\AuthViewU.pas' {AuthView: TFrame},
  AuthManagerU          in 'Auth\AuthManagerU.pas',
  SignUpViewU           in 'Components\Auth\SignUpViewU.pas' {Frame2: TFrame},
  ChatViewU             in 'Components\Chat\ChatViewU.pas' {ChatView: TFrame},
  SingleMsgViewU        in 'Components\Chat\SingleMsgViewU.pas' {SingleMsgView},
  RealtimeDatabaseUtils in 'Utils\RealtimeDatabaseUtils.pas',
  ChatManagerU          in 'Chat\ChatManagerU.pas',
  ChatInterfaces        in 'Chat\ChatInterfaces.pas';

{$R *.res}
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TfrmMainView, frmMainView);
  Application.Run;
end.
