defmodule WechatMP.UtilTest do
  use ExUnit.Case, async: true

  alias WechatMP.Util

  test "parses correct mime types" do
    assert "application/x-www-form-urlencoded" == Util.content_type([
      {"content-type", "application/x-www-form-urlencoded"}
    ])
  end

  test "defaults to application/json mime type when parsing" do
    assert "application/json" == Util.content_type([])
  end

  test "raises error when content type is not correct" do
    assert_raise WechatMP.Error, fn ->
      Util.content_type([{"content-type", "trash; trash"}])
    end
  end

end
