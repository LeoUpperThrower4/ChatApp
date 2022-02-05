unit ChatManagerU;

interface

uses
  System.Classes,
  System.Generics.Collections,
  JSON,
  RealtimeDatabaseUtils,
  AuthManagerU,
  FB4D.Interfaces,
  FB4D.Configuration,
  FB4D.RealTimeDB,
  FB4D.RealTimeDB.Listener,
  ChatInterfaces;

type
  TMessageRec =  record
    SentBy : String;
    SentAt : String;
    Msg    : String
  end;

  TChatManager = class
    private
      FFirebaseConfig              : IFirebaseConfiguration;
      FEvent                       : IFirebaseEvent;
      FMessages                    : TList<TMessageRec>;
      FRealTimeDB                  : IRealTimeDB;
      FOnUpdateLatestMessages      : TOnRTDBValue;
      FOnMessageSent               : TOnRTDBValue;
      FOnErrorUpdateLatestMessages : TOnRequestError;
      FOnErrorSendMessage          : TOnRequestError;
      FChatUpdateSubscribers       : TInterfaceList;
      function  GetMsgRecord               (Val : TJSONValue) : TMessageRec;
      procedure OnUpdateLatestMessages     (ResourceParams: TRequestResourceParam; Val: TJSONValue);
      procedure OnUpdateLatestMessagesFail (const RequestID, ErrMsg: string);
      procedure OnMessageSent              (ResourceParams: TRequestResourceParam; Val: TJSONValue);
      procedure OnMessageFailToSend        (const RequestID, ErrMsg: string);
    public
      procedure UpdateLatestMessages (OnUpdate: TOnRTDBValue = nil; OnError: TOnRequestError = nil);
      procedure SendMessage          (Msg: TMessageRec; OnSent: TOnRTDBValue = nil; OnFailToSend: TOnRequestError = nil);
      property  Messages: TList<TMessageRec> read FMessages;
      procedure OnDBStop(Sender: TObject);
      procedure StartListening;
      procedure OnDBEvent(const Event: string; Params: TRequestResourceParam; JSONObj: TJSONObject);
      procedure OnDBError(const RequestID, ErrMsg: string);
      procedure AddChatUpdateSubscriber   (a_Notifiable : IChatUpdateNotifiable);
      procedure NotifyChatUpdateSubscribers;
      constructor Create;
      destructor Destroy; override;
  end;

const
  c_strNULL = 'null';

var
  g_ChatManager: TChatManager;

implementation

{ TChatManager }

constructor TChatManager.Create;
begin
  inherited;

  FChatUpdateSubscribers := TInterfaceList.Create;
  FMessages              := TList<TMessageRec>.Create;
  FRealTimeDB            := TRealTimeDB.CreateByURL(RealtimeDatabaseURL, g_AuthManager.Authenticator);
  FFirebaseConfig        := TFirebaseConfiguration.Create('AIzaSyDUcS4IWiC7PVYH-5LT69gy--NJHmPZXs4', 'chatapp-31972', 'gs://chatapp-31972.appspot.com', 'https://chatapp-31972-default-rtdb.firebaseio.com/');
end;

procedure TChatManager.StartListening;
begin
  FEvent := FFirebaseConfig.RealTimeDB.ListenForValueEvents(['Global', 'messages'], OnDBEvent, OnDBStop,
    OnDBError, nil);
end;

function TChatManager.GetMsgRecord(Val : TJSONValue) : TMessageRec;
begin
  Result.Msg    := Val.GetValue<string>('Message', '');
  Result.SentAt := Val.GetValue<string>('SentAt' , '');
  Result.SentBy := Val.GetValue<string>('SentBy' , '');
end;

procedure TChatManager.OnDBEvent(const Event: string;
  Params: TRequestResourceParam; JSONObj: TJSONObject);
var
  CurrMsg        : TJSONObject;
  Messages       : TJSONArray;
  MsgsEnumerator : TJSONArray.TEnumerator;
  MsgRec         : TMessageRec;
begin
  if (Event = 'put') then
  begin
    Messages := JSONObj.GetValue<TJSONArray>('data');

    if Messages.ToString <> c_strNULL then
    begin
      try
        MsgsEnumerator := Messages.GetEnumerator;
        FMessages.Clear; // Should have an algorithm to enable not rewriting the whole list everytime
        while MsgsEnumerator.MoveNext do
        begin
           FMessages.Add(GetMsgRecord(MsgsEnumerator.Current));
        end;
        NotifyChatUpdateSubscribers;
      finally
        MsgsEnumerator.Free;
      end;
    end
    else
      UpdateLatestMessages;
  end;
end;

procedure TChatManager.OnDBStop(Sender: TObject);
begin
//  TODO: Fazer um log ('DB Listener stopped - restart App');
end;

procedure TChatManager.OnDBError(const RequestID, ErrMsg: string);
begin
//  TODO: Fazer um log (RequestID + ': ' + ErrMsg);
end;

procedure TChatManager.SendMessage(Msg: TMessageRec; OnSent: TOnRTDBValue = nil; OnFailToSend: TOnRequestError = nil);
  function ConvertMessagesToUpload: TJSONArray;
  var
    MsgRec  : TMessageRec;
    MsgPair : TJSONPair;
    MsgObj  : TJSONObject;
  begin
    Result := TJSONArray.Create;

    for MsgRec in FMessages do
    begin
      MsgObj := TJSONObject.Create;

      MsgPair := TJSONPair.Create('Message', MsgRec.Msg);
      MsgObj.AddPair(MsgPair);

      MsgPair := TJSONPair.Create('SentAt', MsgRec.SentAt);
      MsgObj.AddPair(MsgPair);

      MsgPair := TJSONPair.Create('SentBy', MsgRec.SentBy);
      MsgObj.AddPair(MsgPair);

      Result.AddElement(MsgObj);
    end;
  end;
var
  MessagesReadyToUpload : TJSONArray;
begin
  try
    FOnMessageSent      := OnSent;
    FOnErrorSendMessage := OnFailToSend;

    FMessages.Add(Msg);

    MessagesReadyToUpload := ConvertMessagesToUpload;

    // TODO: Logar envio de mensagem
    FRealTimeDB.Put(['Global', 'messages'], MessagesReadyToUpload, OnMessageSent, OnMessageFailToSend);
  finally
    MessagesReadyToUpload.Free;
  end;
end;

procedure TChatManager.OnMessageSent(ResourceParams: TRequestResourceParam;
  Val: TJSONValue);
begin
  if Assigned(FOnMessageSent) then
  begin
    FOnMessageSent(ResourceParams, Val);
  end;
  NotifyChatUpdateSubscribers;
end;

procedure TChatManager.OnMessageFailToSend(const RequestID, ErrMsg: string);
begin
  // TODO: Logar erro
  if Assigned(FOnErrorSendMessage)
    then FOnErrorSendMessage(RequestID, ErrMsg);
end;

procedure TChatManager.UpdateLatestMessages(OnUpdate: TOnRTDBValue = nil; OnError: TOnRequestError = nil);
begin
  FOnUpdateLatestMessages      := OnUpdate;
  FOnErrorUpdateLatestMessages := OnError;

  FRealTimeDB.Get(['Global', 'messages'], OnUpdateLatestMessages, OnUpdateLatestMessagesFail);
end;

procedure TChatManager.OnUpdateLatestMessages(ResourceParams: TRequestResourceParam; Val: TJSONValue);
begin
  if Val.ToString <> c_strNULL then
  begin
//    FMessages := Val as TJSONArray;
  end;

  if Assigned(FOnUpdateLatestMessages)
    then FOnUpdateLatestMessages(ResourceParams, Val);

  NotifyChatUpdateSubscribers;
end;

procedure TChatManager.OnUpdateLatestMessagesFail(const RequestID, ErrMsg: string);
begin
  if Assigned(FOnErrorUpdateLatestMessages)
    then FOnErrorUpdateLatestMessages(RequestID, ErrMsg);

  // TODO: Fazer técnica do modal do Thulio, avisar o que deu errado e só ter o botão de fechar a aplicação
end;

procedure TChatManager.AddChatUpdateSubscriber(a_Notifiable : IChatUpdateNotifiable);
begin
  if (FChatUpdateSubscribers.IndexOf(a_Notifiable) < 0) then
  begin
    FChatUpdateSubscribers.Add(a_Notifiable);
  end;
end;

procedure TChatManager.NotifyChatUpdateSubscribers;
var
  Subscriber: IInterface;
begin
  for Subscriber in FChatUpdateSubscribers do
  begin
    // TODO: Logar que Subbscriber X foi notificado sobre mudança no chat
    (Subscriber as IChatUpdateNotifiable).UpdateChatView;
  end;
end;

destructor TChatManager.Destroy;
begin
  FChatUpdateSubscribers.Clear;
  FChatUpdateSubscribers.Free;

  FMessages.Free;

  // TODO: Logar destroys

  inherited;
end;

end.
