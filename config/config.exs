# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :wechat_mp_auth, db_prefix: System.get_env("DB_PREFIX")
config :wechat_mp_auth, redis_uri: System.get_env("REDIS_URI") || "http://127.0.0.1:6379"
config :wechat_mp_auth, store:      WechatMPAuth.RedisStore
config :wechat_mp_auth, authorizer: WechatMPAuth.Client
config :wechat_mp_auth, c_a_token:  WechatMPAuth.ComponentAccessToken

config :wechat_mp_auth,
  client_id: "client123", #
  client_secret: "d1aifhuds6721637jahfjv76xh6sgc2", #
  redirect_uri: "http://example.com/auth/wx"

import_config "#{Mix.env}.exs"
