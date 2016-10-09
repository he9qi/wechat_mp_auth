defmodule WechatMPAuth.AuthorizerAccessTokenTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import WechatMPAuth.TestHelpers
  import WechatMPAuth.AuthorizerAccessToken

  setup do
    server = Bypass.open
    client = build_client(site: bypass_server(server))
    {:ok, client: client, server: server}
  end

  test "new authorizer_access_token from string", %{client: client} do
    access_token = "authorizer-access-token-1234"

    authorizer_access_token = new(access_token, client)

    assert authorizer_access_token.access_token == access_token
    assert authorizer_access_token.client
  end

  test "new authorizer_access_token from map", %{client: client} do
    access_token = "authorizer-access-token-1234"
    refresh_token = "authorizer-refresh-token-1234"
    authorizer_appid = "authorizer-appid"
    expires_in = 600

    params = %{
      "authorization_info" => %{
        "authorizer_access_token" => access_token,
        "authorizer_refresh_token" => refresh_token,
        "authorizer_appid" => authorizer_appid,
        "expires_in" => expires_in
      }
    }

    authorizer_access_token = new(params, client)

    assert authorizer_access_token.access_token == access_token
    assert authorizer_access_token.refresh_token == refresh_token
    assert authorizer_access_token.appid == authorizer_appid
    assert authorizer_access_token.expires_at
    assert authorizer_access_token.client
  end

  test "wechat api success", %{client: client, server: server} do
    access_token = "authorizer-access-token-1234"
    request_path = "/message/custom/send"

    Bypass.expect server, fn conn ->
      assert conn.request_path == request_path
      assert conn.method == "POST"

      {:ok, body, conn} = Plug.Conn.read_body(conn)
      body = Poison.decode!(body)
      assert body["touser"] == "of--is4KCF75h_k_DPZSoWhtES6M"
      assert body["msgtype"] == "text"
      assert body["text"]["content"] == "Hello World"

      query_params = URI.decode_query(conn.query_string)
      assert query_params["access_token"] == access_token

      send_resp(conn, 200, ~s({
        "errcode": 0,
        "errmsg": "ok"
      }))
    end

    params = %{
      touser: "of--is4KCF75h_k_DPZSoWhtES6M",
      msgtype: "text",
      text: %{
        content: "Hello World"
      }
    }

    assert {:ok, response } =
      new(access_token, client)
        |> post(request_path, params)

    info = response.body

    assert info["errcode"] == 0
    assert info["errmsg"] == "ok"
  end

  test "wechat api fails with 200", %{client: client, server: server} do
    access_token = "authorizer-access-token-1234"
    request_path = "/message/custom/send"

    Bypass.expect server, fn conn ->
      assert conn.request_path == request_path
      assert conn.method == "POST"

      {:ok, _, conn} = Plug.Conn.read_body(conn)

      send_resp(conn, 200, ~s({
        "errcode": 61004,
        "errmsg": "access clientip is not registered requestIP: 101.226.103.59 hint: [0AOzcA0341vr32!]"
      }))
    end

    params = %{
      touser: "of--is4KCF75h_k_DPZSoWhtES6M",
      msgtype: "text",
      text: %{
        content: "Hello World"
      }
    }

    assert {:error, _ } =
      new(access_token, client)
        |> post(request_path, params)
  end
end
