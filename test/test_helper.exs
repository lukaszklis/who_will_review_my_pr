Dynamo.under_test(WhoWillReviewMyPr.Dynamo)
Dynamo.Loader.enable
ExUnit.start

defmodule WhoWillReviewMyPr.TestCase do
  use ExUnit.CaseTemplate

  # Enable code reloading on test cases
  setup do
    Dynamo.Loader.enable
    :ok
  end
end
