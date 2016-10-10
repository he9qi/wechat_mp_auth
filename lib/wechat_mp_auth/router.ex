defmodule WechatMPAuth.Router do
  use Plug.Router

  alias WechatMPAuth.AuthorizeUrl
  alias WechatMPAuth.ComponentVerifyTicket

  @authorizer Application.get_env(:wechat_mp_auth, :authorizer)
  @client_id  Application.get_env(:wechat_mp_auth, :client_id)
  @store      WechatMPAuth.RedisStore

  plug :match
  plug :dispatch

  get "/auth/wx/:source" do
    result =
      with {:ok, ticket}  <- ComponentVerifyTicket.load(@client_id, @store),
           {_client, url} <- AuthorizeUrl.get(source, ticket, @authorizer),
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

  match _ do
    send_resp(conn, 404, "oops")
  end
end
