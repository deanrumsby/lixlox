defmodule LixLox.Interpreter do
  @moduledoc """
  An interpreter for the Lox language
  """

  @doc """
  Interprets a Lox abstract syntax tree.
  """
  @spec interpret(LixLox.Parser.ast(), map()) :: {LixLox.Parser.ast(), map()}
  def interpret(ast, env)

  def interpret({:literal, value}, env), do: {value, env}
  def interpret({:identifier, a}, env), do: {env[a], env}

  def interpret({:define, {:identifier, identifer}, a}, env) do
    {value, env} = interpret(a, env)
    {value, define(identifer, value, env)}
  end

  def interpret({:print, a}, env) do
    {value, env} = interpret(a, env)
    print(value)
    {nil, env}
  end

  def interpret({:minus, a}, env) do
    {a, env} = interpret(a, env)
    {minus(a), env}
  end

  def interpret({:not, a}, env) do
    {a, env} = interpret(a, env)
    {bang(a), env}
  end

  def interpret({:divide, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {divide(a, b), env}
  end

  def interpret({:multiply, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {multiply(a, b), env}
  end

  def interpret({:subtract, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {subtract(a, b), env}
  end

  def interpret({:add, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {add(a, b), env}
  end

  def interpret({:greater, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {greater_than(a, b), env}
  end

  def interpret({:greater_equal, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {greater_than_equal(a, b), env}
  end

  def interpret({:less, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {less_than(a, b), env}
  end

  def interpret({:less_equal, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {less_than_equal(a, b), env}
  end

  def interpret({:equal, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {equal(a, b), env}
  end

  def interpret({:not_equal, a, b}, env) do
    {a, env} = interpret(a, env)
    {b, env} = interpret(b, env)
    {not_equal(a, b), env}
  end

  defp define(identifier, value, env) when is_atom(identifier),
    do: Map.put(env, identifier, value)

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
