defmodule WechatMP.ResponseTest do
  use ExUnit.Case, async: true

  alias WechatMP.Response

  test "Constructs response" do
    headers = [{"content-type", "application/json"}]
    resp    = Response.new(200, headers, "hello" |> Poison.encode!)

    assert resp.status_code == 200
    assert resp.headers == headers
    assert resp.body == "hello"
  end
end
