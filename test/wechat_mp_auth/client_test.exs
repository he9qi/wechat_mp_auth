defmodule WechatMPAuth.ClientTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import WechatMPAuth.Client
  import WechatMPAuth.TestHelpers

  setup do
    server = Bypass.open
    client = build_client(site: bypass_server(server))
    {:ok, client: client, server: server}
  end

  test "get_authorizer_access_token", %{client: client, server: server} do
    access_token = "authorizer-access-token-1234"
    refresh_token = "authorizer-refresh-token-1234"
    authorizer_appid = "authorizer-appid"
    authorization_code = "auth-code"
    expires_in = 600

    Bypass.expect server, fn conn ->
      case conn.request_path do
        "/component/api_query_auth" ->
          query_params = URI.decode_query(conn.query_string)
          assert query_params["component_access_token"] == "c-token"

          {:ok, body, conn} = Plug.Conn.read_body(conn)
          body = Poison.decode!(body)
          assert body["component_appid"] == client.client_id
          assert body["authorization_code"] == authorization_code

          send_resp(conn, 200, ~s({
            "authorization_info": {
                "authorizer_access_token": "#{access_token}",
                "authorizer_refresh_token": "#{refresh_token}",
                "authorizer_appid": "#{authorizer_appid}",
                "expires_in": #{expires_in}
              }
          }))
      end
    end

    {:ok, authorizer_access_token} = client
      |> get_authorizer_access_token([authorization_code: authorization_code, component_access_token: "c-token"])

    assert authorizer_access_token.access_token == access_token
    assert authorizer_access_token.refresh_token == refresh_token
    assert authorizer_access_token.appid == authorizer_appid
    assert authorizer_access_token.expires_at
    assert authorizer_access_token.client
  end

  test "authorize_url", %{server: server} do
    verify_ticket = "ticket@@abc-123"
    pre_auth_code = "pre-auth-code-1234"
    access_token = "component-access-token-1234"
    client_id = "clientId"
    redirect_uri = "https://localhost:4200/weixin_callback"

    client = build_client(site: bypass_server(server), client_id: client_id, redirect_uri: redirect_uri)

    Bypass.expect server, fn conn ->
      case conn.request_path do
        "/component/api_create_preauthcode" ->
          send_resp(conn, 302, ~s({"pre_auth_code":"#{pre_auth_code}","expires_in":600}))
        "/component/api_component_token" ->
          send_resp(conn, 302, ~s({"component_access_token":"#{access_token}","expires_in":7200}))
      end
    end

    {client, url} = get_authorize_url(client, [verify_ticket: verify_ticket])

    query_params = %{
      component_appid: client_id,
      pre_auth_code: pre_auth_code,
      redirect_uri: redirect_uri
    }
    assert url == client.authorize_url <> "?" <> URI.encode_query(query_params)
    assert client.params["component_access_token"] == access_token
  end

end
