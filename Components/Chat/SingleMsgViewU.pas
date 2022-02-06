unit SingleMsgViewU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects;

type
  TSingleMsgView = class(TForm)
    lblDateTime: TLabel;
    lblMsg: TLabel;
    lblSentBy: TLabel;
    crSingleMessageView: TCalloutRectangle;
    rectLeft: TRectangle;
    rectDate: TRectangle;
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
