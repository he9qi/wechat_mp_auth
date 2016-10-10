defmodule WechatMPAuth.RedisStore do
  @use WechatMPAuth.Store

  def set(key, value) do
    {:ok, _} = Redix.command(:redix, ~w(SET #{key} #{value}))
    :ok
  end

  def get(key) do
    Redix.command(:redix, ~w(GET #{key}))
  end
end
