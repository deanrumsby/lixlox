defmodule LixLox.Interpreter do
  @moduledoc """
  An interpreter for the Lox language
  """

  alias LixLox.Parser

  @doc """
  Interprets a Lox abstract syntax tree.

  ## Example
    iex> LixLox.Interpreter.interpret([{:print {:add, {:literal, "hello"}, {:literal, ", world!"}}}])
    "hello, world!"
  """
  @spec interpret(list(Parser.ast()), map()) :: map()
  def interpret(statements, env \\ %{}) do
    statements
    |> Enum.reduce(env, &run(&1, &2)
    |> elem(1))
  end

  defp run(ast, env)
  defp run({:literal, value}, env), do: {value, env}
  defp run({:identifier, a}, env), do: {env[a], env}

  defp run({:define, {:identifier, identifer}, a}, env) do
    {value, env} = run(a, env)
    {value, define(identifer, value, env)}
  end

  defp run({:print, a}, env) do
    {value, env} = run(a, env)
    print(value)
    {nil, env}
  end

  defp run({:minus, a}, env) do
    {a, env} = run(a, env)
    {minus(a), env}
  end

  defp run({:not, a}, env) do
    {a, env} = run(a, env)
    {bang(a), env}
  end

  defp run({:divide, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
    {divide(a, b), env}
  end

  defp run({:multiply, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
    {multiply(a, b), env}
  end

  defp run({:subtract, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
    {subtract(a, b), env}
  end

  defp run({:add, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
    {add(a, b), env}
  end

  defp run({:greater, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
    {greater_than(a, b), env}
  end

  defp run({:greater_equal, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
    {greater_than_equal(a, b), env}
  end

  defp run({:less, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
    {less_than(a, b), env}
  end

  defp run({:less_equal, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
    {less_than_equal(a, b), env}
  end

  defp run({:equal, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
    {equal(a, b), env}
  end

  defp run({:not_equal, a, b}, env) do
    {a, env} = run(a, env)
    {b, env} = run(b, env)
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
