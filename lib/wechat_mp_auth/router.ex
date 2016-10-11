defmodule WechatMPAuth.Router do
  require Logger
  use Plug.Router

  alias WechatMPAuth.ClientFactory
  alias WechatMPAuth.ComponentVerifyTicket, as: CVT
  alias WechatMPAuth.RedisStore
  alias WechatMPAuth.Repo
  alias WechatMPAuth.Client
  alias WechatMPAuth.AuthorizerAccessToken, as: AAT
  alias WechatMPAuth.ComponentAccessToken, as: CAT

  @authorizer Application.get_env(:wechat_mp_auth, :authorizer)
  @client_id  Application.get_env(:wechat_mp_auth, :client_id)
  @db_prefix  Application.get_env(:wechat_mp_auth, :db_prefix)
  @c_a_token  Application.get_env(:wechat_mp_auth, :c_a_token)

  plug :match
  plug :dispatch

  get "/auth/wx/:source" do
    result =
      with   client <- ClientFactory.create_client(source),
               repo <- %Repo{store: RedisStore, db_name: @db_prefix},
      {:ok, %CVT{ComponentVerifyTicket: ticket}} <- CVT.load(@client_id, repo),
      {client, url} <- @authorizer.get_authorize_url(client, verify_ticket: ticket),
      %Client{params: %{"component_access_token" => token}} <- client,
          comp_repo <- %{repo | prefix_key: "authorizer:#{source}"},
           {:ok, _} <- Repo.insert(comp_repo, "component_access_token", token),
           do: {:ok, url}
    case result do
      {:ok, url} ->
        conn
        |> put_resp_header("location", url)
        |> resp(302, "You are being redirected.")
        |> halt
      {:error, _reason} ->
        send_resp(conn, 422, "failed to obtain authorize url")
    end
  end

  post "auth/wx/:source/callback" do
    result =
      with  client <- ClientFactory.create_client(source),
  {:ok, auth_code} <- conn.params |> Dict.fetch("auth_code"),
              repo <- %Repo{store: RedisStore, db_name: @db_prefix, prefix_key: "authorizer:#{source}"},
   {:ok, ca_token} <- Repo.get(repo, "component_access_token"),
               cat <- CAT.new(ca_token, client),
      {:ok, %AAT{access_token: access_token, refresh_token: refresh_token, appid: app_id} = aat} <- @authorizer.get_authorizer_access_token(client, [authorization_code: auth_code, component_access_token: ca_token]),
%{ "authorizer_info" => %{ "nick_name" => name }} <- @c_a_token.post!(cat, "/component/api_get_authorizer_info", %{component_appid: @client_id, authorizer_appid: app_id}).body,
      {:ok, _} <- Repo.insert(repo, "authorizer_access_token", access_token),
      {:ok, _} <- Repo.insert(repo, "authorizer_refresh_token", refresh_token),
      {:ok, _} <- Repo.insert(repo, "authorizer_app_id", app_id),
      {:ok, _} <- Repo.insert(repo, "authorizer_name", name),
      do: {:ok, aat}

    case result do
      {:ok, _} ->
        send_resp(conn, 200, "success")
      {:error, reason} ->
        Logger.error(inspect reason)
        send_resp(conn, 422, "failed to obtain authorize token")
    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
