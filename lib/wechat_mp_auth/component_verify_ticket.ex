defmodule WechatMPAuth.ComponentVerifyTicket do
  defstruct AppId: nil,
            CreateTime: nil,
            InfoType: "component_verify_ticket",
            ComponentVerifyTicket: nil

  alias WechatMPAuth.RepoInsertable
  alias WechatMPAuth.Repo

  def load(app_id, store) do
    with ticket <- %__MODULE__{AppId: app_id},
            key <- RepoInsertable.key(ticket),
   {:ok, value} <- Repo.get(key, store),
            do: {:ok, %{ ticket | ComponentVerifyTicket: value }}
  end
end
