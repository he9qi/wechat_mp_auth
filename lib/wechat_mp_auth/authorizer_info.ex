defmodule WechatMPAuth.AuthorizerInfo do
  @type token :: binary
  @type t :: %__MODULE__{
               source: binary,
               app_id: binary, # 微信公众号ID
               component_access_token: token,
               access_token: token,
               refresh_token: token,
               name: binary
             }

  defstruct [
    :source,
    :app_id,
    :component_access_token,
    :access_token,
    :refresh_token,
    :name
  ]

  alias WechatMPAuth.ComponentVerifyTicket, as: CVT
  alias WechatMPAuth.ComponentAccessToken,  as: CAT
  alias WechatMPAuth.AuthorizerAccessToken, as: AAT
  alias WechatMPAuth.Client
  alias WechatMPAuth.Repo

  def get_url(client, %CVT{ticket: ticket}, source, authorizer) do
    get_url(client, ticket, source, authorizer)
  end
  def get_url(client, ticket, source, authorizer) do
    with {client, url} <- authorizer.get_authorize_url(client, verify_ticket: ticket),
      %Client{params: %{"component_access_token" => token}} <- client,
       authorizer_info <- %__MODULE__{component_access_token: token, source: source},
       do: {:ok, url, authorizer_info}
  end

  def get_authorizer_info(
    %Client{client_id: client_id} = client,
    auth_code,
    source,
    repo,
    authorizer,
    c_a_token) do

   with authorizer_info <- %__MODULE__{source: source},
    %__MODULE__{
      component_access_token: ca_token
    } = authorizer_info <- Repo.get(repo, authorizer_info),
                    cat <- CAT.new(ca_token, client),
    {:ok,
     %AAT{
       access_token: access_token,
       refresh_token: refresh_token,
       appid: app_id}}  <- authorizer.get_authorizer_access_token(
                             client,
                             authorization_code: auth_code,
                             component_access_token: ca_token),
    %{ "authorizer_info" =>
      %{ "nick_name" => name }} <- c_a_token.post!(
                                     cat,
                                     "/component/api_get_authorizer_info",
                                     %{component_appid: client_id, authorizer_appid: app_id}
                                   ).body,
      do: %{authorizer_info |
            access_token: access_token,
            refresh_token: refresh_token,
            app_id: app_id,
            name: name,
            component_access_token: ca_token,
            source: source}
  end
end
