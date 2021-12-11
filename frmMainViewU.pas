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
  //FB4D
  FB4D.Interfaces;

type
  TfrmMainView = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure OnSuccessfullLogin(User: IFirebaseUser);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  frmMainView : TfrmMainView;
  AuthView    : TAuthView;
  ChatView    : TChatView;

implementation

{$R *.fmx}

procedure TfrmMainView.FormCreate(Sender: TObject);
begin
  AuthView := TAuthView.Create(Self);
  AuthView.SetOnSuccessfullLogin(OnSuccessfullLogin);
  AuthView.Parent := Self;
end;

procedure TfrmMainView.FormDestroy(Sender: TObject);
begin
  if Assigned(ChatView)
    then ChatView.Free;
end;

procedure TfrmMainView.OnSuccessfullLogin(User: IFirebaseUser);
begin
  AuthView.Free;

  ChatView := TChatView.Create(Self);
  ChatView.Parent := Self;
end;

end.
