defmodule LoggerTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  test "debug" do
    assert capture_io(fn ->
      Logger.debug("msg")
    end) == "msg\n"
  end
end

