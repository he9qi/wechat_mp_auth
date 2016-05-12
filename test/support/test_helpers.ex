defmodule WechatMPAuth.TestHelpers do

  import Plug.Conn
  import ExUnit.Assertions

  def bypass_server(%Bypass{port: port}) do
    "http://localhost:#{port}"
  end

  def bypass(server, method, path, fun) do
    bypass(server, method, path, [], fun)
  end
  def bypass(server, method, path, opts, fun) do
    {token, opts}   = Keyword.pop(opts, :token, nil)
    {accept, _opts} = Keyword.pop(opts, :accept, "json")

    Bypass.expect server, fn conn ->
      conn = parse_req_body(conn)

      assert conn.method == method
      assert conn.request_path == path
      assert_accepts(conn, accept)

      fun.(conn)
    end
  end

  defp parse_req_body(conn) do
    opts = [parsers: [:urlencoded, :json],
            pass: ["*/*"],
            json_decoder: Poison]
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  defp assert_accepts(conn, accept) do
    mime =
      case accept do
        "json" -> "application/json"
        _      -> accept
      end
    assert get_req_header(conn, "accept") == [mime]
  end

  def json(conn, status, body \\ []) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, Poison.encode!(body))
  end

  def build_client(opts \\ []) do
    default_client_opts
    |> Keyword.merge(opts)
    |> WechatMPAuth.Client.new()
  end

  def build_token(opts \\ [], %WechatMPAuth.Client{} = client) do
    default_token_opts
    |> Keyword.merge(opts)
    |> stringify_keys()
    |> WechatMPAuth.ComponentAccessToken.new(client)
  end

  defp get_config(key) do
    Application.get_env(:wechat_mp_auth, key)
  end

  defp default_client_opts do
    [client_id: get_config(:client_id),
     client_secret: get_config(:client_secret),
     redirect_uri: get_config(:redirect_uri)]
  end

  defp default_token_opts do
    [component_access_token: "abcdefgh",
     expires_in: 600]
  end

  defp stringify_keys(dict) do
    dict
    |> Enum.map(fn {k,v} -> {Atom.to_string(k), v} end)
    |> Enum.into(%{})
  end
end
