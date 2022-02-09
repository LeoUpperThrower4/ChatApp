unit frmMainViewU;

interface

uses
  // System
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  // FMX
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  // Auth
  AuthManagerU,
  AuthViewU,
  // Chat
  ChatViewU,
  ChatManagerU,
  //FB4D
  FB4D.Interfaces;

type
  TfrmMainView = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure OnSuccessfullLogin(User: IFirebaseUser);
  private
    { Private declarations }
    procedure InitializeManagers;
    procedure DestroyManagers;
  public
    { Public declarations }
    destructor Destroy; override;

  end;

var
  frmMainView : TfrmMainView;
  AuthView    : TAuthView;
  ChatView    : TChatView;

implementation

{$R *.fmx}

/// <summary>
///   Main application form creation. Also creates the Auth form and the handlers
///   for when login is successfull
/// </summary>
procedure TfrmMainView.FormCreate(Sender: TObject);
begin
  InitializeManagers;

  AuthView := TAuthView.Create(Self);
  AuthView.Parent := Self;
  AuthView.SetOnSuccessfullLogin(OnSuccessfullLogin);
end;

/// <summary>
///   Callback function for when login is successfull. Creates Chat form
/// </summary>
procedure TfrmMainView.OnSuccessfullLogin(User: IFirebaseUser);
begin
  AuthView.Free;

  ChatView        := TChatView.Create(Self);
  ChatView.Parent := Self;
end;

/// <summary>
///   Initializes all managers
/// </summary>
procedure TfrmMainView.InitializeManagers;
begin
  if g_AuthManager <> nil
    then g_AuthManager := TAuthManager.Create;

  if g_ChatManager <> nil
    then g_ChatManager := TChatManager.Create;
end;

/// <summary>
///   Destroy all managers
/// </summary>
procedure TfrmMainView.DestroyManagers;
begin
  if Assigned(g_AuthManager)
    then g_AuthManager.Free;

  if Assigned(g_ChatManager)
    then g_ChatManager.Free;
end;

/// <summary>
///   Destroys the main application and its managers
/// </summary>
destructor TfrmMainView.Destroy;
begin
  if AuthView <> nil
    then AuthView.Free;

  DestroyManagers;

  inherited;
end;

end.
