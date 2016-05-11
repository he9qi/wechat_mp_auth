defmodule WechatMP.ComponentAccessToken do
  alias WechatMP.Client
  import WechatMP.Util

  alias WechatMP.Request

  @standard ["component_access_token", "expires_in"]

  @type access_token  :: binary
  @type expires_at    :: integer
  @type body          :: binary | %{}

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

  @doc """
  Makes a `POST` request to the given URL using the `WechatMP.ComponentAccessToken`.
  """
  @spec post(t, binary, body) :: {:ok, Response.t} | {:error, Error.t}
  def post(token, url, body \\ ""),
    do: request(:post, token, url, body)

  @doc """
  Makes a `GET` request to the given URL using the `WechatMP.ComponentAccessToken`.
  """
  @spec get(t, binary, body) :: {:ok, Response.t} | {:error, Error.t}
  def get(token, url, body \\ ""),
    do: request(:get, token, url, "")

  @doc """
  Makes a request of given type to the given URL using the `WechatMP.ComponentAccessToken`.
  """
  @spec request(atom, t, binary, body) :: {:ok, Response.t} | {:error, Error.t}
  def request(method, token, url, body \\ "") do
    url = process_url(token, url)
    case Request.request(method, url, body) do
      {:ok, response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end

  defp process_url(token, url) do
    case String.downcase(url) do
      <<"http://"::utf8, _::binary>> -> url
      <<"https://"::utf8, _::binary>> -> url
      _ -> token.client.site <> url
    end
  end
end
