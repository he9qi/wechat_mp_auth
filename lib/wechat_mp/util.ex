defmodule WechatMP.Util do
  @moduledoc false

  def unix_now do
    {mega, sec, _micro} = :os.timestamp
    (mega * 1_000_000) + sec
  end

  def content_type(headers) do
    case get_content_type(headers) do
      {_, content_type} ->
        case :mimetype_parser.parse(content_type) do
          {:ok, [{type, subtype, _}]} ->
            type <> "/" <> subtype
          error ->
            raise WechatMP.Error, reason: error
        end
      nil ->
        "application/json"
    end
  end

  defp get_content_type(headers) do
    List.keyfind(headers, "Content-Type", 0) ||
    List.keyfind(headers, "content-type", 0)
  end

  def endpoint(site, <<"/"::utf8, _::binary>> = endpoint),
    do: site <> endpoint
  def endpoint(_client, endpoint), do: endpoint
end
