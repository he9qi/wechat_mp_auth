# WeChat Media Platform Authentication

[![Build Status][travis-img]][travis] [![Coverage Status][coverage-img]][coverage] [![Hex Version][hex-img]][hex] [![License][license-img]][license]

[coverage-img]: https://coveralls.io/repos/he9qi/wechat_mp_auth/badge.svg?branch=master&service=github
[coverage]: https://coveralls.io/github/he9qi/wechat_mp_auth?branch=master
[travis-img]: https://travis-ci.org/he9qi/wechat_mp_auth.svg?branch=master
[travis]: https://travis-ci.org/he9qi/wechat_mp_auth
[hex-img]: https://img.shields.io/hexpm/v/wechat_mp_auth.svg
[hex]: https://hex.pm/packages/wechat_mp_auth
[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg
[license]: http://opensource.org/licenses/MIT

> An Elixir WeChat Media Platform Authentication Client Library [微信第三方平台授权](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1453779503&token=0fbba0141afd0e79e61025b7a0cbf63a1850251e&lang=zh_CN)

## Installation

  1. Add wechat_mp_auth to your list of dependencies in `mix.exs`:

        def deps do
          [{:wechat_mp_auth, "~> 0.0.3"}]
        end

  2. Ensure wechat_mp_auth is started before your application:

        def application do
          [applications: [:wechat_mp_auth]]
        end

## Usage

  1. Initialize a client with `client_id`, `client_secret`, and `redirect_uri`.

  ```elixir
  client = WechatMPAuth.Client.new([
    strategy: WechatMPAuth.Strategy.AuthCode, #default
    client_id: "client_id",
    client_secret: "abc123",
    redirect_uri: "https://example.com/auth/callback"
  ])
  ```

  2. Use `get_authorize_url` to generate:
    - the authorization URL using `component_verify_ticket` received from WeChat
    - client that contains `component_access_token`

  ```elixir
  {client, url} = WechatMPAuth.Client.get_authorize_url(client, [verify_ticket: verify_ticket])
  # component_access_token => `client.params["component_access_token"]`
  # authorization URL => "https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=client_id&pre_auth_code=preauthcode@@@xxx&redirect_uri=https://example.com/auth/callback"
  ```

  3. After authorizing from the above URL, server redirects to `redirect_uri` with query params: `authorization_code` and `expires_in` (https://example.com/auth/callback?auth_code=@@@&expires_in=600). Use `component_access_token` and `authorization_code` to get authorizer access token.

  ```elixir
  {:ok, authorizer_access_token} = client |> WechatMPAuth.Client.get_authorizer_access_token([authorization_code: authorization_code, component_access_token: "component-access-token"])
  ```

  3. Use `component_access_token` to make a request for resources.

  ```elixir
  resource = WechatMPAuth.ComponentAccessToken.get!(token, "/api_get_authorizer_info").body
  ```

## License

Please see [LICENSE](https://github.com/he9qi/wechat_mp_auth/blob/master/LICENSE) for licensing details.
