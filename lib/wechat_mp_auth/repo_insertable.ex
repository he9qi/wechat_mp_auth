defprotocol WechatMPAuth.RepoInsertable do
  def key(model)
  def value(model)
end

defimpl WechatMPAuth.RepoInsertable, for: WechatMPAuth.ComponentVerifyTicket do
  def key(%WechatMPAuth.ComponentVerifyTicket{AppId: app_id, InfoType: info_type}) do
    [info_type, app_id] |> Enum.join(":")
  end

  def value(%WechatMPAuth.ComponentVerifyTicket{ComponentVerifyTicket: ticket}), do: ticket
end
