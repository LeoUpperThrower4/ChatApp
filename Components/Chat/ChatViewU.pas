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
    edtMsg                 : TEdit;
    vrtscrlbxMessagesView  : TVertScrollBox;
    lytMessagesView        : TFlowLayout;
    rectWriteMsgBg: TRectangle;
    edtSeparator: TLine;
    function  CreateMsgRec : TMessageRec;
    procedure HandleEnterClick;
    procedure OnMessageSent       (ResourceParams: TRequestResourceParam; Val: TJSONValue);
    procedure OnMessageFailToSend (const RequestID, ErrMsg: string);
    procedure edtMsgKeyDown       (Sender: TObject; var Key: Word; var KeyChar: Char;
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

/// <summary>
///   Create a TMessageRec message record based on whats on the edit text, on the
///   current user and on the current date
/// </summary>
function TChatView.CreateMsgRec: TMessageRec;
begin
  Result.Msg := edtMsg.Text.Trim;
  Result.SentAt := DateToStr(now);
  Result.SentBy := g_AuthManager.CurrentUser.EMail;
end;

/// <summary>
///   Callback that is called when the message edit is pressed. When enter is
///   pressed, message is sent
/// </summary>
procedure TChatView.edtMsgKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = 13
    then HandleEnterClick;
end;

/// <summary>
///   Do visual edits to block sending messages
/// </summary>
procedure TChatView.BlockSendingMessages;
begin
  edtMsg.Enabled  := False;
end;

/// <summary>
///   Do visual edits to enable sending messages
/// </summary>
procedure TChatView.EnableSendingMessages;
begin
  edtMsg.Enabled  := True;
end;

/// <summary>
///   Handles enter button clicked. Blocks sending messages and then send it
/// </summary>
procedure TChatView.HandleEnterClick;
var
  ChatMsgRec : TMessageRec;
begin
  if (edtMsg.Text <> EmptyStr) and (edtMsg.Enabled) then
  begin
    BlockSendingMessages;

    ChatMsgRec := CreateMsgRec;

    g_ChatManager.SendMessage(ChatMsgRec, OnMessageSent, OnMessageFailToSend);
  end;
end;

/// <summary>
///   Callback that is called when message is successfully sent
/// </summary>
procedure TChatView.OnMessageSent(ResourceParams: TRequestResourceParam; Val: TJSONValue);
begin
  edtMsg.Text := '';
  EnableSendingMessages;
  edtMsg.SetFocus;
end;

/// <summary>
///   Callback that is called when message failed to send
/// </summary>
procedure TChatView.OnMessageFailToSend(const RequestID, ErrMsg: string);
begin
  // TODO: Adicionar log
  ShowMessage(ErrMsg);
  EnableSendingMessages;
end;

/// <summary>
///   Updates the chat grid with the new information. Inherited from
///   IChatUpdateNotifiable. Receives notification for chat changes
/// </summary>
procedure TChatView.UpdateChatView;
var
  MessageRec    : TMessageRec;
  SingleMsgView : TSingleMsgView;
begin
  lytMessagesView.Controls.DeleteRange(0, lytMessagesView.Controls.Count);
  try
    SingleMsgView := TSingleMsgView.Create(Self);
    for MessageRec in g_ChatManager.Messages do
    begin
      SingleMsgView                  := TSingleMsgView.Create(lytMessagesView);
      SingleMsgView.lblSentBy.Text   := MessageRec.SentBy;
      SingleMsgView.lblMsg.Text      := MessageRec.Msg;
      SingleMsgView.lblDateTime.Text := MessageRec.SentAt;

      if MessageRec.SentBy = g_AuthManager.CurrentUser.EMail then
      begin
        SingleMsgView.crSingleMessageView.CalloutPosition := TCalloutPosition.Right;
        SingleMsgView.crSingleMessageView.Margins.Left := 15;
        SingleMsgView.crSingleMessageView.Fill.Color := $FF09A770;

        SingleMsgView.rectLeft.Margins.Left := 1;
        SingleMsgView.rectLeft.Align := TAlignLayout.MostLeft;
        SingleMsgView.rectDate.Align := TAlignLayout.Left;
      end;

      lytMessagesView.AddObject(SingleMsgView.crSingleMessageView);
    end;
  finally
  end;
  lytMessagesView.Height := (g_ChatManager.Messages.Count * 130 + 10);
  lytMessagesView.Width  := frmMainView.Width;

  EnableSendingMessages;
end;

/// <summary>
///   Create the chat form. Blocks sending messages and starts listening for chat
///   updates
/// </summary>
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
