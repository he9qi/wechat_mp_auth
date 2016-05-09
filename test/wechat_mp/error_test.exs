defmodule WechatMP.ErrorTest do
  use ExUnit.Case

  test "it raises connection refused error message" do
    assert_raise WechatMP.Error, "Connection refused", fn ->
      raise WechatMP.Error, reason: :econnrefused
    end
  end

  test "it raises string error message" do
    assert_raise WechatMP.Error, "Wechat Error", fn ->
      raise WechatMP.Error, reason: "Wechat Error"
    end
  end

  test "it raises non-string error message" do
    error = %{:error => "Wechat Error"}
    reason_message = inspect error

    assert_raise WechatMP.Error, reason_message, fn ->
      raise WechatMP.Error, reason: error
    end
  end
end
