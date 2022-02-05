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
  FB4D.RealTimeDB,
  FB4D.Interfaces,
  FB4D.Configuration;
type
  TChatView = class(TFrame, IChatUpdateNotifiable)
    lytWriteMsg            : TLayout;
    rectWriteMsgBg         : TRectangle;
    edtMsg                 : TEdit;
    btnSend                : TSpeedButton;
    rectBtnSendWrapper     : TRectangle;
    vrtscrlbxMessagesView  : TVertScrollBox;
    lytMessagesView        : TFlowLayout;
    function  CreateMsgRec : TMessageRec;
    procedure OnMessageSent       (ResourceParams: TRequestResourceParam; Val: TJSONValue);
    procedure OnMessageFailToSend (const RequestID, ErrMsg: string);
    procedure btnSendClick        (Sender: TObject);
    procedure edtMsgKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure BlockSendingMessages;
    procedure EnableSendingMessages;
  public
    { Public declarations }
    procedure UpdateChatView;
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  frmMainViewU;

{$R *.fmx}

{ TChatView }

function TChatView.CreateMsgRec: TMessageRec;
begin
  Result.Msg := edtMsg.Text.Trim;
  Result.SentAt := DateToStr(now);
  Result.SentBy := g_AuthManager.CurrentUser.EMail;
end;

procedure TChatView.edtMsgKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = 13
    then btnSendClick(Self);
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
  ChatMsgRec : TMessageRec;
begin
  if edtMsg.Text <> EmptyStr then
  begin
    BlockSendingMessages;

    ChatMsgRec := CreateMsgRec;

    g_ChatManager.SendMessage(ChatMsgRec, OnMessageSent, OnMessageFailToSend);
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
  MessageRec   : TMessageRec;
  SingleMsgView : TSingleMsgView;
begin
  lytMessagesView.Controls.DeleteRange(0, lytMessagesView.Controls.Count);
  try
    SingleMsgView := TSingleMsgView.Create(Self);
    for MessageRec in g_ChatManager.Messages do
    begin
      SingleMsgView                         := TSingleMsgView.Create(lytMessagesView);
      SingleMsgView.lblSentBy.Text          := MessageRec.SentBy;
      SingleMsgView.lblMsg.Text             := MessageRec.Msg;
      SingleMsgView.lblDateTime.Text        := MessageRec.SentAt;
      lytMessagesView.AddObject(SingleMsgView.pnlSingleMsgView);
//       TODO: Adicionar um separador
    end;
  finally
  end;
  lytMessagesView.Height := (g_ChatManager.Messages.Count * SingleMsgView.pnlSingleMsgView.Height);
  lytMessagesView.Width  := frmMainView.Width;

  EnableSendingMessages;
end;

constructor TChatView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  BlockSendingMessages;

  g_ChatManager.AddChatUpdateSubscriber(Self);

  frmMainView.Width := 400;

  lytMessagesView.Parent := vrtscrlbxMessagesView;

  g_ChatManager.StartListening;
end;

end.
