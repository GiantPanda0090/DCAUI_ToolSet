defmodule ACITest do
  use ExUnit.Case
  doctest ACI

  test "greets the world" do
    assert ACI.hello() == :world
  end
end
