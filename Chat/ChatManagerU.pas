unit ChatManagerU;

interface

uses
  JSON,
  System.Generics.Collections,
  RealtimeDatabaseUtils,
  AuthManagerU,
  FB4D.Interfaces,
  FB4D.RealTimeDB;

type
  TChatManager = class
    private
      FMessages               : TJSONArray;
      FRealTimeDB             : IRealTimeDB;
      FOnUpdateLatestMessages : TOnRTDBValue;
      procedure OnUpdateLatestMessages     (ResourceParams: TRequestResourceParam; Val: TJSONValue);
      procedure OnUpdateLatestMessagesFail (const RequestID, ErrMsg: string);
    public
      procedure UpdateLatestMessages       (OnUpdate: TOnRTDBValue = nil; OnError: TOnRequestError = nil);
      procedure SendMessage                (Msg: TJSONObject; OnMessageSent: TOnRTDBValue; OnMessageFailToSend: TOnRequestError);
      constructor Create;
  end;

var
  g_ChatManager: TChatManager;

implementation

{ TChatManager }

//******************************************************************************
//
// Responsável por pegar, no banco de dados, os dados mais recentes e atualizar
// a lista completa de mensagens da classe ChatManagerU. Retorna True caso concluído
// com sucesso e False caso contrário
//
//******************************************************************************
constructor TChatManager.Create;
begin
  inherited;

  FRealTimeDB := TRealTimeDB.CreateByURL(RealtimeDatabaseURL, g_AuthManager.Authenticator);
  FMessages   := TJSONArray.Create;
end;

procedure TChatManager.OnUpdateLatestMessages(ResourceParams: TRequestResourceParam; Val: TJSONValue);
begin
  if Val.ToString <> 'null' then
    FMessages := Val.Clone as TJSONArray;

  if Assigned(FOnUpdateLatestMessages)
    then FOnUpdateLatestMessages(ResourceParams, Val);
end;

procedure TChatManager.OnUpdateLatestMessagesFail(const RequestID, ErrMsg: string);
begin
  // O que fazer? Como avisar? Eviar como mensagem de API do Windows?
end;

procedure TChatManager.SendMessage(Msg: TJSONObject; OnMessageSent: TOnRTDBValue; OnMessageFailToSend: TOnRequestError);
begin
  if FMessages <> nil then
  begin
    FMessages.Add(Msg);
    FRealTimeDB.Put(['Global', 'messages'], FMessages, OnMessageSent, OnMessageFailToSend);
  end;
end;

procedure TChatManager.UpdateLatestMessages(OnUpdate: TOnRTDBValue = nil; OnError: TOnRequestError = nil);
begin
  FOnUpdateLatestMessages := OnUpdate;

  FRealTimeDB.Get(['Global', 'messages'], OnUpdateLatestMessages, OnError);
end;

end.
