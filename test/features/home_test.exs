# Feature tests go through the Dynamo.under_test
# and are meant to test the full stack.
defmodule HomeTest do
  use WhoWillReviewMyPr.TestCase
  use Dynamo.HTTP.Case

  test "redirects to /login" do
    conn = get("/")
    assert conn.resp_headers["location"] == "http://127.0.0.1/login"
    assert conn.status == 302
  end

  test "render login.html" do
    conn = get("/login")
    assert Regex.match?(%r/Login with GitHub/, conn.sent_body)
    assert conn.status == 200
  end

  test "/logout" do
    conn = get("/logout")
    assert conn.resp_headers["location"] == "http://127.0.0.1/login"
    assert conn.status == 302
  end

end
