unit ChatViewU;

interface
uses
  // Default
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Edit,
  FMX.Objects, FMX.Layouts,
  // View
  SingleMsgViewU,
  // Manager
  AuthManagerU,
  ChatManagerU,
  // Interfaces
  ChatInterfaces,
  // Utils
  JSON,
  // FB4D
  FB4D.RealTimeDB, FB4D.Interfaces, FB4D.Configuration;
type
  TChatView = class(TFrame, IChatUpdateNotifiable)
    lytWriteMsg           : TLayout;
    rectWriteMsgBg        : TRectangle;
    edtMsg                : TEdit;
    btnSend               : TSpeedButton;
    rectBtnSendWrapper    : TRectangle;
    vrtscrlbxMessagesView : TVertScrollBox;
    lytMessagesView       : TFlowLayout;
    function  CreateMsgJSONObject : TJSONObject;
    procedure OnMessageSent       (ResourceParams: TRequestResourceParam; Val: TJSONValue);
    procedure OnMessageFailToSend (const RequestID, ErrMsg: string);
    procedure btnSendClick        (Sender: TObject);
  private
    { Private declarations }
    procedure BlockSendingMessages;
    procedure EnableSendingMessages;
  public
    { Public declarations }
    procedure UpdateChatView;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses
  frmMainViewU;

{$R *.fmx}

{ TChatView }

function TChatView.CreateMsgJSONObject: TJSONObject;
var
  msgJSON  : TJSONObject;
  dataPair : TJSONPair;
begin
  msgJSON := TJSONObject.Create;

  dataPair := TJSONPair.Create('Message',edtMsg.Text.Trim);
  msgJSON.AddPair(dataPair);

  dataPair := TJSONPair.Create('SentAt',DateToStr(now));
  msgJSON.AddPair(dataPair);

  dataPair := TJSONPair.Create('SentBy',g_AuthManager.CurrentUser.EMail);
  msgJSON.AddPair(dataPair);

  Result := msgJSON;
end;

procedure TChatView.BlockSendingMessages;
begin
  edtMsg.Enabled  := False;
  btnSend.Enabled := False;
end;

procedure TChatView.EnableSendingMessages;
begin
  edtMsg.Enabled  := True;
  btnSend.Enabled := True;
end;

procedure TChatView.btnSendClick(Sender: TObject);
var
  ChatMsgJSON : TJSONValue;
begin
  if edtMsg.Text <> EmptyStr then
  begin
    BlockSendingMessages;

    ChatMsgJSON := CreateMsgJSONObject;

    g_ChatManager.SendMessage(ChatMsgJSON, OnMessageSent, OnMessageFailToSend);
  end;
end;

procedure TChatView.OnMessageSent(ResourceParams: TRequestResourceParam; Val: TJSONValue);
begin
  edtMsg.Text := '';
  EnableSendingMessages;
end;

procedure TChatView.OnMessageFailToSend(const RequestID, ErrMsg: string);
begin
  // TODO: Adicionar log
  ShowMessage(ErrMsg);
  EnableSendingMessages;
end;

procedure TChatView.UpdateChatView;
var
  ChatMsgJSON   : TJSONValue;
  SingleMsgView : TSingleMsgView;
begin
  lytMessagesView.Controls.DeleteRange(0, lytMessagesView.Controls.Count);
  try
    SingleMsgView := TSingleMsgView.Create(lytMessagesView);
    for ChatMsgJSON in g_ChatManager.Messages do
    begin
      SingleMsgView                         := TSingleMsgView.Create(lytMessagesView);
      SingleMsgView.lblSentBy.Text          := ChatMsgJSON.GetValue<String>('SentBy','...');
      SingleMsgView.lblMsg.Text             := ChatMsgJSON.GetValue<String>('Message','...');
      SingleMsgView.lblDateTime.Text        := ChatMsgJSON.GetValue<String>('SentAt','...');
      lytMessagesView.AddObject(SingleMsgView.pnlSingleMsgView);
      // TODO: Adicionar um separador
    end;
  finally
  end;
  lytMessagesView.Height := (g_ChatManager.Messages.Count * SingleMsgView.pnlSingleMsgView.Height);
  lytMessagesView.Width  := frmMainView.Width;

  EnableSendingMessages;
end;

constructor TChatView.Create(AOwner: TComponent);
begin
  inherited;

  BlockSendingMessages;

  if not Assigned(g_ChatManager)
    then g_ChatManager := TChatManager.Create;

  g_ChatManager.AddChatUpdateSubscriber(Self);

  frmMainView.Width := 400;

  lytMessagesView.Parent := vrtscrlbxMessagesView;
end;

destructor TChatView.Destroy;
begin
  if g_ChatManager <> nil
    then g_ChatManager.Free;

  inherited;
end;

end.
