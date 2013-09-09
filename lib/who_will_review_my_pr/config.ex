defmodule Config do
  def client_secret do
    System.get_env("GITHUB_CSECRET") || "the github secret"
  end

  def client_id do
    System.get_env("GITHUB_CID") || "the github client id"
  end

  def secret do
    System.get_env("APP_SECRET") || "application secret"
  end
end
