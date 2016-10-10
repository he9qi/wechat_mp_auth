defmodule WechatMPAuth.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts              WechatMPAuth.Router.init([])
  @db_prefix         Application.get_env(:wechat_mp_auth, :db_prefix)
  @client_id         Application.get_env(:wechat_mp_auth, :client_id)
  @redirect_uri      Application.get_env(:wechat_mp_auth, :redirect_uri)
  @app_id            "entity_12345"
  @verify_ticket_key "#{@db_prefix}:component_verify_ticket:#{@app_id}"
  @verify_ticket_val "ticket@@123"

  describe "initiate wechat authorization" do
    setup do
      conn = conn(:get, "/auth/wx/#{@app_id}")
      conn = WechatMPAuth.Router.call(conn, @opts)

      on_exit fn ->
        Redix.command(:redix, ~w(DEL #{@verify_ticket_key}))
      end

      Redix.command(
        :redix, ~w(SET #{@verify_ticket_key} #{@verify_ticket_val})
      )

      {:ok, conn: conn}
    end

    test "redirects to wechat authorize url", %{conn: conn} do
      redirect_url ="https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{@client_id}&redirect_uri=#{@redirect_uri}/#{@app_id}/callback"

      {_, location} = conn.resp_headers |> Enum.find(fn {k, _} -> k == "location" end)
      assert location == redirect_url
      assert conn.status == 302
    end

    # test "stores component access token" do
    #
    # end
  end
end
