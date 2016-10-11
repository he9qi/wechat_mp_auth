use Mix.Config

config :wechat_mp_auth, db_prefix:  "wechat_mp_auth_test"
config :wechat_mp_auth, authorizer: WechatMPAuth.DummyClient
config :wechat_mp_auth, c_a_token:  WechatMPAuth.DummyComponentAccessToken
