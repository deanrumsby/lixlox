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
  def loop() do
    input = IO.gets(@prompt)

    with {:ok, ast, _rest} <- Parser.parse(input) do
      ast
      |> Interpreter.interpret()
      |> to_string()
      |> IO.puts()
    end

    loop()
  end
end
