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
  Win.Registry, Winapi.Windows,
  FB4D.Authentication;

{ TAuth }

constructor TAuthManager.Create;
var
  error : string;
begin
  FAuthenticated  := False;
  Authenticator := TFirebaseAuthentication.Create(RealtimeDatabaseWebAPIKey);
end;

procedure TAuthManager.SetOnUserLoggedIn(OnUserResponse: TOnUserResponse);
begin
  FOnUserLoggedIn := OnUserResponse;
end;

procedure TAuthManager.OnUserLoggedIn(const Info: string; User: IFirebaseUser);
begin
  CurrentUser    := User;
  FAuthenticated := True;
  FOnUserLoggedIn(Info, User);
end;

function TAuthManager.EmailLogin(email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError): Boolean;
begin
  Result := False;
  if Assigned(Authenticator) then
  begin
    Result := True;
    SetOnUserLoggedIn(OnUserResponse);
    Authenticator.SignInWithEmailAndPassword(email, pwd, OnUserLoggedIn, OnError)
  end;
end;

function TAuthManager.EmailSignUp(email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError): Boolean;
begin
  Result := False;
  if Assigned(Authenticator) then
  begin
    Result := True;
    Authenticator.SignUpWithEmailAndPassword(email, pwd, OnUserResponse, OnError);
  end;
end;

end.
