defmodule Github do

  # TODO: get rid of curl

  def oauth_uri do
    # TODO: implement redirect_uri & state
    # http://developer.github.com/v3/oauth/#web-application-flow
    "https://github.com/login/oauth/authorize?client_id=#{Config.client_id}&scope=repo"
  end

  def authenticate(code) do
    client_id = Config.client_id
    client_secret = Config.client_secret
    command = "curl -XPOST 'https://github.com/login/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&code=#{code}' 2>/dev/null"
    response = System.cmd(command)
    Logger.debug(response)
    String.slice(response, 13, 40)
  end

  def user(access_token) do
    command = "curl -XGET https://api.github.com/user?access_token=#{access_token} 2> /dev/null"
    resp = System.cmd(command)
    {:ok, resp } = JSON.decode(resp)
    HashDict.get(resp, "login")
  end

  def random_reviewer(pull_request, access_token) do
    col = collaborators(pull_request, access_token)
    con = contributors(pull_request, access_token)
    if ListDict.size(con) == 0, do: con = contributors(pull_request, access_token)
    in_both = Cust.members_of_both(con, col)
    Logger.debug(inspect(in_both))
    shuffled = Cust.shuffle(in_both)
    Logger.debug(inspect(shuffled))
    Enum.take(shuffled,1)
  end

  def ask_to_review(pull_request, reviewer, access_token) do
    [_, _, _, owner, repo, _, number] = String.split(pull_request, "/")
    comment = "Hey @#{reviewer} would you have time to review this? [/®](http://who-will-review-my-pr.herokuapp.com)"
    command = "curl -H 'Authorization: token #{access_token}' -XPOST https://api.github.com/repos/#{owner}/#{repo}/issues/#{number}/comments -d '{ \"body\": \"#{comment}\" }' 2> /dev/null"
    resp = System.cmd(command)
    Logger.debug(resp)
    resp
  end

  defp collaborators(pull_request, access_token) do
    [_, _, _, owner, repo, _, _] = String.split(pull_request, "/")

    command = "curl -H 'Authorization: token #{access_token}' -XGET https://api.github.com/repos/#{owner}/#{repo}/collaborators 2> /dev/null"
    resp = System.cmd(command)
    {:ok, resp } = JSON.decode(resp)
    Enum.map(resp, get_user_login(&1))
  end

  defp contributors(pull_request, access_token) do
    [_, _, _, owner, repo, _, _] = String.split(pull_request, "/")
    command = "curl -H 'Authorization: token #{access_token}' -XGET https://api.github.com/repos/#{owner}/#{repo}/stats/contributors 2> /dev/null"
    resp = System.cmd(command)
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
