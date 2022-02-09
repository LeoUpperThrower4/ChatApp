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
    procedure rectBtnSubmitClick(Sender: TObject);
  private
    { Private declarations }
    SignUpFrame         : TSignUpView;
    LoginFrame          : TLoginView;
    FAuthMode           : TAuthMode;
    FOnSuccessfullLogin : OnUserSuccessfullyLoggedIn;
    procedure SetLoginBtnActive;
    procedure SetSignUpBtnActive;
    procedure StartLoadingState;
    procedure StopLoadingState;
  public
    { Public declarations }
    constructor Create(AComponent : TComponent);
  end;

implementation

{$R *.fmx}

{ TAuthView }

/// <summary>
///   Creates the Auth form.
/// </summary>
constructor TAuthView.Create(AComponent : TComponent);
begin
  inherited Create(AComponent);

  SetLoginBtnActive;
end;

/// <summary>
///   Callback function that is called when authentication error happens. Only
///   show message error
/// </summary>
procedure TAuthView.OnError(const RequestID, ErrMsg: string);
var
  msg : String;
begin
  StopLoadingState;
  ShowMessage(ErrMsg);
  if Assigned(SignUpFrame) then
  begin
    if ErrMsg = 'INVALID_EMAIL' then
    begin
      ShowMessage('Invalid email!');
      // Perform a simple animation
    end
    else if ErrMsg = 'MISSING_PASSWORD' then
    begin
      ShowMessage('You forgot the password!');
      // Perform a simple animation
    end;
  end;
end;

/// <summary>
///   Callback function that is called when authentication is successfull. If it
///   is sign in, executes the defined successfull login procedure; if it is sign up,
///   then sets login form with the entered info
/// </summary>
procedure TAuthView.OnUserResponse(const Info: string; User: IFirebaseUser);
var
  email: string;
begin
  StopLoadingState;
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

/// <summary>
///   Handle click of the rectangle that sets the login frame
/// </summary>
procedure TAuthView.rectBtnLoginClick(Sender: TObject);
begin
  SetLoginBtnActive;
end;

/// <summary>
///   Handle click of the rectangle that sets the sign up frame
/// </summary>
procedure TAuthView.rectBtnSignUpClick(Sender: TObject);
begin
  SetSignUpBtnActive;
end;

/// <summary>
///   Handles click on the submit button. If login frame is set, it tries to logs
///   in, otherwise, tries to signs up
/// </summary>
procedure TAuthView.rectBtnSubmitClick(Sender: TObject);
begin
  StartLoadingState;
  if FAuthMode = amLogin then
  begin
    g_AuthManager.EmailLogin(LoginFrame.edtEmail.Text.Trim, LoginFrame.edtPwd.Text.Trim, OnUserResponse, OnError);
  end
  else
  begin
    g_AuthManager.EmailSignUp(SignUpFrame.edtEmail.Text.Trim, SignUpFrame.edtPwd.Text.Trim, OnUserResponse, OnError);
  end;
end;

/// <summary>
///   Sets visual components to Login mode
/// </summary>
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

/// <summary>
///   Sets visual components to Sign up mode
/// </summary>
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

/// <summary>
///   Sets Sign up frame
/// </summary>
procedure TAuthView.SetSignUpForm;
begin
  if LoginFrame <> nil
    then FreeAndNil(LoginFrame);

  if SignUpFrame = nil then
  begin
    SignUpFrame := TSignUpView.Create(lytForm);
    SignUpFrame.Parent := lytForm;
    rectMiddle.Height  := rectMiddle.Height + 50;
  end;
end;

/// <summary>
///   Starts loading state by disabling edits and buttons
/// </summary>
procedure TAuthView.StartLoadingState;
begin
  rectBtnSubmit.Enabled := False;
  if SignUpFrame <> nil then
  begin
    SignUpFrame.edtEmail.Enabled := False;
    SignUpFrame.edtPwd.Enabled   := False;
    SignUpFrame.edtName.Enabled  := False;
  end
  else
  begin
    LoginFrame.edtEmail.Enabled := False;
    LoginFrame.edtPwd.Enabled   := False;
  end;
end;

/// <summary>
///   Starts loading state by disabling edits and buttons
/// </summary>
procedure TAuthView.StopLoadingState;
begin
  rectBtnSubmit.Enabled := True;
  if SignUpFrame <> nil then
  begin
    SignUpFrame.edtEmail.Enabled := True;
    SignUpFrame.edtPwd.Enabled   := True;
    SignUpFrame.edtName.Enabled  := True;
  end
  else
  begin
    LoginFrame.edtEmail.Enabled := True;
    LoginFrame.edtPwd.Enabled   := True;
  end;
end;

/// <summary>
///   Sets Login in frame
/// </summary>
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

/// <summary>
///   Sets the local callback that will be called when successfull login occurs
/// </summary>
procedure TAuthView.SetOnSuccessfullLogin(Callback: OnUserSuccessfullyLoggedIn);
begin
  FOnSuccessfullLogin := Callback;
end;

end.
