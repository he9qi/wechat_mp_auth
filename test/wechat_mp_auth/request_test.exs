defmodule WechatMPAuth.RequestTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import WechatMPAuth.TestHelpers
  alias WechatMPAuth.Request

  setup_all do
    server = Bypass.open
    {:ok, server: server}
  end

  test "Request GET", %{server: server} do
    bypass server, "GET", "/", fn conn ->
      send_resp(conn, 200, ~s({"success":true}))
    end

    assert {:ok, resp} = Request.request(:get, "http://localhost:#{server.port}/")

    assert resp.body == %{"success" => true}
  end

  test "Request GET!", %{server: server} do
    bypass server, "GET", "/", fn conn ->
      send_resp(conn, 200, ~s({"success":true}))
    end

    resp = Request.request!(:get, "http://localhost:#{server.port}/")

    assert resp.body == %{"success" => true}
  end

  test "Request POST with application/json", %{server: server} do
    bypass server, "POST", "/", fn conn ->
      assert conn.method == "POST"
      assert conn.body_params == %{"token" => 123}

      send_resp(conn, 200, ~s({"success":true}))
    end

    assert {:ok, resp} = Request.request(:post,
      "http://localhost:#{server.port}/",
      %{"token": 123},
      [{"content-type", "application/json"}])

    assert resp.body == %{"success" => true}
  end

end
