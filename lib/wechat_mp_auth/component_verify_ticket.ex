defmodule WechatMPAuth.ComponentVerifyTicket do
  @type t :: %__MODULE__{
               app_id: binary,
               ticket: binary
             }
  defstruct [:app_id, :ticket]
end
