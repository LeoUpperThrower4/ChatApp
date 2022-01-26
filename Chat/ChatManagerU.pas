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
  TChatManager = class
    private
      FFirebaseConfig              : IFirebaseConfiguration;
      FEvent                       : IFirebaseEvent;
      FMessages                    : TJSONArray;
      FRealTimeDB                  : IRealTimeDB;
      FOnUpdateLatestMessages      : TOnRTDBValue;
      FOnMessageSent               : TOnRTDBValue;
      FOnErrorUpdateLatestMessages : TOnRequestError;
      FOnErrorSendMessage          : TOnRequestError;
      FChatUpdateSubscribers       : TInterfaceList;
      procedure OnUpdateLatestMessages     (ResourceParams: TRequestResourceParam; Val: TJSONValue);
      procedure OnUpdateLatestMessagesFail (const RequestID, ErrMsg: string);
      procedure OnMessageSent       (ResourceParams: TRequestResourceParam; Val: TJSONValue);
      procedure OnMessageFailToSend (const RequestID, ErrMsg: string);
    public
      procedure UpdateLatestMessages (OnUpdate: TOnRTDBValue = nil; OnError: TOnRequestError = nil);
      procedure SendMessage          (Msg: TJSONValue; OnSent: TOnRTDBValue = nil; OnFailToSend: TOnRequestError = nil);
      property  Messages: TJSONArray read FMessages;
      procedure OnDBStop(Sender: TObject);
      procedure StartListening;
      procedure OnDBEvent(const Event: string; Params: TRequestResourceParam; JSONObj: TJSONObject);
      procedure OnDBError(const RequestID, ErrMsg: string);
      procedure AddChatUpdateSubscriber(a_Notifiable : IChatUpdateNotifiable);
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
  FMessages              := TJSONArray.Create;
  FRealTimeDB            := TRealTimeDB.CreateByURL(RealtimeDatabaseURL, g_AuthManager.Authenticator);
  FFirebaseConfig        := TFirebaseConfiguration.Create('AIzaSyDUcS4IWiC7PVYH-5LT69gy--NJHmPZXs4', 'chatapp-31972', 'gs://chatapp-31972.appspot.com', 'https://chatapp-31972-default-rtdb.firebaseio.com/');

  StartListening;
end;

procedure TChatManager.StartListening;
begin
  FEvent := FFirebaseConfig.RealTimeDB.ListenForValueEvents(['Global', 'messages'], OnDBEvent, OnDBStop,
    OnDBError, nil);
end;

procedure TChatManager.OnDBEvent(const Event: string;
  Params: TRequestResourceParam; JSONObj: TJSONObject);
var
  JSONValue: TJSONValue;
begin
  if (Event = 'put') then
  begin
    JSONValue := JSONObj.GetValue<TJSONValue>('data');

    if JSONValue.ToString <> c_strNULL then
    begin
      FMessages := JSONValue.Clone as TJSONArray;
      NotifyChatUpdateSubscribers;
    end
    else
      UpdateLatestMessages;
  end;
end;

procedure TChatManager.OnDBStop(Sender: TObject);
begin
//  TODO: Fazer um log ('DB Listener was stopped - restart App');
end;

procedure TChatManager.OnDBError(const RequestID, ErrMsg: string);
begin
//  TODO: Fazer um log (RequestID + ': ' + ErrMsg);
end;

procedure TChatManager.SendMessage(Msg: TJSONValue; OnSent: TOnRTDBValue = nil; OnFailToSend: TOnRequestError = nil);
begin
  FOnMessageSent      := OnSent;
  FOnErrorSendMessage := OnFailToSend;

  (FMessages as TJSONArray).AddElement(Msg);

  FRealTimeDB.Put(['Global', 'messages'], FMessages, OnMessageSent, OnMessageFailToSend);
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
    FMessages.Free;
    FMessages := Val as TJSONArray;
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
    (Subscriber as IChatUpdateNotifiable).UpdateChatView;
  end;
end;

destructor TChatManager.Destroy;
begin
  FEvent.StopListening;

  FMessages.Free;
  FChatUpdateSubscribers.Free;

  inherited;
end;

end.
