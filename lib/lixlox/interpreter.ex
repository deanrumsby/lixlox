defmodule LixLox.Interpreter do
  @moduledoc """
  An interpreter for the Lox language
  """

  alias LixLox.Parser
  alias LixLox.Environment

  @doc """
  Interprets a Lox abstract syntax tree.

  ## Example
    iex> LixLox.Interpreter.interpret([{:print {:add, {:literal, "hello"}, {:literal, ", world!"}}}])
    "hello, world!"
  """
  @spec interpret(list(Parser.ast()), Environment.t()) ::
          {:ok, Environment.t()} | {:error, String.t()}
  def interpret(statements, env \\ Environment.new()) do
    statements
    |> Enum.reduce_while({:ok, env}, fn ast, acc ->
      {:ok, env} = acc

      case run(ast, env) do
        {:ok, _value, env} -> {:cont, {:ok, env}}
        {:error, message} -> {:halt, {:error, message}}
      end
    end)
  end

  defp run(ast, env)
  defp run({:literal, value}, env), do: {:ok, value, env}

  defp run({:identifier, a}, env) do
    with {:ok, value} <- Environment.get(env, a) do
      {:ok, value, env}
    end
  end

  defp run({:block, block}, env) do
    with {:ok, env} <- interpret(block, Environment.new(env)),
         {:ok, env} <- Environment.return(env) do
      {:ok, nil, env}
    end
  end

  defp run({:if, expression, statement, nil}, env) do
    with {:ok, true, env} <- run(expression, env),
         {:ok, value, env} <- run(statement, env) do
      {:ok, value, env}
    end
  end

  defp run({:if, expression, _statement, else_statement}, env) do
    with {:ok, false, env} <- run(expression, env),
         {:ok, value, env} <- run(else_statement, env) do
      {:ok, value, env}
    end
  end

  defp run({:define, {:identifier, identifer}, a}, env) do
    with {:ok, value, env} <- run(a, env) do
      {:ok, value, define(identifer, value, env)}
    end
  end

  defp run({:assign, {:identifier, identifier}, a}, env) do
    with {:ok, value, env} <- run(a, env),
         {:ok, env} <- assign(identifier, value, env) do
      {:ok, value, env}
    end
  end

  defp run({:print, a}, env) do
    with {:ok, value, env} <- run(a, env) do
      print(value)
      {:ok, nil, env}
    end
  end

  defp run({:minus, a}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, value} <- minus(a) do
      {:ok, value, env}
    end
  end

  defp run({:not, a}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, value} <- bang(a) do
      {:ok, value, env}
    end
  end

  defp run({:divide, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env),
         {:ok, value} <- divide(a, b) do
      {:ok, value, env}
    end
  end

  defp run({:multiply, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env),
         {:ok, value} <- multiply(a, b) do
      {:ok, value, env}
    end
  end

  defp run({:subtract, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env),
         {:ok, value} <- subtract(a, b) do
      {:ok, value, env}
    end
  end

  defp run({:add, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env),
         {:ok, value} <- add(a, b) do
      {:ok, value, env}
    end
  end

  defp run({:greater, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env),
         {:ok, value} <- greater_than(a, b) do
      {:ok, value, env}
    end
  end

  defp run({:greater_equal, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env),
         {:ok, value} <- greater_than_equal(a, b) do
      {:ok, value, env}
    end
  end

  defp run({:less, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env),
         {:ok, value} <- less_than(a, b) do
      {:ok, value, env}
    end
  end

  defp run({:less_equal, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env),
         {:ok, value} <- less_than_equal(a, b) do
      {:ok, value, env}
    end
  end

  defp run({:equal, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env) do
      {:ok, equal(a, b), env}
    end
  end

  defp run({:not_equal, a, b}, env) do
    with {:ok, a, env} <- run(a, env),
         {:ok, b, env} <- run(b, env) do
      {:ok, not_equal(a, b), env}
    end
  end

  defp define(identifier, value, env) when is_atom(identifier),
    do: Environment.init(env, identifier, value)

  defp assign(identifier, value, env) when is_atom(identifier),
    do: Environment.update(env, identifier, value)

  defp print(a), do: IO.puts(a)

  defp minus(a) when is_number(a), do: {:ok, -1 * a}
  defp minus(_a), do: {:error, "minus error: unexpected type"}

  defp bang(a) when is_boolean(a), do: {:ok, !a}
  defp bang(_a), do: {:error, "not error: unexpected type"}

  defp divide(a, b) when is_number(a) and is_number(b), do: {:ok, a / b}
  defp divide(_a, _b), do: {:error, "divide error: unexpected type"}

  defp multiply(a, b) when is_number(a) and is_number(b), do: {:ok, a * b}
  defp multiply(_a, _b), do: {:error, "multiply error: unexpected type"}

  defp subtract(a, b) when is_number(a) and is_number(b), do: {:ok, a - b}
  defp subtract(_a, _b), do: {:error, "subtract error: unexpected type"}

  defp add(a, b) when is_number(a) and is_number(b), do: {:ok, a + b}
  defp add(a, b) when is_bitstring(a) and is_bitstring(b), do: {:ok, a <> b}
  defp add(_a, _b), do: {:error, "add error: unexpected type"}

  defp greater_than(a, b) when is_number(a) and is_number(b), do: {:ok, a > b}
  defp greater_than(_a, _b), do: {:error, "greater than error: unexpected type"}

  defp less_than(a, b) when is_number(a) and is_number(b), do: {:ok, a < b}
  defp less_than(_a, _b), do: {:error, "less than error: unexpected type"}

  defp greater_than_equal(a, b) when is_number(a) and is_number(b), do: {:ok, a >= b}
  defp greater_than_equal(_a, _b), do: {:error, "greater than equal error: unexpected type"}

  defp less_than_equal(a, b) when is_number(a) and is_number(b), do: {:ok, a <= b}
  defp less_than_equal(_a, _b), do: {:error, "less than equal error: unexpected type"}

  defp equal(a, b) when is_number(a) and is_number(b), do: a == b
  defp equal(a, b), do: a === b

  defp not_equal(a, b) when is_number(a) and is_number(b), do: a != b
  defp not_equal(a, b), do: a !== b
end
