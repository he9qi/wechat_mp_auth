# WechatMP

**WeChat Media Platform OAuth** [微信第三方平台授权](https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1453779503&token=0fbba0141afd0e79e61025b7a0cbf63a1850251e&lang=zh_CN)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add wechat_mp to your list of dependencies in `mix.exs`:

        def deps do
          [{:wechat_mp, "~> 0.0.1"}]
        end

  2. Ensure wechat_mp is started before your application:

        def application do
          [applications: [:wechat_mp]]
        end
