defmodule WechatMPAuth.RedisStore do
  @use WechatMPAuth.Store

  # TODO: throws Redix.Error
  def set(key, value) do
    {:ok, _} = Redix.command(:redix, ["SET", key, value])
    :ok
  end

  def get(key) do
    Redix.command(:redix, ~w(GET #{key}))
  end
end
