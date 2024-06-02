defmodule LixLoxTest do
  use ExUnit.Case
  doctest LixLox.Parser

  alias LixLox.Parser

  test "literals" do
    input = "5; 6.3; 9.0; nil; true; false; \"hello\";"
    result = Parser.parse(input)

    assert result ==
             {:ok,
              [
                {:literal, 5},
                {:literal, 6.3},
                {:literal, 9.0},
                {:literal, nil},
                {:literal, true},
                {:literal, false},
                {:literal, "hello"}
              ], ""}
  end

  test "sum" do
    input = "7 + 152;"
    result = Parser.parse(input)

    assert result == {:ok, [{:add, {:literal, 7}, {:literal, 152}}], ""}
  end

  test "operator precedence" do
    input = "2 * (5 + 3);"
    result = Parser.parse(input)

    assert result == {:ok, [{:multiply, {:literal, 2}, {:add, {:literal, 5}, {:literal, 3}}}], ""}

    input = "5 / -4;"
    result = Parser.parse(input)

    assert result == {:ok, [{:divide, {:literal, 5}, {:minus, {:literal, 4}}}], ""}
  end

  test "block scope" do
    input = "{ var test = 3; }"
    result = Parser.parse(input)

    assert result == {:ok, [{:block, [{:define, {:identifier, :test}, {:literal, 3}}]}], ""}
  end
end
