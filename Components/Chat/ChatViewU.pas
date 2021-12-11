unit ChatViewU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Edit,
  FMX.Objects, FMX.Layouts;

type
  TChatView = class(TFrame)
    lytWriteMsg: TLayout;
    rectWriteMsgBg: TRectangle;
    edtMsg: TEdit;
    btnSend: TSpeedButton;
    rectBtnSendWrapper: TRectangle;
    Layout1: TLayout;
    Memo1: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
