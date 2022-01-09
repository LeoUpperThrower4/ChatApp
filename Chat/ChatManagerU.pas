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
      FMessages   : TJSONArray;
      FRealTimeDB : IRealTimeDB;
      FOnUpdateLatestMessages : TOnRTDBValue;
      procedure OnUpdateLatestMessages    (ResourceParams: TRequestResourceParam; Val: TJSONValue);
      procedure OnUpdateLatestMessagesFail(const RequestID, ErrMsg: string);
    public
      procedure UpdateLatestMessages(OnUpdate: TOnRTDBValue = nil; OnError: TOnRequestError = nil);
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

  // Cria instância para o RealtimeDB
  FRealTimeDB := TRealTimeDB.CreateByURL(RealtimeDatabaseURL, g_AuthManager.Authenticator);

  // Atualiza a lista de mensagens
  UpdateLatestMessages(nil, OnUpdateLatestMessagesFail);
end;

procedure TChatManager.OnUpdateLatestMessages(ResourceParams: TRequestResourceParam; Val: TJSONValue);
begin
  FMessages := Val as TJSONArray;
  if Assigned(FOnUpdateLatestMessages)
    then FOnUpdateLatestMessages(ResourceParams, Val);
end;

procedure TChatManager.OnUpdateLatestMessagesFail(const RequestID, ErrMsg: string);
begin
  // O que fazer? Como avisar? Eviar como mensagem de api do Windows?
end;

procedure TChatManager.UpdateLatestMessages(OnUpdate: TOnRTDBValue = nil; OnError: TOnRequestError = nil);
begin
  FOnUpdateLatestMessages := OnUpdate;

  FRealTimeDB.Get(['Global', 'messages'], OnUpdateLatestMessages, OnError);
end;

end.
