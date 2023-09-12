defmodule WTPTest do
  use ExUnit.Case
  doctest WTP

  test "greets the world" do
    assert WTP.hello() == :world
  end
end
