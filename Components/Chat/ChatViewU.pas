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
  ChatManagerU,
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
    function  CreateMsgJSONObject : TJSONObject;
    procedure btnSendClick        (Sender: TObject);
    procedure OnMessagesUpdated   (ResourceParams: TRequestResourceParam; Val: TJSONValue);
    procedure OnMessageSent       (ResourceParams: TRequestResourceParam; Val: TJSONValue);
    procedure OnMessageFailToSend (const RequestID, ErrMsg: string);
  private
    fEvent            : IFirebaseEvent;
    fConfig           : IFirebaseConfiguration;
    RTDB              : TRealTimeDB;
//    procedure OnDBStop(Sender: TObject);
//    procedure StartListening;
//    procedure OnDBEvent(const Event: string; Params: TRequestResourceParam; JSONObj: TJSONObject);
//    procedure OnDBError(const RequestID, ErrMsg: string);
    { Private declarations }
  public
    { Public declarations }
  constructor Create(AOwner: TComponent); override;
  end;

implementation
{$R *.fmx}
{ TChatView }

//procedure TChatView.StartListening;
//begin
//  // Inicializa a variavel de evento
//  fConfig := TFirebaseConfiguration.Create('AIzaSyDUcS4IWiC7PVYH-5LT69gy--NJHmPZXs4', 'chatapp-31972', 'gs://chatapp-31972.appspot.com', 'https://chatapp-31972-default-rtdb.firebaseio.com/');
//  fEvent  := TFirebaseEvent.Create;
//
//  // Comeca a ouvir por mudancas no server
//  fEvent := RTDB.ListenForValueEvents(['Global', 'messages'], OnDBEvent, OnDBStop,
//    OnDBError, nil);
//end;
//
//procedure TChatView.OnDBStop(Sender: TObject);
//begin
//  ShowMessage('DB Listener was stopped - restart App');
//end;
//
//procedure TChatView.OnDBEvent(const Event: string;
//  Params: TRequestResourceParam; JSONObj: TJSONObject);
//begin
//  ShowMessage(JSONObj.GetValue<string>(cData));
////    btnWrite.Enabled := false;
////    lblStatus.Text := 'Last read: ' + DateTimeToStr(now);
//end;

//procedure TChatView.OnDBError(const RequestID, ErrMsg: string);
//begin
//  ShowMessage(RequestID + ': ' + ErrMsg);
//end;

procedure TChatView.OnMessageFailToSend(const RequestID, ErrMsg: string);
begin
  ShowMessage(ErrMsg);
end;

procedure TChatView.OnMessageSent(ResourceParams: TRequestResourceParam; Val: TJSONValue);
begin
  edtMsg.Text := '';
  // Atualizar parte visual do chat (falta a issue $10 ficar pronta)
end;

function TChatView.CreateMsgJSONObject: TJSONObject;
var
  msgJSON  : TJSONObject;
  dataPair : TJSONPair;
begin
  try
    msgJSON := TJSONObject.Create;

    dataPair := TJSONPair.Create('Message',edtMsg.Text.Trim);
    msgJSON.AddPair(dataPair);

    dataPair := TJSONPair.Create('SentAt',DateToStr(now));
    msgJSON.AddPair(dataPair);

    dataPair := TJSONPair.Create('SentBy',g_AuthManager.CurrentUser.EMail);
    msgJSON.AddPair(dataPair);

    Result := msgJSON.Clone as TJSONObject;
  finally
    if msgJSON <> nil
      then msgJSON.Free;
  end;
end;

procedure TChatView.btnSendClick(Sender: TObject);
var
  ChatMsgJSON : TJSONObject;
begin
  if edtMsg.Text.Trim <> '' then
  begin
    ChatMsgJSON := CreateMsgJSONObject;

    g_ChatManager.SendMessage(ChatMsgJSON, OnMessageSent, OnMessageFailToSend);
  end;
end;

procedure TChatView.OnMessagesUpdated(ResourceParams: TRequestResourceParam; Val: TJSONValue);
begin
  btnSend.Enabled := True;
end;

constructor TChatView.Create(AOwner: TComponent);
begin
  inherited;

  fEvent := TFirebaseEvent.Create;

  g_ChatManager := TChatManager.Create;

  g_ChatManager.UpdateLatestMessages(OnMessagesUpdated, nil);

  // Inicia o listener do banco de dados para esperar por novas mensagens
  // StartListening;
end;

end.
