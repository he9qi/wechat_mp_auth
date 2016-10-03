defmodule WechatMPAuth.ComponentAccessTokenTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import WechatMPAuth.TestHelpers
  import WechatMPAuth.ComponentAccessToken

  setup do
    server = Bypass.open
    client = build_client(site: bypass_server(server))
    access_token = new("access-token-1234", client)
    {:ok, client: client, server: server, access_token: access_token}
  end

  test "new component_access_token from string", %{client: client} do
    access_token = "component-access-token-1234"

    component_access_token = new(access_token, client)

    assert component_access_token.access_token == access_token
    assert component_access_token.client
  end

  test "new component_access_token from map", %{client: client} do
    access_token = "component-access-token-1234"
    expires_in = 600

    params = %{
      "component_access_token" => access_token,
      "expires_in" => expires_in
    }

    component_access_token = new(params, client)

    assert component_access_token.access_token == access_token
    assert component_access_token.expires_at
    assert component_access_token.client
  end

  test "GET", %{server: server, access_token: access_token} do
    bypass server, "GET", "/", fn conn ->
      assert conn.query_params == %{"component_access_token" => "access-token-1234"}
      send_resp(conn, 200, ~s({"success":true}))
    end
    assert {:ok, resp} = get(access_token, "/")
    assert resp.body == %{"success" => true}
  end

  test "GET!", %{server: server, access_token: access_token} do
    bypass server, "GET", "/", fn conn ->
      send_resp(conn, 200, ~s({"success":true}))
    end
    resp = get!(access_token, "/")
    assert resp.body == %{"success" => true}
  end

  test "POST", %{server: server, access_token: access_token} do
    bypass server, "POST", "/", fn conn ->
      assert conn.method == "POST"

      {:ok, body, _} = Plug.Conn.read_body(conn)
      assert Poison.decode!(body) == %{"token" => 123}

      send_resp(conn, 200, ~s({"success":true}))
    end

    assert {:ok, resp} = post(access_token, "/", %{"token" => 123})
    assert resp.body == %{"success" => true}
  end

  test "POST!", %{server: server, access_token: access_token} do
    bypass server, "POST", "/", fn conn ->
      assert conn.method == "POST"

      {:ok, body, _} = Plug.Conn.read_body(conn)
      assert Poison.decode!(body) == %{"token" => 123}

      send_resp(conn, 200, ~s({"success":true}))
    end

    resp = post!(access_token, "/", %{"token" => 123})
    assert resp.body == %{"success" => true}
  end

  test "POST with empty body", %{server: server, access_token: access_token} do
    bypass server, "POST", "/", fn conn ->
      send_resp(conn, 200, ~s({"success":true}))
    end

    assert {:ok, resp} = post(access_token, "/")
    assert resp.body == %{"success" => true}

    resp = post!(access_token, "/")
    assert resp.body == %{"success" => true}
  end

  test "Request GET", %{server: server, access_token: access_token} do
    bypass server, "GET", "/", fn conn ->
      assert conn.host == "localhost"
      assert conn.port == server.port
      send_resp(conn, 200, ~s({"success":true}))
    end

    assert {:ok, resp} = request(:get, access_token, "/", "")
    assert resp.body == %{"success" => true}
  end

  test "Request GET!", %{server: server, access_token: access_token} do
    bypass server, "GET", "/", fn conn ->
      send_resp(conn, 200, ~s({"success":true}))
    end

    resp = request!(:get, access_token, "/", "")
    assert resp.body == %{"success" => true}
  end

  test "Request GET absolute URL", %{server: server, access_token: access_token} do
    bypass server, "GET", "/", fn conn ->
      assert conn.host == "localhost"
      assert conn.port == server.port
      send_resp(conn, 200, ~s({"success":true}))
    end

    assert {:ok, resp} = request(:get, access_token, "http://localhost:#{server.port}/", "")
    assert resp.body == %{"success" => true}
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
        |> post(authorizer_info_url, params)

    info = response.body["authorizer_info"]

    assert info["alias"] == "paytest01"
    assert info["nick_name"] == "SDK Demo Special"
    assert info["user_name"] == "gh_eb5e3a772040"
  end
end
