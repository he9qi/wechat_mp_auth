# WeChat Media Platform Authentication

[![Build Status][travis-img]][travis] [![Hex Version][hex-img]][hex] [![License][license-img]][license]

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
          [{:wechat_mp_auth, "~> 0.0.1"}]
        end

  2. Ensure wechat_mp_auth is started before your application:

        def application do
          [applications: [:wechat_mp_auth]]
        end

## Usage

  Current strategy:

  - Authorization Code

### Authorization Code Flow (AuthCode Strategy)

  ```elixir
  # Initialize a client with client_id, client_secret, site, and redirect_uri.
  # The strategy option is optional as it defaults to `WechatMPAuth.Strategy.AuthCode`.
  client = WechatMPAuth.Client.new([
    strategy: WechatMPAuth.Strategy.AuthCode, #default
    client_id: "client_id",
    client_secret: "abc123",
    site: "https://auth.example.com",
    redirect_uri: "https://example.com/auth/callback"
  ])

  # `get_authorize_url` generates:
  #   1. the authorization URL using `component_verify_ticket` received from WeChat
  #   2. client that contains `component_access_token`
  {client, url} = WechatMPAuth.Client.get_authorize_url(client, [verify_ticket: verify_ticket])
  # component_access_token => `client.params["component_access_token"]`
  # authorization URL => "https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=client_id&pre_auth_code=preauthcode@@@xxx&redirect_uri=https://example.com/auth/callback"

  # Use the component access token to make a request for resources
  resource = WechatMPAuth.ComponentAccessToken.get!(token, "/api_get_authorizer_info?component_access_token=access-token-1234").body
  ```

## License

Please see [LICENSE](https://github.com/he9qi/ueberauth_weibo/blob/master/LICENSE) for licensing details.
