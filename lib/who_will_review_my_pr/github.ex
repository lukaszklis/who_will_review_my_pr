defmodule Github do
  def oauth_uri do
    api.authorize_uri
  end

  def authenticate(code) do
    response = api.access_token(code)
    Logger.debug(response)
    String.slice(response, 13, 40)
  end

  def user(access_token) do
    resp = api.user(access_token)
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
    comment = "Hey @#{reviewer} would you have time to review this? [/®](http://who-will-review-my-pr.herokuapp.com)"
    resp = api.post_comment(access_token, pull_request, comment)
    Logger.debug(resp)
    resp
  end

  defp collaborators(pull_request, access_token) do
    resp = api.collaborators(access_token, pull_request)
    {:ok, resp } = JSON.decode(resp)
    Enum.map(resp, get_user_login(&1))
  end

  defp contributors(pull_request, access_token) do
    resp = api.contributors(access_token, pull_request)
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

  defp api do
    Github.Api
  end
end

