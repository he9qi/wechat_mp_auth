defmodule WechatMP.Client do

  @moduledoc """
  This module defines the `WechatMP.Client` struct and is responsible for building
  and establishing a request for an component access token.
  """

  alias WechatMP.Client
  alias WechatMP.Request
  alias WechatMP.ComponentAccessToken

  @type strategy                   :: module
  @type client_id                  :: binary
  @type client_secret              :: binary
  @type site                       :: binary
  @type component_access_token_url :: binary
  @type pre_auth_code_url          :: binary
  @type param                      :: binary | %{binary => param} | [param]
  @type params                     :: %{binary => param}

  @type t :: %__MODULE__{
              strategy:      strategy,
              client_id:     client_id,
              client_secret: client_secret,
              site:          site,
              component_access_token_url: component_access_token_url,
              pre_auth_code_url:          pre_auth_code_url,
              params:        params}

  defstruct strategy: WechatMP.Strategy.AuthCode,
            client_id: "",
            client_secret: "",
            site: "",
            component_access_token_url: "/component/api_component_token",
            pre_auth_code_url: "component/api_create_preauthcode",
            params: %{}

  @doc """
  Builds a new WechatMP client struct using the `opts` provided.
  ## Client struct fields
  * `strategy` - a module that implements the Wechat MP OAuth strategy,
    defaults to `WechatMP.Strategy.AuthCode`
  * `client_id` - the client_id for the Wechat Component
  * `client_secret` - the client_secret for the Wechat Component
  * `site` - the OAuth2 provider site host
  * `component_access_token_url` - absolute or relative URL path to the authorization
    endpoint. Defaults to `"/component/api_component_token"`
  * `pre_auth_code_url` - absolute or relative URL path to the token endpoint.
    Defaults to `"/component/api_create_preauthcode"`
  * `params` - a map of request parameters
  * `headers` - a list of request headers
  * `redirect_uri` - the URI the provider should redirect to after authorization
     or token requests
  """
  @spec new(Keyword.t) :: t
  def new(opts), do: struct(__MODULE__, opts)

  @spec get_component_access_token(t, params) :: {:ok, ComponentAccessToken.t} | {:error, Error.t}
  def get_component_access_token(client, params \\ []) do
    {client, url} = component_access_token_url(client, params)
    case Request.request(:post, url, client.params) do
      {:ok, response} -> {:ok, ComponentAccessToken.new(response.body, client)}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Puts the specified `value` in the params for the given `key`.
  The key can be a `string` or an `atom`. Atoms are automatically
  convert to strings.
  """
  @spec put_param(t, String.t | atom, any) :: t
  def put_param(%Client{params: params} = client, key, value) do
    %{client | params: Map.put(params, param_key(key), value)}
  end

  @doc """
  Set multiple params in the client in one call.
  """
  @spec merge_params(t, WechatMP.params) :: t
  def merge_params(client, params) do
    params = Enum.reduce(params, %{}, fn {k,v}, acc ->
      Map.put(acc, param_key(k), v)
    end)
    %{client | params: Map.merge(client.params, params)}
  end

  defp to_url(client, :component_access_token_url) do
    {client, endpoint(client, client.component_access_token_url)}
  end

  defp component_access_token_url(client, params) do
    client
      |> client.strategy.get_component_access_token(params)
      |> to_url(:component_access_token_url)
  end

  defp param_key(binary) when is_binary(binary), do: binary
  defp param_key(atom) when is_atom(atom), do: Atom.to_string(atom)

  defp endpoint(client, <<"/"::utf8, _::binary>> = endpoint),
    do: client.site <> endpoint
  defp endpoint(_client, endpoint), do: endpoint
end
