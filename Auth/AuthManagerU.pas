unit AuthManagerU;

interface
uses 
  FB4D.Interfaces;
  
type
  TAuthManager = class
  private
    FAuthenticated : Boolean;
    FApiKey        : String;
    FHasValidApiKey: Boolean;
    FAuthenticator  : IFirebaseAuthentication;
    function SearchApiKeyInReg(var error : string)  : Boolean;
  public
    function isAuthenticated: Boolean;
    function HasValidApiKey : Boolean;
    function EmailLogin (email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError) : Boolean;
    function EmailSignUp(email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError) : Boolean;
    constructor Create;
  end;

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
    FAuthenticator := TFirebaseAuthentication.Create(FApiKey);
  end;
end;

function TAuthManager.SearchApiKeyInReg(var error : string): Boolean;
var
  Reg : TRegistry;
begin
  error := '';
  Result := False;
  Reg := TRegistry.Create;
  try 
    if Reg.OpenKey('\ChatApp\FB', False) then
    begin
      FApiKey := Reg.ReadString('WebApiKey');  
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

function TAuthManager.isAuthenticated: Boolean;
begin
  Result := FAuthenticated;
end;

function TAuthManager.EmailLogin(email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError): Boolean;
begin
  Result := False;
  if Assigned(FAuthenticator) then
  begin
    FAuthenticator.SignInWithEmailAndPassword(email, pwd, OnUserResponse, OnError);
    Result := True;
  end;
end;

function TAuthManager.EmailSignUp(email, pwd: string; OnUserResponse: TOnUserResponse; OnError: TOnRequestError): Boolean;
begin
  Result := False;
  if Assigned(FAuthenticator) then
  begin
    FAuthenticator.SignUpWithEmailAndPassword(email, pwd, OnUserResponse, OnError);
    Result := True;
  end;
end;

function TAuthManager.HasValidApiKey : Boolean;
begin
  Result := FHasValidApiKey;
end;

end.
