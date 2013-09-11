defmodule Config do
  def client_secret do
    System.get_env("GITHUB_CSECRET") || "the_github_secret"
  end

  def client_id do
    System.get_env("GITHUB_CID") || "the_github_client_id"
  end

  def secret do
    System.get_env("APP_SECRET") || "application_secret"
  end

  def root_url do
    System.get_env("ROOT_URL") || "localhost:4000"
  end
end
