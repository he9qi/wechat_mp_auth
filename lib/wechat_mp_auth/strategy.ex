defmodule WechatMPAuth.Strategy do

  defmacro __using__(_) do
    quote do
      import WechatMPAuth.Client
    end
  end
end
