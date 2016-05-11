defmodule WechatMP.ComponentAccessTokenTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import WechatMP.TestHelpers
  import WechatMP.ComponentAccessToken

  setup do
    server = Bypass.open
    client = build_client(site: bypass_server(server), client_id: "clientId")
    {:ok, client: client, server: server}
  end

  test "get_authorizer_info", %{client: client, server: server} do
    authorizer_appid = "auth-appid-123"
    access_token = "component-access-token-1234"
    authorizer_info_url = "/component/api_get_authorizer_info"

    Bypass.expect server, fn conn ->
      assert conn.request_path == authorizer_info_url
      assert conn.method == "POST"

      {:ok, body, conn} = Plug.Conn.read_body(conn)
      body = Poison.decode!(body)
      assert body["component_appid"] == client.client_id
      assert body["authorizer_appid"] == authorizer_appid

      query_params = URI.decode_query(conn.query_string)
      assert query_params["component_access_token"] == access_token

      send_resp(conn, 302, ~s({
        "authorizer_info": {
          "nick_name": "SDK Demo Special",
          "head_img": "http://wx.qlogo.cn/mmopen/GPyw0pGicibl5Eda4GmSSbTguhjg9LZjumHmVjybjiaQXnE9XrXEts6ny9Uv4Fk6hOScWRDibq1fI0WOkSaAjaecNTict3n6EjJaC/0",
          "service_type_info": { "id": 2 },
          "verify_type_info": { "id": 0 },
          "user_name":"gh_eb5e3a772040",
          "business_info": {"open_store": 0, "open_scan": 0, "open_pay": 0, "open_card": 0, "open_shake": 0},
          "alias":"paytest01"
        }
      }))
    end

    params = %{
      authorizer_appid: authorizer_appid,
      component_appid: client.client_id
    }

    assert {:ok, response } =
      build_token([component_access_token: access_token], client)
        |> post(authorizer_info_url <> "?component_access_token=#{access_token}", params)

    info = response.body["authorizer_info"]

    assert info["alias"] == "paytest01"
    assert info["nick_name"] == "SDK Demo Special"
    assert info["user_name"] == "gh_eb5e3a772040"
  end
end
