defmodule BmupTest do
  use ExUnit.Case
  doctest Bmup

  test "greets the world" do
    assert Bmup.hello() == :world
  end
end
