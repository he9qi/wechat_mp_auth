defmodule WechatMPAuth.ErrorTest do
  use ExUnit.Case

  test "it raises connection refused error message" do
    assert_raise WechatMPAuth.Error, "Connection refused", fn ->
      raise WechatMPAuth.Error, reason: :econnrefused
    end
  end

  test "it raises string error message" do
    assert_raise WechatMPAuth.Error, "Wechat Error", fn ->
      raise WechatMPAuth.Error, reason: "Wechat Error"
    end
  end

  test "it raises non-string error message" do
    error = %{:error => "Wechat Error"}
    reason_message = inspect error

    assert_raise WechatMPAuth.Error, reason_message, fn ->
      raise WechatMPAuth.Error, reason: error
    end
  end
end
