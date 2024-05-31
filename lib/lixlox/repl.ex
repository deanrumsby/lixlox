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

    case Parser.parse(input) do
      {:ok, ast, _rest} -> 
        ast
        |> Interpreter.interpret()
    
      {:error, reason} ->
        reason
        |> IO.puts()
    end

    loop()
  end
end
