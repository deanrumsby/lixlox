defmodule LixLox.Repl do
  @moduledoc """
  A [R]ead [E]valuate [P]rint [L]oop for the Lox programming language.
  """

  alias LixLox.Parser
  alias LixLox.Interpreter

  @prompt "lixlox> "

  @doc """
  Starts a REPL.
  """
  def loop(env \\ %{}) do
    input = IO.gets(@prompt)

    case Parser.parse(input) do
      {:ok, statements, _rest} ->
        
        statements
        |> Enum.reduce(env, &elem(Interpreter.interpret(&1, &2), 1))
        |> loop()

      {:error, reason} ->
        IO.puts(reason)
        loop(env)
    end
  end
end
