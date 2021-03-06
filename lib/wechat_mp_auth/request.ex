defmodule WechatMPAuth.Request do
  @moduledoc false

  use HTTPoison.Base

  import WechatMPAuth.Util

  alias WechatMPAuth.Error
  alias WechatMPAuth.Response

  def request(method, url, body \\ "", headers \\ [], opts \\ []) do
    content_type = content_type(headers)
    body = process_request_body(body, content_type)
    headers = process_request_headers(headers, content_type)

    case super(method, url, body, headers, opts) do
      {:ok, %HTTPoison.Response{status_code: status, headers: headers, body: body}} ->
        response = Response.new(status, headers, body)
        case response.body do
          %{"errcode" => 0} -> {:ok, response}
          %{"errcode" => _} -> {:error, %Error{reason: response.body["errmsg"]}}
          _ -> {:ok, response}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %Error{reason: reason}}
    end
  end

  def request!(method, url, body \\ "", headers \\ [], options \\ []) do
    case request(method, url, body, headers, options) do
      {:ok, response} -> response
      {:error, error} -> raise error
    end
  end

  defp process_request_headers(headers, content_type), do:
  [{"Accept", content_type} | headers]

  defp process_request_body("", _), do: ""
  defp process_request_body([], _), do: ""
  defp process_request_body(body, "application/json"), do: Poison.encode!(body)
  defp process_request_body(body, "application/x-www-form-urlencoded"), do: URI.encode_query(body)
end
