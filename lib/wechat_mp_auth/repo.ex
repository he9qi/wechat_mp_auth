defmodule WechatMPAuth.Repo do
  alias WechatMPAuth.RepoInsertable

  defstruct [:db_name, :prefix_key, :store]

  def insert(repo, model) do
    with key <- RepoInsertable.key(model),
       value <- RepoInsertable.value(model),
         do: insert(repo, key, value)
  end

  def insert(%__MODULE__{store: store} = repo, key, value) do
    case build_full_key(repo, key) |> store.set(value) do
      :ok -> {:ok, key}
      other -> other
    end
  end

  def get(%__MODULE__{store: store} = repo, key) do
    case build_full_key(repo, key) |> store.get do
      {:ok, nil} -> {:error, "cannot find value for #{key}"}
      other -> other
    end
  end

  defp build_full_key(%__MODULE__{db_name: db_name, prefix_key: prefix_key}, key) do
    [db_name, prefix_key, key]
    |> Enum.reject(&(is_nil(&1)))
    |> Enum.join(":")
  end
end
