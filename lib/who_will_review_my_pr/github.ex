defmodule Github do
  def oauth_uri do
    # TODO: implement state
    # http://developer.github.com/v3/oauth/#web-application-flow
    "https://github.com/login/oauth/authorize?client_id=#{Config.client_id}&scope=repo&redirect_uri=#{URI.encode(Config.root_url <> "/authenticate")}"
  end

  def authenticate(code) do
    client_id = Config.client_id
    client_secret = Config.client_secret
    uri = "https://github.com/login/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&code=#{code}&redirect_uri=#{URI.encode(Config.root_url <> "/authenticate")}"
    response = HTTP.post(uri)
    Logger.debug(response)
    String.slice(response, 13, 40)
  end

  def user(access_token) do
    uri = "https://api.github.com/user?access_token=#{access_token}"
    resp = HTTP.get(uri)
    {:ok, resp } = JSON.decode(resp)
    HashDict.get(resp, "login")
  end

  def random_reviewer(pull_request, access_token) do
    col = collaborators(pull_request, access_token)
    con = contributors(pull_request, access_token)
    if ListDict.size(con) == 0, do: con = contributors(pull_request, access_token)
    in_both = Common.members_of_both(con, col)
    Logger.debug(inspect(in_both))
    shuffled = Common.shuffle(in_both)
    Logger.debug(inspect(shuffled))
    Enum.take(shuffled,1)
  end

  def ask_to_review(pull_request, reviewer, access_token) do
    [_, _, _, owner, repo, _, number] = String.split(pull_request, "/")
    comment = "Hey @#{reviewer} would you have time to review this? [/®](http://who-will-review-my-pr.herokuapp.com)"
    uri = "https://api.github.com/repos/#{owner}/#{repo}/issues/#{number}/comments"
    request_body = "{ \"body\": \"#{comment}\" }"
    resp = HTTP.post(access_token, uri, request_body)
    Logger.debug(resp)
    resp
  end

  defp collaborators(pull_request, access_token) do
    [_, _, _, owner, repo, _, _] = String.split(pull_request, "/")

    uri = "https://api.github.com/repos/#{owner}/#{repo}/collaborators"
    resp = HTTP.get(access_token, uri)
    {:ok, resp } = JSON.decode(resp)
    Enum.map(resp, get_user_login(&1))
  end

  defp contributors(pull_request, access_token) do
    [_, _, _, owner, repo, _, _] = String.split(pull_request, "/")

    uri = "https://api.github.com/repos/#{owner}/#{repo}/stats/contributors"
    resp = HTTP.get(access_token, uri)
    {:ok, resp } = JSON.decode(resp)
    Enum.map(resp, get_contribution_author(&1))
  end

  defp get_user_login(user) do
    HashDict.get(user, "login")
  end

  defp get_contribution_author(contribution) do
    get_user_login(
      HashDict.get(contribution, "author")
    )
  end
end
