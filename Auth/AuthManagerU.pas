unit AuthManagerU;

interface
uses 
  FB4D.Interfaces;
  
type
  TAuthManager = class
  private
    FAuthenticated  : Boolean;
    FApiKey         : String;
    FHasValidApiKey : Boolean;
    FOnUserLoggedIn : TOnUserResponse;
    function SearchApiKeyInReg(var error : string)  : Boolean;
    procedure SetOnUserLoggedIn(OnUserResponse: TOnUserResponse);
    procedure OnUserLoggedIn(const Info: string; User: IFirebaseUser);
  public
    CurrentUser              : IFirebaseUser;
    Authenticator            : IFirebaseAuthentication;
    property isAuthenticated : Boolean read FAuthenticated;
    function HasValidApiKey  : Boolean;
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
  FHasValidApiKey := SearchApiKeyInReg(error);
  if HasValidApiKey then
  begin
    Authenticator := TFirebaseAuthentication.Create(FApiKey);
  end;
end;

function TAuthManager.SearchApiKeyInReg(var error : string): Boolean;
var
  Reg : TRegistry;
begin
  error := '';
  Result := False;
  Reg := TRegistry.Create;

//  Reg.OpenKey('\ChatApp\Firebase', True);
//  Reg.WriteString('WebAPIKey', 'AIzaSyDUcS4IWiC7PVYH-5LT69gy--NJHmPZXs4');
  try
    if Reg.OpenKey('\ChatApp\Firebase', False) then
    begin
      FApiKey := Reg.ReadString('WebAPIKey');
      Result := True;
    end
    else
    begin
      error := 'API Key not valid';
    end;
  finally
    Reg.Free;
  end;
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

function TAuthManager.HasValidApiKey : Boolean;
begin
  Result := FHasValidApiKey;
end;

end.
