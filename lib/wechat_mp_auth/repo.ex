defmodule WechatMPAuth.Repo do
  alias WechatMPAuth.RepoInsertable, as: RI

  @type model :: WechatMPAuth.RepoInsertable
  @type store :: WechatMPAuth.Store
  @type t :: %__MODULE__{name: binary, store: store}
  defstruct [:name, :store]

  @spec insert(t, model) :: {:ok, binary}
  def insert(repo, model) do
    with   key <- RI.key(model),
          data <- RI.serialize(model),
             _ <- data |> Enum.each(fn {k, v} -> insert(repo, key, k, v) end),
      do: {:ok, key}
  end

  @spec insert(t, binary, binary, binary) :: {:ok, binary}
  def insert(%__MODULE__{store: store} = repo, key, attr_key, value) do
    case build_key(repo, key, attr_key) |> store.set(value) do
      :ok -> {:ok, key}
      other -> other
    end
  end

  @spec get(t, model) :: model
  def get(%__MODULE__{} = repo, model) do
    with key <- RI.key(model),
      fields <- RI.fields(model),
      do: fields |> Enum.reduce(model, fn f, a -> %{a | f => get(repo, key, f)} end)
  end

  @spec get(t, binary, binary) :: binary
  def get(%__MODULE__{store: store} = repo, key, attr_key) do
    {:ok, value} = build_key(repo, key, attr_key) |> store.get
    value
  end

  defp build_key(%__MODULE__{name: name}, key, attr_key) do
    [name, key, attr_key]
    |> Enum.reject(&(is_nil(&1)))
    |> Enum.join(":")
  end
end
