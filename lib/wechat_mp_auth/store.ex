defmodule WechatMPAuth.Store do
  @callback set(key :: binary, value :: binary) :: :ok | {:error, binary}
  @callback get(key :: binary) :: {:ok, binary} | {:error, binary}
  @callback delete(key :: binary) :: :ok | {:error, binary}
end
