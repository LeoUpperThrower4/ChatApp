unit SingleMsgViewU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TSingleMsgView = class(TForm)
    lblName: TLabel;
    lblMsg: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SingleMsgView: TSingleMsgView;

implementation

{$R *.fmx}

end.
