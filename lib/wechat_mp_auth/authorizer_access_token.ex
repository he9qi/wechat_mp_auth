defmodule WechatMPAuth.AuthorizerAccessToken do
  @moduledoc """
    This module defines the `WechatMPAuth.AuthorizerAccessToken` struct
  """

  alias WechatMPAuth.Client
  import WechatMPAuth.Util

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

  @doc """
  Returns a new `WechatMPAuth.AuthorizerAccessToken` struct given the authorizer
  access token `string` and `%WechatMPAuth.Client{}`.
  """
  @spec new(binary, Client.t) :: t
  def new(token, client) when is_binary(token) do
    new(%{"authorization_info" => %{"authorizer_access_token" => token}}, client)
  end

  @doc """
  Returns a new `WechatMPAuth.AuthorizerAccessToken` struct given the response
  from `WechatMPAuth.Client.get_authorizer_access_token` and `%WechatMPAuth.Client{}`.
  """
  def new(%{"authorization_info" => response}, client) do
    struct __MODULE__, [
      client:         client,
      access_token:   response["authorizer_access_token"],
      refresh_token:  response["authorizer_refresh_token"],
      appid:          response["authorizer_appid"],
      expires_at:     (response["expires_in"] |> expires_at())]
  end

end
