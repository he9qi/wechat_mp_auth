defmodule WechatMPAuth.Util do
  @moduledoc false

  def unix_now do
    {mega, sec, _micro} = :os.timestamp
    (mega * 1_000_000) + sec
  end

  @doc """
  Returns a unix timestamp based on now + expires_at (in seconds)
  """
  def expires_at(nil), do: nil
  def expires_at(val) when is_binary(val) do
    {int, _} = Integer.parse(val)
    int
  end
  def expires_at(int), do: unix_now + int

  def content_type(headers) do
    case get_content_type(headers) do
      {_, content_type} ->
        case :mimetype_parser.parse(content_type) do
          {:ok, [{type, subtype, _}]} ->
            type <> "/" <> subtype
          error ->
            raise WechatMPAuth.Error, reason: error
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
