unit AuthManagerU;

interface
uses 
  FB4D.Interfaces,
  RealtimeDatabaseUtils;
  
type
  TAuthManager = class
  private
    FAuthenticated  : Boolean;
    FOnUserLoggedIn : TOnUserResponse;
    procedure SetOnUserLoggedIn(OnUserResponse: TOnUserResponse);
    procedure OnUserLoggedIn(const Info: string; User: IFirebaseUser);
  public
    CurrentUser              : IFirebaseUser;
    Authenticator            : IFirebaseAuthentication;
    property isAuthenticated : Boolean read FAuthenticated;
    function EmailLogin (email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError) : Boolean;
    function EmailSignUp(email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError) : Boolean;
    constructor Create;
  end;

var
  g_AuthManager: TAuthManager;

implementation

uses
  FB4D.Authentication,
  Winapi.Windows;

{ TAuth }

/// <summary>
///   Creates the object and initializes the Authenticator variable
/// </summary>
constructor TAuthManager.Create;
begin
  inherited;

  FAuthenticated := False;
  Authenticator  := TFirebaseAuthentication.Create(RealtimeDatabaseWebAPIKey);
end;

/// <summary>
///   Sets the callback function that will be called when login is succesfull
/// </summary>
/// <param name="OnUserResponse">
///   The function that will be called
/// </param>
procedure TAuthManager.SetOnUserLoggedIn(OnUserResponse: TOnUserResponse);
begin
  FOnUserLoggedIn := OnUserResponse;
end;

/// <summary>
///   Function that is always called when login is succesfull. It is responsible
///   for setting the current session user and changing the state of AuthManager
///   to Authenticated
/// </summary>
/// <param name="User">
///   User info
/// </param>
procedure TAuthManager.OnUserLoggedIn(const Info: string; User: IFirebaseUser);
begin
  CurrentUser    := User;
  FAuthenticated := True;
  FOnUserLoggedIn(Info, User);
end;

/// <summary>
///   Try to login via email authentication
/// </summary>
/// <param name="email">
///   User email
/// </param>
/// <param name="pwd">
///   User password
/// </param>
/// <param name="OnUserResponse">
///   Callback function that will be called when login is succesfull
/// </param>
/// <param name="OnError">
///   Callback function that will be called when login has failed
/// </param>
/// <returns>
///   Boolean indicating whether login was successfull or not
/// </returns>
function TAuthManager.EmailLogin(email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError): Boolean;
begin
  Result := False;
  if Assigned(Authenticator) then
  begin
    Result := True;
    SetOnUserLoggedIn(OnUserResponse);
    Authenticator.SignInWithEmailAndPassword(email, pwd, OnUserLoggedIn, OnError)
  end
  else
  begin
    Authenticator := TFirebaseAuthentication.Create(RealtimeDatabaseWebAPIKey);
    EmailLogin(email, pwd, OnUserResponse, OnError);
  end;
end;

/// <summary>
///   Try to sign up via email authentication
/// </summary>
/// <param name="email">
///   User email
/// </param>
/// <param name="pwd">
///   User password
/// </param>
/// <param name="OnUserResponse">
///   Callback function that will be called when sign up is succesfull
/// </param>
/// <param name="OnError">
///   Callback function that will be called when sign up has failed
/// </param>
/// <returns>
///   Boolean indicating whether sign up was successfull or not
/// </returns>
function TAuthManager.EmailSignUp(email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError): Boolean;
begin
  Result := False;
  if Assigned(Authenticator) then
  begin
    Result := True;
    Authenticator.SignUpWithEmailAndPassword(email, pwd, OnUserResponse, OnError);
  end
  else
  begin
    Authenticator := TFirebaseAuthentication.Create(RealtimeDatabaseWebAPIKey);
    EmailSignUp(email, pwd, OnUserResponse, OnError)
  end;
end;


end.
