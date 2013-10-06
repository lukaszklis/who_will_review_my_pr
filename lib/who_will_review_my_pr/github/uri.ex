
defmodule Github.Uri do
  def authorize(client_id, redirect_uri) do
    "https://github.com/login/oauth/authorize" <>
      "?client_id=#{client_id}&scope=repo" <>
      "&redirect_uri=#{URI.encode(redirect_uri)}"
  end

  def access_token(client_id, client_secret, code, redirect_uri) do
    "https://github.com/login/oauth/access_token" <>
      "?client_id=#{client_id}&client_secret=#{client_secret}" <>
      "&code=#{code}&redirect_uri=#{URI.encode(redirect_uri)}"
  end

  def user do
    "https://api.github.com/user"
  end

  def collaborators(owner, repo) do
    "https://api.github.com/repos/#{owner}/#{repo}/collaborators"
  end

  def contributors(owner, repo) do
    "https://api.github.com/repos/#{owner}/#{repo}/stats/contributors"
  end

  def comments(owner, repo, issue) do
    "https://api.github.com/repos/#{owner}/#{repo}/issues/#{issue}/comments"
  end
end

