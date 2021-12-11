unit AuthViewU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation,
  // Auth
  AuthManagerU,
  SignUpViewU,
  LoginViewU,
  // Chat
  ChatViewU,
  // FB4D
  FB4D.Interfaces;

type
  OnUserSuccessfullyLoggedIn = procedure(User: IFirebaseUser) of object;
  TAuthMode = (amLogin, amSignUp);
  TAuthView = class(TFrame)
    rectBg: TRectangle;
    rectMiddle: TRectangle;
    rectPicture: TRoundRect;
    lytProfilePic: TLayout;
    lytAuthMode: TLayout;
    rectBottom: TRectangle;
    lblLogin: TLabel;
    lblSignUp: TLabel;
    rectBtnLogin: TRectangle;
    rectBtnSignUp: TRectangle;
    rectSeparator: TRectangle;
    lytForm: TLayout;
    lytBtn: TLayout;
    rectBtnSubmit: TRectangle;
    lblBtnSubmit: TLabel;
    procedure OnUserResponse(const Info: string; User: IFirebaseUser);
    procedure OnError       (const RequestID, ErrMsg: string);
    procedure rectBtnLoginClick(Sender: TObject);
    procedure rectBtnSignUpClick(Sender: TObject);
    procedure SetLoginForm;
    procedure SetSignUpForm;
    procedure SetOnSuccessfullLogin(Callback : OnUserSuccessfullyLoggedIn);
    constructor Create(AComponent : TComponent);
    procedure rectBtnSubmitClick(Sender: TObject);
  private
    { Private declarations }
    SignUpFrame         : TSignUpView;
    LoginFrame          : TLoginView;
    AuthManager         : TAuthManager;
    FAuthMode           : TAuthMode;
    FOnSuccessfullLogin : OnUserSuccessfullyLoggedIn;
    procedure SetLoginBtnActive;
    procedure SetSignUpBtnActive;
    procedure StartLoadingState;
    procedure StopLoadingState;
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

{ TAuthView }

constructor TAuthView.Create(AComponent : TComponent);
begin
  inherited Create(AComponent);
  AuthManager := TAuthManager.Create;
  SetLoginBtnActive;
end;

procedure TAuthView.OnError(const RequestID, ErrMsg: string);
begin
  ShowMessage(ErrMsg);
  // Tratar esses erros
end;

procedure TAuthView.OnUserResponse(const Info: string; User: IFirebaseUser);
var
  email: string;
begin
  if Info.Contains('Sign in') then
  begin
    FOnSuccessfullLogin(User);
  end
  else
  begin
    email := SignUpFrame.edtEmail.Text.Trim;
    SetLoginBtnActive;
    LoginFrame.edtEmail.Text := email;
  end;
end;

procedure TAuthView.rectBtnLoginClick(Sender: TObject);
begin
  SetLoginBtnActive;
end;

procedure TAuthView.rectBtnSignUpClick(Sender: TObject);
begin
  SetSignUpBtnActive;
end;

procedure TAuthView.rectBtnSubmitClick(Sender: TObject);
begin
  StartLoadingState;
  if FAuthMode = amLogin then
  begin
    AuthManager.EmailLogin(LoginFrame.edtEmail.Text.Trim, LoginFrame.edtPwd.Text.Trim, OnUserResponse, OnError);
  end
  else
  begin
    AuthManager.EmailSignUp(SignUpFrame.edtEmail.Text.Trim, SignUpFrame.edtPwd.Text.Trim, OnUserResponse, OnError);
  end;
  StopLoadingState;
end;

procedure TAuthView.SetLoginBtnActive;
begin
  // Configure Login label
  lblLogin.TextSettings.Font.Style  := TFontStyleExt.Create(TFontWeight.Bold);
  lblLogin.TextSettings.FontColor   := TAlphaColor($FFF0F0F0);
  // Set SignUp label as default
  lblSignUp.TextSettings.Font.Style := TFontStyleExt.Default;
  lblSignUp.TextSettings.FontColor  := TAlphaColor($FF4E5E63);
  rectBottom.Position.X             := 0;

  SetLoginForm;
  FAuthMode := amLogin;
end;

procedure TAuthView.SetSignUpBtnActive;
begin
  // Configure SignUp label
  lblSignUp.TextSettings.Font.Style := TFontStyleExt.Create(TFontWeight.Bold);
  lblSignUp.TextSettings.FontColor  := TAlphaColor($FFF0F0F0);
  // Set Login label as default
  lblLogin.TextSettings.Font.Style  := TFontStyleExt.Default;
  lblLogin.TextSettings.FontColor   := TAlphaColor($FF4E5E63);
  rectBottom.Position.X             := 100;

  SetSignUpForm;
  FAuthMode := amSignUp;
end;

procedure TAuthView.SetSignUpForm;
begin
  if LoginFrame <> nil
    then FreeAndNil(LoginFrame);

  if SignUpFrame = nil then
  begin
    SignUpFrame := TSignUpView.Create(lytForm);
    SignUpFrame.Parent := lytForm;
    rectMiddle.Height := rectMiddle.Height + 50;
  end;
end;

procedure TAuthView.StartLoadingState;
begin
  rectBtnSubmit.Enabled := False;
  if SignUpFrame <> nil then
  begin
    SignUpFrame.edtEmail.Enabled := False;
    SignUpFrame.edtPwd.Enabled   := False;
  end
  else
  begin
    LoginFrame.edtEmail.Enabled := False;
    LoginFrame.edtPwd.Enabled   := False;
  end;
end;

procedure TAuthView.StopLoadingState;
begin
  rectBtnSubmit.Enabled := True;
  if SignUpFrame <> nil then
  begin
    SignUpFrame.edtEmail.Enabled := True;
    SignUpFrame.edtPwd.Enabled   := True;
  end
  else
  begin
    LoginFrame.edtEmail.Enabled := True;
    LoginFrame.edtPwd.Enabled   := True;
  end;
end;

procedure TAuthView.SetLoginForm;
begin
  if SignUpFrame <> nil
  then FreeAndNil(SignUpFrame);

  if LoginFrame = nil then
  begin
    LoginFrame := TLoginView.Create(lytForm);
    LoginFrame.Parent := lytForm;
    rectMiddle.Height := rectMiddle.Height - 50;
  end;
end;

procedure TAuthView.SetOnSuccessfullLogin(Callback: OnUserSuccessfullyLoggedIn);
begin
  FOnSuccessfullLogin := Callback;
end;

end.
