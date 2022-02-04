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

procedure TfrmMainView.FormCreate(Sender: TObject);
begin
  InitializeManagers;

  AuthView := TAuthView.Create(Self);
  AuthView.Parent := Self;
  AuthView.SetOnSuccessfullLogin(OnSuccessfullLogin);

end;

procedure TfrmMainView.OnSuccessfullLogin(User: IFirebaseUser);
begin
  AuthView.Free;

  ChatView        := TChatView.Create(Self);
  ChatView.Parent := Self;
end;

procedure TfrmMainView.InitializeManagers;
begin
  if not Assigned(g_AuthManager)
    then g_AuthManager := TAuthManager.Create;

  if not Assigned(g_ChatManager)
    then g_ChatManager := TChatManager.Create;
end;

procedure TfrmMainView.DestroyManagers;
begin
  if Assigned(g_AuthManager)
    then g_AuthManager.Free;

  if Assigned(g_ChatManager)
    then g_ChatManager.Free;
end;

destructor TfrmMainView.Destroy;
begin
  if Assigned(AuthView)
    then AuthView.Free;

  DestroyManagers;

  inherited;
end;

end.
