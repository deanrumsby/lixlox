defmodule LixLox.Interpreter do
  @moduledoc """
  An interpreter for the Lox language
  """

  def interpret(ast)
  def interpret({:print, a}), do: print(interpret(a))
  def interpret({:minus, a}), do: minus(interpret(a))
  def interpret({:not, a}), do: bang(interpret(a))
  def interpret({:divide, a, b}), do: divide(interpret(a), interpret(b))
  def interpret({:multiply, a, b}), do: multiply(interpret(a), interpret(b))
  def interpret({:subtract, a, b}), do: subtract(interpret(a), interpret(b))
  def interpret({:add, a, b}), do: add(interpret(a), interpret(b))
  def interpret({:greater, a, b}), do: greater_than(interpret(a), interpret(b))
  def interpret({:greater_equal, a, b}), do: greater_than_equal(interpret(a), interpret(b))
  def interpret({:less, a, b}), do: less_than(interpret(a), interpret(b))
  def interpret({:less_equal, a, b}), do: less_than_equal(interpret(a), interpret(b))
  def interpret({:equal, a, b}), do: equal(interpret(a), interpret(b))
  def interpret({:not_equal, a, b}), do: not_equal(interpret(a), interpret(b))
  def interpret(literal), do: literal

  defp print(a), do: IO.puts(a)

  defp minus(a) when is_number(a), do: -1 * a
  defp minus(_a), do: "minus error: unexpted type"

  defp bang(a) when is_boolean(a), do: !a
  defp bang(_a), do: "not error: unexpected type"

  defp divide(a, b) when is_number(a) and is_number(b), do: a / b
  defp divide(_a, _b), do: "divide error: unexpected type"

  defp multiply(a, b) when is_number(a) and is_number(b), do: a * b
  defp multiply(_a, _b), do: "multiply error: unexpected type"

  defp subtract(a, b) when is_number(a) and is_number(b), do: a - b
  defp subtract(_a, _b), do: "subtract error: unexpected type"

  defp add(a, b) when is_number(a) and is_number(b), do: a + b
  defp add(a, b) when is_bitstring(a) and is_bitstring(b), do: a <> b
  defp add(_a, _b), do: "add error: unexpected type"

  defp greater_than(a, b) when is_number(a) and is_number(b), do: a > b
  defp greater_than(_a, _b), do: "greater than error: unexpected type"

  defp less_than(a, b) when is_number(a) and is_number(b), do: a < b
  defp less_than(_a, _b), do: "less than error: unexpected type"

  defp greater_than_equal(a, b) when is_number(a) and is_number(b), do: a >= b
  defp greater_than_equal(_a, _b), do: "greater than equal error: unexpected type"

  defp less_than_equal(a, b) when is_number(a) and is_number(b), do: a <= b
  defp less_than_equal(_a, _b), do: "less than equal error: unexpected type"

  defp equal(a, b) when is_number(a) and is_number(b), do: a == b
  defp equal(a, b), do: a === b

  defp not_equal(a, b) when is_number(a) and is_number(b), do: a != b
  defp not_equal(a, b), do: a !== b
end
