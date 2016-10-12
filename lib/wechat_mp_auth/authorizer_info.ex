defmodule WechatMPAuth.AuthorizerInfo do
  @type token :: binary
  @type t :: %__MODULE__{
               source: binary,
               app_id: binary, # 微信公众号ID
               component_access_token: token,
               access_token: token,
               refresh_token: token,
               name: binary
             }

  defstruct [
    :source,
    :app_id,
    :component_access_token,
    :access_token,
    :refresh_token,
    :name
  ]
end
