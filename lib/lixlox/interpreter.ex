defmodule LixLox.Interpreter do
  @moduledoc """
  An interpreter for the Lox language
  """

  def interpret(ast)
  def interpret(literal) when is_number(literal), do: literal
  def interpret({:minus, a}), do: -1 * interpret(a)
  def interpret({:not, a}), do: not interpret(a)
  def interpret({:divide, a, b}), do: interpret(a) / interpret(b)
  def interpret({:multiply, a, b}), do: interpret(a) * interpret(b)
  def interpret({:subtract, a, b}), do: interpret(a) - interpret(b)
  def interpret({:add, a, b}), do: interpret(a) + interpret(b)
  def interpret({:greater, a, b}), do: interpret(a) > interpret(b)
  def interpret({:greater_equal, a, b}), do: interpret(a) >= interpret(b)
  def interpret({:less, a, b}), do: interpret(a) < interpret(b)
  def interpret({:less_equal, a, b}), do: interpret(a) <= interpret(b)
  def interpret({:equal, a, b}), do: interpret(a) == interpret(b)
  def interpret({:not_equal, a, b}), do: interpret(a) != interpret(b)
end
