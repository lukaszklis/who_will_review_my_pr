defmodule GithubTest do
  use ExUnit.Case

  test "oauth_uri" do
    assert Github.oauth_uri == "https://github.com/login/oauth/authorize" <
      "?client_id=the_github_client_id&scope=repo"
  end
end
