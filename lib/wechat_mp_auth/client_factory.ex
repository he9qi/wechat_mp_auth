defmodule WechatMPAuth.ClientFactory do
  @client_id     Application.get_env(:wechat_mp_auth, :client_id)
  @client_secret Application.get_env(:wechat_mp_auth, :client_secret)
  @redirect_uri  Application.get_env(:wechat_mp_auth, :redirect_uri)

  def create_client(source) do
    WechatMPAuth.Client.new([
      strategy: WechatMPAuth.Strategy.AuthCode,
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: @redirect_uri <> "/#{source}/callback"
    ])
  end
end

