defmodule WechatMP.ClientTest do
  use ExUnit.Case, async: true
  # use Plug.Test

  import WechatMP.Client
  import WechatMP.TestHelpers

  setup do
    server = Bypass.open
    client = build_client(site: bypass_server(server))
    {:ok, client: client, server: server}
  end

  test "component_access_token_url!", %{client: client, server: server} do
    # component_access_token_url!(client)
  end

end
