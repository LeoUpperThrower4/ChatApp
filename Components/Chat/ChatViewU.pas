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
    lytWriteMsg           : TLayout;
    rectWriteMsgBg        : TRectangle;
    edtMsg                : TEdit;
    btnSend               : TSpeedButton;
    rectBtnSendWrapper    : TRectangle;
    vrtscrlbxMessagesView : TVertScrollBox;
    lytMessagesView       : TFlowLayout;
    function  CreateMsgJSONObject : TJSONObject;
    procedure btnSendClick        (Sender: TObject);
    procedure OnMessagesUpdated   (ResourceParams: TRequestResourceParam; Val: TJSONValue);
    procedure OnMessageSent       (ResourceParams: TRequestResourceParam; Val: TJSONValue);
    procedure OnMessageFailToSend (const RequestID, ErrMsg: string);
  private
    fEvent                : IFirebaseEvent;
    fConfig               : IFirebaseConfiguration;
    RTDB                  : TRealTimeDB;
    procedure UpdateLytMessagesView;
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

uses
  frmMainViewU;

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
  UpdateLytMessagesView;
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

    UpdateLytMessagesView;
  end;
end;

procedure TChatView.UpdateLytMessagesView;
var
  ChatMsgJSON   : TJSONValue;
  SingleMsgView : TSingleMsgView;
begin
  lytMessagesView.Controls.DeleteRange(0, lytMessagesView.Controls.Count);
  for ChatMsgJSON in g_ChatManager.Messages do
  begin
    SingleMsgView := TSingleMsgView.Create(lytMessagesView);
    SingleMsgView.pnlSingleMsgView.Parent := lytMessagesView;
    SingleMsgView.lblSentBy.Text          := ChatMsgJSON.GetValue<String>('SentBy','...');
    SingleMsgView.lblMsg.Text             := ChatMsgJSON.GetValue<String>('Message','...');
    SingleMsgView.lblDateTime.Text        := ChatMsgJSON.GetValue<String>('SentAt','...');
    lytMessagesView.AddObject(SingleMsgView.pnlSingleMsgView);
    // TODO: Adicionar um separador
  end;

  lytMessagesView.Height := (g_ChatManager.Messages.Count * SingleMsgView.pnlSingleMsgView.Height);
  lytMessagesView.Width  := 400;
end;

procedure TChatView.OnMessagesUpdated(ResourceParams: TRequestResourceParam; Val: TJSONValue);
begin
  btnSend.Enabled := True;

  UpdateLytMessagesView;
end;

constructor TChatView.Create(AOwner: TComponent);
begin
  inherited;

  fEvent := TFirebaseEvent.Create;

  g_ChatManager := TChatManager.Create;

  g_ChatManager.UpdateLatestMessages(OnMessagesUpdated, nil);

  frmMainView.Width := 400;

  lytMessagesView.Parent := vrtscrlbxMessagesView;

  // Inicia o listener do banco de dados para esperar por novas mensagens
  // StartListening;
end;

end.
