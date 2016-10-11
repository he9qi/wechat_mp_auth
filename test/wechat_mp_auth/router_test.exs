defmodule WechatMPAuth.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts              WechatMPAuth.Router.init([])
  @db_prefix         Application.get_env(:wechat_mp_auth, :db_prefix)
  @client_id         Application.get_env(:wechat_mp_auth, :client_id)
  @redirect_uri      Application.get_env(:wechat_mp_auth, :redirect_uri)
  @entity_id         "entity_12345"
  @verify_ticket_key "#{@db_prefix}:component_verify_ticket:#{@client_id}"
  @c_a_token_key     "#{@db_prefix}:authorizer:#{@entity_id}:component_access_token"
  @a_a_token_key     "#{@db_prefix}:authorizer:#{@entity_id}:authorizer_access_token"
  @a_r_token_key     "#{@db_prefix}:authorizer:#{@entity_id}:authorizer_refresh_token"
  @a_app_id_key      "#{@db_prefix}:authorizer:#{@entity_id}:authorizer_app_id"
  @a_name_key        "#{@db_prefix}:authorizer:#{@entity_id}:authorizer_name"
  @verify_ticket_val "ticket@@123"
  @auth_code         "auth_code12345"
  @component_access_token "component-access-token-1234"
  @refresh_token     "refreshtoken@@@12345"
  @a_app_id          "wxabcde"
  @authorizer_name   "Lafanyi App"

  describe "handles wechat authorization callback" do
    setup do
      Redix.command(
        :redix, ~w(SET #{@c_a_token_key} #{@component_access_token})
      )
      on_exit fn ->
        Redix.command(:redix, ~w(DEL #{@a_a_token_key}))
        Redix.command(:redix, ~w(DEL #{@a_r_token_key}))
        Redix.command(:redix, ~w(DEL #{@a_r_token_key}))
      end

      params = %{auth_code: @auth_code}
      conn = conn(:post, "/auth/wx/#{@entity_id}/callback", params)
      conn = WechatMPAuth.Router.call(conn, @opts)

      {:ok, conn: conn}
    end

    test "returns success", %{conn: conn} do
      assert conn.status == 200
    end

    test "saves authorizer access token" do
      {:ok, authorizer_access_token} =
        Redix.command(:redix, ~w(GET #{@a_a_token_key}))

      assert "authorizer-access-token-1234" == authorizer_access_token
    end

    test "saves authorizer app id" do
      {:ok, authorizer_app_id} =
        Redix.command(:redix, ~w(GET #{@a_app_id_key}))

      assert @a_app_id == authorizer_app_id
    end

    test "saves authorizer refresh token" do
      {:ok, authorizer_refresh_token} =
        Redix.command(:redix, ~w(GET #{@a_r_token_key}))

      assert @refresh_token == authorizer_refresh_token
    end

    test "saves authorizer name" do
      {:ok, authorizer_name} =
        Redix.command(:redix, ~w(GET #{@a_name_key}))

      assert @authorizer_name == authorizer_name
    end
  end

  describe "initiate wechat authorization" do
    setup do
      Redix.command(
        :redix, ~w(SET #{@verify_ticket_key} #{@verify_ticket_val})
      )

      conn = conn(:get, "/auth/wx/#{@entity_id}")
      conn = WechatMPAuth.Router.call(conn, @opts)

      on_exit fn ->
        Redix.command(:redix, ~w(DEL #{@verify_ticket_key}))
        Redix.command(:redix, ~w(DEL #{@c_a_token_key}))
      end

      {:ok, conn: conn}
    end

    test "redirects to wechat authorize url", %{conn: conn} do
      redirect_url ="https://mp.weixin.qq.com/cgi-bin/componentloginpage?component_appid=#{@client_id}&redirect_uri=#{@redirect_uri}/#{@entity_id}/callback"

      {_, location} =
        conn.resp_headers |> Enum.find(fn {k, _} -> k == "location" end)
      assert location == redirect_url
      assert conn.status == 302
    end

    test "stores component access token" do
      {:ok, component_access_token} =
        Redix.command(:redix, ~w(GET #{@c_a_token_key}))

      assert "component-access-token-1234" == component_access_token
    end
  end
end
