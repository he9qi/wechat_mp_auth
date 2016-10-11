defmodule WechatMPAuth.DummyComponentAccessToken do
  @client_id         Application.get_env(:wechat_mp_auth, :client_id)

  defmodule Result do
    defstruct [:body]
  end

  def post!(token, "/component/api_get_authorizer_info", %{component_appid: @client_id, authorizer_appid: "wxabcde"}) do
    %WechatMPAuth.DummyComponentAccessToken.Result{body:
      %{"authorization_info" => %{
        "authorizer_appid" => "wxcbbafb71295a8940",
        "func_info" => [
           %{"funcscope_category" => %{"id" => 1}},
           %{"funcscope_category" => %{"id" => 15}},
           %{"funcscope_category" => %{"id" => 4}},
           %{"funcscope_category" => %{"id" => 7}},
           %{"funcscope_category" => %{"id" => 2}},
           %{"funcscope_category" => %{"id" => 3}},
           %{"funcscope_category" => %{"id" => 11}},
           %{"funcscope_category" => %{"id" => 6}},
           %{"funcscope_category" => %{"id" => 5}},
           %{"funcscope_category" => %{"id" => 8}},
           %{"funcscope_category" => %{"id" => 13}},
           %{"funcscope_category" => %{"id" => 10}}]
        },
        "authorizer_info" => %{
          "alias" => "lafanyiapp",
          "business_info" => %{"open_card" => 0, "open_pay" => 0, "open_scan" => 0,
            "open_shake" => 0, "open_store" => 0},
          "head_img" => "http://wx.qlogo.cn/mmopen/0T8yO33zeejDhF9TiajfNaBia8VdaVlVkTAQBGzGLl5v0N5SEyX1LutlEiaP719eSSuETy2YiaQR42ef5dxM0nFjzhdn1oEjwNmh/0",
          "idc" => 1,
          "nick_name" => "Lafanyi App",
          "qrcode_url" => "http://mmbiz.qpic.cn/mmbiz_jpg/XdWfIXHNJcaGXiaeHgbm1DR8zXiblicDia0gDDgx9417Mjic6j056VPUOBhiaNkbnWv1nxNVKBAuENPlRRJFSTnGBSxA/0",
          "service_type_info" => %{"id" => 2}, "user_name" => "gh_59fb8895dafa",
          "verify_type_info" => %{"id" => 0}}}
    }
  end
end
