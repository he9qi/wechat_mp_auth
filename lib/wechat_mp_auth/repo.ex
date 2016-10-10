defmodule WechatMPAuth.Repo do
  alias WechatMPAuth.RepoInsertable

  @db_prefix Application.get_env(:peppa, :db_prefix)

  def insert(model, store) do
    with key <- RepoInsertable.key(model),
       value <- RepoInsertable.value(model),
         do: insert(key, value, store)
  end

  def insert(key, value, store) do
    case key |> build_full_key |> store.set(value) do
      :ok -> {:ok, key}
      other -> other
    end
  end

  def get(key, store) do
    key |> build_full_key |> store.get
  end

  defp build_full_key(key) do
    [@db_prefix, key] |> Enum.join(":")
  end
end
