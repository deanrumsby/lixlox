defmodule LixLoxTest do
  use ExUnit.Case
  doctest LixLox

  test "greets the world" do
    assert LixLox.hello() == :world
  end
end
