defmodule ApplicationRouter do
  use Dynamo.Router

  prepare do
    # Pick which parts of the request you want to fetch
    # You can comment the line below if you don't need
    # any of them or move them to a forwarded router
    conn = conn.fetch([:cookies, :params])
    conn = conn.assign(:title, "Who will review my PR?")
    conn
  end

  # It is common to break your Dynamo into many
  # routers, forwarding the requests between them:
  # forward "/posts", to: PostsRouter

  get "/" do
    conn = conn.fetch(:session)
    access_token = get_session(conn, :access_token)
    if access_token === nil or String.length(access_token) !== 40 do
      redirect(conn, to: "/login")
    else
      Logger.debug("#### from session:" <> access_token)
      user_name = Github.user(access_token)
      conn = conn.assign(:user_name, user_name)
      render conn, "index.html"
    end
  end

  post "/review" do
    conn = conn.fetch(:session)
    access_token = get_session(conn, :access_token)
    conn = conn.fetch :params
    pull_request = conn.params[:pull_request]
    conn = conn.assign(:pull_request, pull_request)
    reviewer = Github.random_reviewer(pull_request, access_token)
    Logger.debug(inspect(reviewer))
    conn = conn.assign(:reviewer_name, reviewer)
    Github.ask_to_review(pull_request, reviewer, access_token)
    render conn, "review.html"
  end

  get "/login" do
    conn = conn.assign(:github_oauth_uri, Github.oauth_uri)
    render conn, "login.html"
  end

  get "/logout" do
    conn = conn.fetch(:session)
    conn = put_session(conn, :access_token, nil)
    redirect(conn, to: "/login")
  end

  get "/authenticate" do
    conn = conn.fetch(:session)
    code = conn.fetch(:params).params[:code]
    access_token = Github.authenticate(code);
    conn = put_session(conn, :access_token, access_token)
    redirect(conn, to: "/")
  end
end
