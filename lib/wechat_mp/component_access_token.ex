defmodule WechatMP.ComponentAccessToken do
  alias WechatMP.Client
  import WechatMP.Util

  @standard ["component_access_token", "expires_in"]

  @type access_token  :: binary
  @type expires_at    :: integer

  @type t :: %__MODULE__{
              access_token: access_token,
              expires_at:   expires_at,
              client:       Client.t}

  defstruct access_token: "",
            expires_at: nil,
            client: nil

  @spec new(binary, Client.t) :: t
  def new(token, client) when is_binary(token) do
    new(%{"component_access_token" => token}, client)
  end

  def new(response, client) do
    {std, other} = Dict.split(response, @standard)

    struct __MODULE__, [
      client:         client,
      access_token:   std["component_access_token"],
      expires_at:     (std["expires_in"] || other["expires"] |> expires_at())]
  end

  @doc """
  Returns a unix timestamp based on now + expires_at (in seconds)
  """
  def expires_at(nil), do: nil
  def expires_at(val) when is_binary(val) do
    {int, _} = Integer.parse(val)
    int
  end
  def expires_at(int), do: unix_now + int

end
