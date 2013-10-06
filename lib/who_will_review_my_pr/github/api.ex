
defmodule Github.Api do
  def authorize_uri do
    uri.authorize(client_id, redirect_uri)
  end

  def access_token(code) do
    HTTP.post(
      uri.access_token(client_id, client_secret, code, redirect_uri)
    )
  end

  def user(access_token) do
    HTTP.get(access_token, uri.user)
  end

  def collaborators(access_token, pull_request) do
    [_, _, _, owner, repo, _, _] = String.split(pull_request, "/")

    HTTP.get(access_token, uri.collaborators(owner, repo))
  end

  def contributors(access_token, pull_request) do
    [_, _, _, owner, repo, _, _] = String.split(pull_request, "/")

    HTTP.get(access_token, uri.contributors(owner, repo))
  end

  def post_comment(access_token, pull_request, comment) do
    [_, _, _, owner, repo, _, number] = String.split(pull_request, "/")
    request_body = "{ \"body\": \"#{comment}\" }"
    HTTP.post(access_token, uri.comments(owner, repo, number), request_body)
  end

  defp client_id do
    Config.client_id
  end

  defp client_secret do
    Config.client_secret
  end

  defp redirect_uri do
    Config.root_url <> "/authenticate"
  end

  defp uri do
    Github.Uri
  end
end

