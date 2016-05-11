defmodule WechatMP.Strategy.AuthCodeTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import WechatMP.TestHelpers

  alias WechatMP.Client
  alias WechatMP.ComponentAccessToken
  alias WechatMP.Strategy.AuthCode

  setup do
    server = Bypass.open
    client = build_client(strategy: AuthCode, site: bypass_server(server))
    {:ok, client: client, server: server}
  end

  test "get_component_access_token", %{client: client, server: server} do
    verify_ticket = "ticket@@abc-123"
    access_token  = "component-access-token-1234"

    Bypass.expect server, fn conn ->
      assert conn.request_path == "/component/api_component_token"
      assert conn.method == "POST"

      # Note: wechat doesn't care what content-type request has
      # assert get_req_header(conn, "content-type") == ["application/json"]

      {:ok, body, conn} = Plug.Conn.read_body(conn)
      body = Poison.decode!(body)# URI.decode_query(body)

      assert body["component_appid"] == client.client_id
      assert body["component_appsecret"] == client.client_secret
      assert body["component_verify_ticket"] == verify_ticket

      send_resp(conn, 302, ~s({"component_access_token":"#{access_token}","expires_in":7200}))
    end

    assert {:ok, %ComponentAccessToken{} = token} = Client.get_component_access_token(client, [verify_ticket: verify_ticket])
    assert token.access_token == access_token
    assert token.client != nil
  end

  test "pre_auth_code_url", %{client: client} do
    {client, url} = AuthCode.pre_auth_code_url(client, %{component_access_token: "token-1234"})
    assert url == "#{client.site}/component/api_create_preauthcode?component_access_token=token-1234"
  end

  test "get_pre_auth_code", %{client: client, server: server} do
    pre_auth_code = "pre-auth-code-1234"
    access_token = "component-access-token-1234"

    Bypass.expect server, fn conn ->
      assert conn.request_path == "/component/api_create_preauthcode"
      assert conn.method == "POST"

      {_ok, body, conn} = Plug.Conn.read_body(conn)
      body = Poison.decode!(body)# URI.decode_query(body)

      assert body["component_appid"] == client.client_id

      send_resp(conn, 302, ~s({"pre_auth_code":"#{pre_auth_code}","expires_in":600}))
    end

    assert {:ok, %{"expires_in" => expires_in, "pre_auth_code" => pre_auth_code}} =
      AuthCode.get_pre_auth_code(client, %ComponentAccessToken{access_token: access_token})
    assert pre_auth_code == "pre-auth-code-1234"
    assert expires_in == 600
  end
end
