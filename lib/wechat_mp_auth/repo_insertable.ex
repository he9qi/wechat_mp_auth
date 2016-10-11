defprotocol WechatMPAuth.RepoInsertable do
  def key(model)
  def value(model)
end

defimpl WechatMPAuth.RepoInsertable, for: WechatMPAuth.ComponentVerifyTicket do
  alias WechatMPAuth.ComponentVerifyTicket
  def key(%ComponentVerifyTicket{AppId: app_id, InfoType: info_type}) do
    [info_type, app_id] |> Enum.join(":")
  end
  def value(%ComponentVerifyTicket{ComponentVerifyTicket: ticket}), do: ticket
end

defimpl WechatMPAuth.RepoInsertable, for: BitString do
  def key(str), do: str
  def value(str), do: str
end
