unit SignUpViewU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit;

type
  TSignUpView = class(TFrame)
    edtName: TEdit;
    lblName: TLabel;
    lytName: TLayout;
    lytPwd: TLayout;
    edtPwd: TEdit;
    lblPwd: TLabel;
    lytEmail: TLayout;
    edtEmail: TEdit;
    lblEmail: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
