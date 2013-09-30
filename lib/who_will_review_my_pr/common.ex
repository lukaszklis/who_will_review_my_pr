defmodule Common do

  def shuffle(list) do
    # To avoid Enum.shuffle to return one and the same result
    :random.seed(:erlang.now)

    Enum.shuffle(list)
  end

  def members_of_both(list1, list2) do
    [shorter, longer] = if ListDict.size(list1) < ListDict.size(list2), do: [list1,list2], else: [list2,list1]
    Enum.filter(shorter, fn(x) -> Enum.member?(longer, x) end)
  end

end
