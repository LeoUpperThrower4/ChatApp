unit LoginViewU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit;

type
  TLoginView = class(TFrame)
    edtEmail: TEdit;
    lblEmail: TLabel;
    edtPwd: TEdit;
    lblSenha: TLabel;
    lytEmail: TLayout;
    lytSenha: TLayout;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
