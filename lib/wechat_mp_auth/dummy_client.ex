defmodule WechatMPAuth.DummyClient do
  def get_authorize_url(%WechatMPAuth.Client{client_id: client_id, redirect_uri: redirect_uri} = client, [verify_ticket: "ticket@@123"]) do
    {client, "https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{client_id}&redirect_uri=#{redirect_uri}"}
  end
end

