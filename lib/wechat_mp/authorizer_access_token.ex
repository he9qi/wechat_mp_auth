defmodule WechatMP.AuthorizerAccessToken do
  alias WechatMP.Client
  import WechatMP.Util

  @type access_token  :: binary
  @type refresh_token :: binary
  @type appid         :: binary
  @type expires_at    :: integer

  @type t :: %__MODULE__{
              appid:         appid,
              access_token:  access_token,
              refresh_token: refresh_token,
              expires_at:    expires_at,
              client:        Client.t}

  defstruct access_token: "",
            refresh_token: "",
            appid: "",
            expires_at: nil,
            client: nil

  @spec new(binary, Client.t) :: t
  def new(token, client) when is_binary(token) do
    new(%{"authorizer_access_token" => token}, client)
  end

  def new(%{"authorization_info" => response}, client) do
    struct __MODULE__, [
      client:         client,
      access_token:   response["authorizer_access_token"],
      refresh_token:  response["authorizer_refresh_token"],
      appid:          response["authorizer_appid"],
      expires_at:     (response["expires_in"] |> expires_at())]
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
