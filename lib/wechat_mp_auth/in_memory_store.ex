defmodule WechatMPAuth.InMemoryStore do
  @use WechatMPAuth.Store

  def set(_, nil), do: :ok
  def set(key, value) do
    ConCache.put(:in_memory_store, key, value)
    :ok
  end

  def get(key) do
    {:ok, ConCache.get(:in_memory_store, key)}
  end

  def delete(key) do
    ConCache.delete(:in_memory_store, key)
    :ok
  end
end
