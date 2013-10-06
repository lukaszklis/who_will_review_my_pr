defmodule HTTP do
  # TODO: get rid of curl use ibrowse instead
  # https://github.com/cmullaparthi/ibrowse

  def post(uri) do
    System.cmd("curl -XPOST '#{uri}' 2>/dev/null")
  end

  def post(access_token, uri, request_body) do
    System.cmd("curl -H 'Authorization: token #{access_token}' -XPOST #{uri} -d '#{request_body}' 2> /dev/null")
  end

  def get(access_token, uri) do
    System.cmd("curl -H 'Authorization: token #{access_token}' -XGET '#{uri}' 2>/dev/null")
  end
end

