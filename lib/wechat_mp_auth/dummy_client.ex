defmodule WechatMPAuth.DummyClient do
  @component_access_token "component-access-token-1234"
  @authorizer_access_token "authorizer-access-token-1234"
  @verify_ticket "ticket@@123"
  @refresh_token "refreshtoken@@@12345"
  @auth_code     "auth_code12345"
  @a_app_id      "wxabcde"

  def get_authorize_url(%WechatMPAuth.Client{
    client_id: client_id, redirect_uri: redirect_uri
  } = client, [verify_ticket: @verify_ticket]) do
    client =
      %{client | params: %{"component_access_token" => @component_access_token}}

    { client,
      "https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{client_id}&redirect_uri=#{redirect_uri}" }
  end

  def get_authorizer_access_token(client, [
    authorization_code: @auth_code,
    component_access_token: @component_access_token]) do
    {:ok,
      %WechatMPAuth.AuthorizerAccessToken{
        access_token: @authorizer_access_token,
        refresh_token: @refresh_token,
        appid: @a_app_id,
        client: client
      }
    }
  end
end

