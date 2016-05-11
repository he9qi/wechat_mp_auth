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

    {:ok, req} = Request.request(:get, "http://localhost:#{server.port}/")

    assert req.body == %{"success" => true}
  end

end
