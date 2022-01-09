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
      procedure OnUpdateLatestMessages    (ResourceParams: TRequestResourceParam; Val: TJSONValue);
      procedure OnUpdateLatestMessagesFail(const RequestID, ErrMsg: string);
    public
      procedure UpdateLatestMessages;
      constructor Create;
  end;

var
  g_ChatManager: TChatManager;

implementation

{ TChatManager }

//******************************************************************************
//
// Respons�vel por pegar, no banco de dados, os dados mais recentes e atualizar
// a lista completa de mensagens da classe ChatManagerU. Retorna True caso conclu�do
// com sucesso e False caso contr�rio
//
//******************************************************************************
constructor TChatManager.Create;
begin
  inherited;

  // Cria inst�ncia para o RealtimeDB
  FRealTimeDB := TRealTimeDB.CreateByURL(RealtimeDatabaseURL, g_AuthManager.Authenticator);

  // Atualiza a lista de mensagens
  UpdateLatestMessages;
end;

procedure TChatManager.OnUpdateLatestMessages(ResourceParams: TRequestResourceParam; Val: TJSONValue);
begin
  FMessages := Val as TJSONArray;
end;

procedure TChatManager.OnUpdateLatestMessagesFail(const RequestID, ErrMsg: string);
begin
  // O que fazer? Como avisar? Eviar como mensagem de api do Windows?
end;

procedure TChatManager.UpdateLatestMessages;
begin
  FRealTimeDB.Get(['Global', 'messages'], OnUpdateLatestMessages, OnUpdateLatestMessagesFail);
end;

end.