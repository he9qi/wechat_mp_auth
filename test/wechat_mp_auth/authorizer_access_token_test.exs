defmodule WechatMPAuth.AuthorizerAccessTokenTest do
  use ExUnit.Case, async: true

  import WechatMPAuth.TestHelpers
  alias WechatMPAuth.AuthorizerAccessToken

  setup do
    client = build_client()
    {:ok, client: client}
  end

  test "new authorizer_access_token from string", %{client: client} do
    access_token = "authorizer-access-token-1234"

    authorizer_access_token = AuthorizerAccessToken.new(access_token, client)

    assert authorizer_access_token.access_token == access_token
    assert authorizer_access_token.client
  end

  test "new authorizer_access_token from map", %{client: client} do
    access_token = "authorizer-access-token-1234"
    refresh_token = "authorizer-refresh-token-1234"
    authorizer_appid = "authorizer-appid"
    expires_in = 600

    params = %{
      "authorization_info" => %{
        "authorizer_access_token" => access_token,
        "authorizer_refresh_token" => refresh_token,
        "authorizer_appid" => authorizer_appid,
        "expires_in" => expires_in
      }
    }

    authorizer_access_token = AuthorizerAccessToken.new(params, client)

    assert authorizer_access_token.access_token == access_token
    assert authorizer_access_token.refresh_token == refresh_token
    assert authorizer_access_token.appid == authorizer_appid
    assert authorizer_access_token.expires_at
    assert authorizer_access_token.client
  end
end
