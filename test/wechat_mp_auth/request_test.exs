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

  test "Request GET Connection Failure", %{server: server} do
    Bypass.down(server)

    assert {:error, error} = Request.request(:get, "http://localhost:#{server.port}/")
    assert error.reason == :econnrefused

    Bypass.up(server)
  end

  test "Request GET Error Response", %{server: server} do
    bypass server, "GET", "/", fn conn ->
      send_resp(conn, 200, ~s<{
        "errcode": 42001,
        "errmsg": "access_token expired hint: [utxVxa0955vr19]"
      }>)
    end

    assert {:ok, resp} = Request.request(:get, "http://localhost:#{server.port}/")
    assert resp.body == %{"errcode" => 42001, "errmsg" => "access_token expired hint: [utxVxa0955vr19]"}
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

      json(conn, 200, ~s({"success":true}))
    end

    assert {:ok, resp} = Request.request(:post,
      "http://localhost:#{server.port}/",
      %{"token": 123},
      [{"content-type", "application/json"}])

    assert resp.body == "{\"success\":true}"
  end

  test "Request POST with application/x-www-form-urlencoded", %{server: server} do
    bypass server, "POST", "/", [accept: "application/x-www-form-urlencoded"], fn conn ->
      assert conn.method == "POST"
      assert conn.body_params == %{"token" => "123"}

      json(conn, 200, ~s({"success":true}))
    end

    assert {:ok, resp} = Request.request(:post,
      "http://localhost:#{server.port}/",
      %{"token": 123},
      [{"content-type", "application/x-www-form-urlencoded"}, {"accept", "application/x-www-form-urlencoded"}])

    assert resp.body == "{\"success\":true}"
  end

end
