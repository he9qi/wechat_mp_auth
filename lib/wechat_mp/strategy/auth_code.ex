defmodule WechatMP.Strategy.AuthCode do

  use WechatMP.Strategy

  def get_component_access_token(client, params) do
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
end
