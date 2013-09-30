defmodule CommonTest do
  use ExUnit.Case

  test "shuffle returns elemenst in different order" do
    list = ["red", "blue", "green"]
    assert [list, list, list] != [Common.shuffle(list), Common.shuffle(list), Common.shuffle(list)]
  end

  test "number_of_both returns elements that are members of both given lists" do
    assert Common.members_of_both(
      ["car","cat","carpet"],
      ["car","plain"]
    ) == ["car"]
  end

end
