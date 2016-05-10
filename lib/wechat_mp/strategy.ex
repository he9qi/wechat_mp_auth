defmodule WechatMP.Strategy do

  defmacro __using__(_) do
    quote do
      import WechatMP.Client
    end
  end
end
