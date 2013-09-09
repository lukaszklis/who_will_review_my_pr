defmodule ApplicationRouter do
  use Dynamo.Router

  prepare do
    # Pick which parts of the request you want to fetch
    # You can comment the line below if you don't need
    # any of them or move them to a forwarded router
    conn.fetch([:cookies, :params, :session])
    conn.assign(:title, "Who will review my PR?")
  end

  filter Dynamo.Filters.Session.new(
    Dynamo.Filters.Session.CookieStore,
    [key: "_who_will_review_my_pr", secret: String.duplicate(Config.secret, 8)])

  # It is common to break your Dynamo into many
  # routers, forwarding the requests between them:
  # forward "/posts", to: PostsRouter

  get "/" do
    conn = conn.fetch :session
    access_token = get_session(conn, :access_token)
    if access_token === nil or String.length(access_token) !== 40 do
      IO.puts("#### from request")
      redirect(conn, to: "/login")
    else
      IO.puts("#### from session:" <> access_token)
      user_name = Github.user(access_token)
      conn = conn.assign(:user_name, user_name)
      render conn, "index.html"
    end
  end

  post "/review" do
    conn = conn.fetch :session
    access_token = get_session(conn, :access_token)
    conn = conn.fetch :params
    pull_request = conn.params[:pull_request]
    conn = conn.assign(:pull_request, pull_request)
    reviewer = Github.random_reviewer(pull_request, access_token)
    conn = conn.assign(:reviewer_name, reviewer)
    Github.ask_to_review(pull_request, reviewer, access_token)
    render conn, "review.html"
  end

  get "/login" do
    conn = conn.assign(:github_oauth_uri, Github.oauth_uri)
    render conn, "login.html"
  end

  get "/logout" do
    conn = conn.fetch :session
    conn = put_session(conn, :access_token, nil)
    redirect(conn, to: "/login")
  end

  get "/authenticate" do
    conn = conn.fetch :session
    code = conn.fetch(:params).params[:code]
    access_token = Github.authenticate(code);
    conn = put_session(conn, :access_token, access_token)
    redirect(conn, to: "/")
  end
end

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
    Enum.take(Enum.shuffle(col),1)
  end

  def ask_to_review(pull_request, reviewer, access_token) do
    [_, _, _, owner, repo, _, number] = String.split(pull_request, "/")
    comment = "Hey @#{reviewer} would you have time to review this?"
    command = "curl -v -H 'Authorization: token #{access_token}' -XPOST https://api.github.com/repos/#{owner}/#{repo}/issues/#{number}/comments -d '{ \"body\": \"#{comment}\" }'"
    resp = System.cmd(command)
    IO.puts(resp)
    resp
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

