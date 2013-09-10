defmodule Github do
  def oauth_uri do
    "https://github.com/login/oauth/authorize?client_id=#{Config.client_id}&scope=repo"
  end

  def authenticate(code) do
    client_id = Config.client_id
    client_secret = Config.client_secret
    command = "curl -XPOST 'https://github.com/login/oauth/access_token?client_id=#{client_id}&client_secret=#{client_secret}&code=#{code}' 2>/dev/null"
    response = System.cmd(command)
    IO.puts(response)
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
    in_both = members_of_both(con, col)
    Enum.take(Enum.shuffle(in_both),1)
  end

  def ask_to_review(pull_request, reviewer, access_token) do
    [_, _, _, owner, repo, _, number] = String.split(pull_request, "/")
    comment = "Hey @#{reviewer} would you have time to review this?"
    command = "curl -v -H 'Authorization: token #{access_token}' -XPOST https://api.github.com/repos/#{owner}/#{repo}/issues/#{number}/comments -d '{ \"body\": \"#{comment}\" }'"
    resp = System.cmd(command)
    IO.puts(resp)
    resp
  end

  defp members_of_both(list1, list2) do
    [shorter, longer] = if ListDict.size(list1) < ListDict.size(list2), do: [list1,list2], else: [list2,list1]
    Enum.filter(shorter, fn(x) -> Enum.member?(longer, x) end)
  end

  defp collaborators(pull_request, access_token) do
    [_, _, _, owner, repo, _, number] = String.split(pull_request, "/")
    command = "curl -H 'Authorization: token #{access_token}' -XGET https://api.github.com/repos/#{owner}/#{repo}/collaborators 2> /dev/null"
    resp = System.cmd(command)
    {:ok, resp } = JSON.decode(resp)
    Enum.map(resp, get_user_login(&1))
  end

  defp contributors(pull_request, access_token) do
    [_, _, _, owner, repo, _, number] = String.split(pull_request, "/")
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
