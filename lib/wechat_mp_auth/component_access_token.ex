defmodule WechatMPAuth.ComponentAccessToken do
  @moduledoc """
  This module defines the `WechatMPAuth.ComponentAccessToken` struct and
  provides functionality to make authorized requests to an WechatMPAuth provider
  using the ComponentAccessToken returned by the provider.

  The `WechatMPAuth.ComponentAccessToken` struct is created for you when you use the
  `WechatMPAuth.Client.get_component_access_token`
  ### Notes
  * If a full url is given (e.g. "http://www.example.com/api/resource") then it
  will use that otherwise you can specify an endpoint (e.g. "/api/resource") and
  it will append it to the `Client.site`.
  ### Examples
  ```
  token =  WechatMPAuth.ComponentAccessToken.new("abc123", %WechatMPAuth.Client{site: "www.example.com"})
  case WechatMPAuth.ComponentAccessToken.get(token, "/some/resource") do
    {:ok, %WechatMPAuth.Response{status_code: 401}} ->
      "Not Good"
    {:ok, %WechatMPAuth.Response{status_code: status_code, body: body}} when status_code in [200..299] ->
      "Yay!!"
    {:error, %WechatMPAuth.Error{reason: reason}} ->
      reason
  end
  response = WechatMPAuth.ComponentAccessToken.get!(token, "/some/resource")
  response = WechatMPAuth.ComponentAccessToken.post!(token, "/some/other/resources", %{foo: "bar"})
```
  """
  alias WechatMPAuth.Client
  import WechatMPAuth.Util

  alias WechatMPAuth.Request
  alias WechatMPAuth.ComponentAccessToken

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

  @doc """
  Returns a new `WechatMPAuth.ComponentAccessToken` struct given the authorizer
  access token `string` and `%WechatMPAuth.Client{}`.
  """
  @spec new(binary, Client.t) :: t
  def new(token, client) when is_binary(token) do
    new(%{"component_access_token" => token}, client)
  end

  @doc """
  Same as `new/2` except that the first arg is a `map`.
  Note if giving a map, please be sure to make the key a `string` no an `atom`.
  This is used by `WechatMPAuth.Client.get_component_access_token/2` to create
  the `WechatMPAuth.ComponentAccessToken` struct.

  ### Example
  ```
  iex(1)> WechatMPAuth.ComponentAccessToken.new("clientId", %WechatMPAuth.Client{})
  %WechatMPAuth.ComponentAccessToken{access_token: "clientId", appid: "",
   client: %WechatMPAuth.Client{authorize_url: "https://mp.weixin.qq.com/cgi-bin/componentloginpage",
   authorizer_access_token_url: "/component/api_query_auth",
   client_id: "clientId", client_secret: "d1aifhuds6721637jahfjv76xh6sgc2",
   component_access_token_url: "/component/api_component_token", params: %{},
   pre_auth_code_url: "/component/api_create_preauthcode",
   redirect_uri: "http://example.com/weixin_callback", site: "",
   strategy: WechatMPAuth.Strategy.AuthCode}, expires_at: nil,
   refresh_token: ""}
  ```

  """
  def new(response, client) do
    {std, other} = Dict.split(response, @standard)

    struct __MODULE__, [
      client:         client,
      access_token:   std["component_access_token"],
      expires_at:     (std["expires_in"] || other["expires"] |> expires_at())]
  end

  @doc """
  Makes a `POST` request to the given URL using the `WechatMPAuth.ComponentAccessToken`.
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
  Makes a `GET` request to the given URL using the `WechatMPAuth.ComponentAccessToken`.
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
  Makes a request of given type to the given URL using the `WechatMPAuth.ComponentAccessToken`.
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


  defp access_token_url(url, %ComponentAccessToken{access_token: access_token}) do
    mark = if String.ends_with?(url, "/"), do: "?", else: "/?"
    url <> mark <> "component_access_token=#{access_token}"
  end

  defp process_url(token, url) do
    case String.downcase(url) do
      <<"http://"::utf8, _::binary>> -> url
      <<"https://"::utf8, _::binary>> -> url
      _ -> token.client.site <> url
    end
  end
end
