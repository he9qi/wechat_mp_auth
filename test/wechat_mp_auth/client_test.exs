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
