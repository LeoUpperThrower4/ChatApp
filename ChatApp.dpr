program ChatApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  frmMainViewU       in 'frmMainViewU.pas' {frmMainView},
  AuthViewU          in 'Components\Auth\AuthViewU.pas' {AuthView: TFrame},
  AuthBtnViewU       in 'Components\Auth\AuthBtnViewU.pas' {Frame1: TFrame},
  AuthManagerU       in 'Auth\AuthManagerU.pas',
  AuthViewDataTypesU in 'Auth\AuthViewDataTypesU.pas',
  SignUpViewU        in 'Components\Auth\SignUpViewU.pas' {Frame2: TFrame},
  ChatViewU          in 'Components\Chat\ChatViewU.pas' {ChatView: TFrame},
  SingleMsgViewU     in 'Components\Chat\SingleMsgViewU.pas' {SingleMsgView};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMainView, frmMainView);
  Application.Run;
end.
