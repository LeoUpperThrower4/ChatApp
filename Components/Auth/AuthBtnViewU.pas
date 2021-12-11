unit AuthBtnViewU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects;

type
  TAuthButton = class (TComponent)
    rectBtn: TRectangle;
    lblTitle: TLabel;
    Rectangle3: TRectangle;
    constructor Create(AComponent : TComponent); override;
  end;


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('AuthComps', [TAuthButton]);
end;

{$R *.fmx}

{ TAuthButton }

constructor TAuthButton.Create(AComponent: TComponent);
begin
  inherited;
   rectBtn := TRectangle.Create(Self);
   lblTitle := TLabel.Create(Self);
end;

end.
