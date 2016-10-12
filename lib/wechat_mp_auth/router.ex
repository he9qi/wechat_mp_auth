defmodule WechatMPAuth.Router do
  require Logger
  use Plug.Router

  alias WechatMPAuth.ClientFactory
  alias WechatMPAuth.ComponentVerifyTicket, as: CVT
  alias WechatMPAuth.RedisStore
  alias WechatMPAuth.Repo

  import WechatMPAuth.AuthorizerInfo, only: [get_authorizer_info: 6, get_url: 4]

  @authorizer Application.get_env(:wechat_mp_auth, :authorizer)
  @client_id  Application.get_env(:wechat_mp_auth, :client_id)
  @db_prefix  Application.get_env(:wechat_mp_auth, :db_prefix)
  @c_a_token  Application.get_env(:wechat_mp_auth, :c_a_token)

  plug :match
  plug :dispatch

  get "/auth/wx/:source" do
    result =
                    with client <- ClientFactory.create_client(source),
                           repo <- %Repo{name: @db_prefix, store: RedisStore},
                         ticket <- Repo.get(repo, %CVT{app_id: @client_id}),
    {:ok, url, authorizer_info} <- get_url(client, ticket, source, @authorizer),
                       {:ok, _} <- Repo.insert(repo, authorizer_info),
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
              repo <- %Repo{name: @db_prefix, store: RedisStore},
   authorizer_info <- get_authorizer_info(client, auth_code, source, repo, @authorizer, @c_a_token),
          {:ok, _} <- Repo.insert(repo, authorizer_info),
      do: {:ok, authorizer_info}

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
