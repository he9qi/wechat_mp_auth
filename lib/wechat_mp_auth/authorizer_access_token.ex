defmodule WechatMPAuth.AuthorizerAccessToken do
  @moduledoc """
    This module defines the `WechatMPAuth.AuthorizerAccessToken` struct
  """

  alias WechatMPAuth.Client
  import WechatMPAuth.Util

  alias WechatMPAuth.Request
  alias WechatMPAuth.AuthorizerAccessToken

  @type access_token  :: binary
  @type refresh_token :: binary
  @type appid         :: binary
  @type expires_at    :: integer
  @type body          :: binary | %{}

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

  @doc """
  Makes a `POST` request to the given URL using the `WechatMPAuth.AuthorizerAccessToken`.
  """
  @spec post(t, binary, body) :: {:ok, Response.t} | {:error, Error.t}
  def post(token, url, body \\ ""),
    do: request(:post, token, url, body)

  @doc """
  Same as `post/3` but returns a `WechatMPAuth.Response` or `WechatMPAuth.Error` exception
  if the request results in an error.
  An `WechatMPAuth.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  @spec post!(t, binary, body) :: Response.t | Error.t
  def post!(token, url, body \\ ""),
    do: request!(:post, token, url, body)

  @doc """
  Makes a `GET` request to the given URL using the `WechatMPAuth.AuthorizerAccessToken`.
  """
  @spec get(t, binary) :: {:ok, Response.t} | {:error, Error.t}
  def get(token, url),
    do: request(:get, token, url, "")

  @doc """
  Same as `get/2` but returns a `WechatMPAuth.Response` or `WechatMPAuth.Error` exception if
  the request results in an error.
  """
  @spec get!(t, binary) :: Response.t | Error.t
  def get!(token, url),
    do: request!(:get, token, url, "")

  @doc """
  Makes a request of given type to the given URL using the `WechatMPAuth.AuthorizerAccessToken`.
  """
  @spec request(atom, t, binary, body) :: {:ok, Response.t} | {:error, Error.t}
  def request(method, token, url, body \\ "") do
    url = token |> process_url(url) |> access_token_url(token)
    case Request.request(method, url, body) do
      {:ok, response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Same as `request/4` but returns `WechatMPAuth.Response` or raises an error if an
  error occurs during the request.
  An `WechatMPAuth.Error` exception is raised if the request results in an
  error tuple (`{:error, reason}`).
  """
  @spec request!(atom, t, binary, body) :: Response.t | Error.t
  def request!(method, token, url, body \\ "") do
    case request(method, token, url, body) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  defp access_token_url(url, %AuthorizerAccessToken{access_token: access_token}) do
    url <> "?access_token=#{access_token}"
  end

  defp process_url(token, url) do
    case String.downcase(url) do
      <<"http://"::utf8, _::binary>> -> url
      <<"https://"::utf8, _::binary>> -> url
      _ -> token.client.site <> url
    end
  end

end
