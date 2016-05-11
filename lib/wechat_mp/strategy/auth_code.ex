defmodule WechatMP.Strategy.AuthCode do

  use WechatMP.Strategy
  import WechatMP.Util

  alias WechatMP.ComponentAccessToken
  alias WechatMP.Request

  def get_component_access_token_params(client, params) do
    {verify_ticket, params} = Keyword.pop(params, :verify_ticket)

    unless verify_ticket do
      raise WechatMP.Error, reason: "Missing required key `verify_ticket` for `#{inspect __MODULE__}`"
    end

    client
      |> put_param(:component_appid, client.client_id)
      |> put_param(:component_appsecret, client.client_secret)
      |> put_param(:component_verify_ticket, verify_ticket)
      |> merge_params(params)
  end

  def get_pre_auth_code(client, %ComponentAccessToken{access_token: access_token}) do
    {client, url} = pre_auth_code_url(client, %{component_access_token: access_token})
    case Request.request(:post, url, client.params) do
      {:ok, response} -> {:ok, response.body}
      {:error, error} -> {:error, error}
    end
  end

  def pre_auth_code_url(client, %{component_access_token: _} = params) do
    client
      |> put_param(:component_appid, client.client_id)
      |> merge_params(params)
      |> to_url(:pre_auth_code_url)
  end

  def authorize_url(client, %{pre_auth_code: _} = params) do
    client
      |> put_param(:component_appid, client.client_id)
      |> put_param(:redirect_uri, client.redirect_uri)
      |> merge_params(params)
  end
  def authorize_url(client, params) do
    component_access_token = get_component_access_token!(client, params)
    {:ok, %{"pre_auth_code" => pre_auth_code}} = get_pre_auth_code(client, component_access_token)
    authorize_url(client, %{pre_auth_code: pre_auth_code})
  end

  defp to_url(client, :pre_auth_code_url) do
    params = Map.take(client.params, ["component_access_token"])
    url = endpoint(client.site, client.pre_auth_code_url) <> "?" <> URI.encode_query(params)
    {client, url}
  end
end
