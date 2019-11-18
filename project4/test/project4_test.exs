defmodule Project4Test do
  use ExUnit.Case
  doctest Project4

  test "HEY #ME #WHAT #NO @adv @ait @sup whatt?" do
    assert Project4.main("HEY #ME #WHAT #NO @adv @ait @sup whatt?") == [
      "HEY #ME #WHAT #NO @adv @ait @sup whatt?",
      ["ME", "WHAT", "NO"],
      ["adv", "ait", "sup"]
    ]
  end
end
