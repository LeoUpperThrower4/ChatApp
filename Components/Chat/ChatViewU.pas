unit ChatViewU;
interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Edit,
  FMX.Objects, FMX.Layouts,
  // View
  SingleMsgViewU,
  // Manager
  AuthManagerU,
  // Utils
  JSON,
  // FB4D
  FB4D.RealTimeDB, FB4D.Interfaces, FB4D.Configuration;
type
  TChatView = class(TFrame)
    lytWriteMsg       : TLayout;
    rectWriteMsgBg    : TRectangle;
    edtMsg            : TEdit;
    btnSend           : TSpeedButton;
    rectBtnSendWrapper: TRectangle;
    Layout1           : TLayout;
    flwlytMsg         : TFlowLayout;
    procedure btnSendClick(Sender: TObject);
  private
    fEvent            : IFirebaseEvent;
    fConfig           : IFirebaseConfiguration;
    RTDB              : TRealTimeDB;
    procedure OnDBStop(Sender: TObject);
    procedure StartListening;
    procedure OnDBEvent(const Event: string; Params: TRequestResourceParam; JSONObj: TJSONObject);
    procedure OnDBError(const RequestID, ErrMsg: string);
    { Private declarations }
  public
    { Public declarations }
  constructor Create(AOwner: TComponent); override;
  destructor Destroy;
  end;

implementation
{$R *.fmx}
{ TChatView }

procedure TChatView.StartListening;
begin
  // Inicializa a variavel de evento
  fConfig := TFirebaseConfiguration.Create('AIzaSyDUcS4IWiC7PVYH-5LT69gy--NJHmPZXs4', 'chatapp-31972', 'gs://chatapp-31972.appspot.com', 'https://chatapp-31972-default-rtdb.firebaseio.com/');
  fEvent  := TFirebaseEvent.Create;

  // Comeca a ouvir por mudancas no server
  fEvent := RTDB.ListenForValueEvents(['Global', 'messages'], OnDBEvent, OnDBStop,
    OnDBError, nil);
end;

procedure TChatView.OnDBStop(Sender: TObject);
begin
  ShowMessage('DB Listener was stopped - restart App');
end;

procedure TChatView.OnDBEvent(const Event: string;
  Params: TRequestResourceParam; JSONObj: TJSONObject);
begin
  ShowMessage(JSONObj.GetValue<string>(cData));
//    btnWrite.Enabled := false;
//    lblStatus.Text := 'Last read: ' + DateTimeToStr(now);
end;

procedure TChatView.OnDBError(const RequestID, ErrMsg: string);
begin
  ShowMessage(RequestID + ': ' + ErrMsg);
end;

procedure TChatView.btnSendClick(Sender: TObject);
var
  msgJSON  : TJSONObject;
  dataPair : TJSONPair;
begin
  try
    // Cria objeto da mensagem...
    msgJSON := TJSONObject.Create;

    // Adiciona Message ao objeto
    dataPair := TJSONPair.Create('Message',edtMsg.Text);
    msgJSON.AddPair(dataPair);

    // Adiciona SentAt ao objeto
    dataPair := TJSONPair.Create('SentAt',DateToStr(now));
    msgJSON.AddPair(dataPair);

    // Adiciona SentBy ao objeto
    dataPair := TJSONPair.Create('SentBy',g_AuthManager.CurrentUser.EMail);
    msgJSON.AddPair(dataPair);

    // Envia mensagem ao servidor


    // Adicionar mensagem na tela
  finally
    if msgJSON <> nil
      then msgJSON.Free;
  end;
end;

constructor TChatView.Create(AOwner: TComponent);
begin
  inherited;

  fEvent := TFirebaseEvent.Create;

  // Inicializa o Realtime Database
  RTDB := TRealTimeDB.Create('https://chatapp-31972-default-rtdb.firebaseio.com/', g_AuthManager.Authenticator);

  // Carrega mensagens antigas

  // Inicia o listener do banco de dados para esperar por novas mensagens
  //StartListening;
end;

destructor TChatView.Destroy;
begin
  fEvent.StopListening;
end;

end.
