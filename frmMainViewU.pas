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
  AuthViewU;

type
  TfrmMainView = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMainView : TfrmMainView;
  AuthView    : TAuthView;

implementation

{$R *.fmx}

procedure TfrmMainView.FormCreate(Sender: TObject);
begin
  AuthView := TAuthView.Create(Self);
  AuthView.Parent := Self;
end;

end.
