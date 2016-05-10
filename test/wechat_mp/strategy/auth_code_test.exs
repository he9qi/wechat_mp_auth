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

  test "get_token", %{client: client, server: server} do
    verify_ticket = "ticket@@abc-123"
    access_token  = "component-access-token-1234"

    Bypass.expect server, fn conn ->
      assert conn.request_path == "/component/api_component_token"
      assert conn.method == "POST"

      {:ok, body, conn} = Plug.Conn.read_body(conn)
      body = Poison.decode!(body)# URI.decode_query(body)

      assert body["component_appid"] == client.client_id
      assert body["component_appsecret"] == client.client_secret
      assert body["component_verify_ticket"] == verify_ticket

      send_resp(conn, 302, ~s({"component_access_token":"#{access_token}","expires_in":7200}))
    end

    assert {:ok, %ComponentAccessToken{} = token} = Client.get_component_access_token(client, [verify_ticket: verify_ticket])
    assert token.access_token == access_token
  end

end
