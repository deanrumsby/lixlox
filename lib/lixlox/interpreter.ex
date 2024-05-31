defmodule LixLox.Interpreter do
  @moduledoc """
  An interpreter for the Lox language
  """

  def interpret(statement, env)
  def interpret({:define, identifer, a}, env), do: {nil, define(identifer, resolve(a, env), env)}

  def interpret({:print, a}, env) do
    print(resolve(a, env))
    {nil, env}
  end

  def interpret({:minus, a}, env), do: {minus(resolve(a, env)), env}
  def interpret({:not, a}, env), do: {bang(resolve(a, env)), env}
  def interpret({:divide, a, b}, env), do: {divide(resolve(a, env), resolve(b, env)), env}
  def interpret({:multiply, a, b}, env), do: {multiply(resolve(a, env), resolve(b, env)), env}
  def interpret({:subtract, a, b}, env), do: {subtract(resolve(a, env), resolve(b, env)), env}
  def interpret({:add, a, b}, env), do: {add(resolve(a, env), resolve(b, env)), env}
  def interpret({:greater, a, b}, env), do: {greater_than(resolve(a, env), resolve(b, env)), env}

  def interpret({:greater_equal, a, b}, env),
    do: {greater_than_equal(resolve(a, env), resolve(b, env)), env}

  def interpret({:less, a, b}, env), do: {less_than(resolve(a, env), resolve(b, env)), env}

  def interpret({:less_equal, a, b}, env),
    do: {less_than_equal(resolve(a, env), resolve(b, env)), env}

  def interpret({:equal, a, b}, env), do: {equal(resolve(a, env), resolve(b, env)), env}
  def interpret({:not_equal, a, b}, env), do: {not_equal(resolve(a, env), resolve(b, env)), env}
  def interpret(identifier, env) when is_atom(identifier), do: {env[identifier], env}
  def interpret(literal, env), do: {literal, env}

  defp resolve(expression, env) do
    expression
    |> interpret(env)
    |> elem(0)
  end

  defp define(identifier, value, env) do
    Map.put(env, identifier, value)
  end

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
