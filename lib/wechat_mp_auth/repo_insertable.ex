defprotocol WechatMPAuth.RepoInsertable do
  def key(model)
  def serialize(model)
  def fields(model)
end

defimpl WechatMPAuth.RepoInsertable, for: WechatMPAuth.ComponentVerifyTicket do
  alias WechatMPAuth.ComponentVerifyTicket

  def key(%ComponentVerifyTicket{app_id: app_id}) do
    "component_verify_ticket:#{app_id}"
  end

  def fields(%ComponentVerifyTicket{} = model) do
    model |> Map.from_struct |> Map.keys
  end

  def serialize(%ComponentVerifyTicket{} = model) do
    model |> Map.from_struct
  end
end

defimpl WechatMPAuth.RepoInsertable, for: WechatMPAuth.AuthorizerInfo do
  alias WechatMPAuth.AuthorizerInfo

  def key(%AuthorizerInfo{source: source}) do
    "authorizer_info:#{source}"
  end

  def fields(%AuthorizerInfo{} = model) do
    model |> Map.from_struct |> Map.keys
  end

  def serialize(%AuthorizerInfo{} = model) do
    model |> Map.from_struct
  end
end
