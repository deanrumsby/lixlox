defmodule LixLox.Repl do
  @moduledoc """
  A [R]ead [E]valuate [P]rint [L]oop for the Lox programming language.
  """

  alias LixLox.Parser
  alias LixLox.Interpreter
  alias LixLox.Environment

  @prompt "lixlox> "

  @doc """
  Starts a REPL.
  """
  def loop(env \\ Environment.new()) do
    input = IO.gets(@prompt)

    with {:ok, statements, _rest} <- Parser.parse(input),
         {:ok, next_env} <- Interpreter.interpret(statements, env) do
      loop(next_env)
    else
      {:error, message} ->
        IO.puts(message)
        loop(env)
    end
  end
end
