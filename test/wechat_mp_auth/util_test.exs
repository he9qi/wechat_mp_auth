defmodule WechatMPAuth.UtilTest do
  use ExUnit.Case, async: true

  alias WechatMPAuth.Util

  test "expires at is nil" do
    assert nil == Util.expires_at(nil)
  end

  test "expires at is string" do
    assert 1463017450 == Util.expires_at("1463017450")
  end

  test "expires at is not string" do
    assert Util.unix_now + 100 == Util.expires_at(100)
  end

  test "parses correct mime types" do
    assert "application/x-www-form-urlencoded" == Util.content_type([
      {"content-type", "application/x-www-form-urlencoded"}
    ])
  end

  test "defaults to application/json mime type when parsing" do
    assert "application/json" == Util.content_type([])
  end

  test "raises error when content type is not correct" do
    assert_raise WechatMPAuth.Error, fn ->
      Util.content_type([{"content-type", "trash; trash"}])
    end
  end

end
