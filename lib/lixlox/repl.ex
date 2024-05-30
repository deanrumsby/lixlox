defmodule LixLox.Repl do
  @moduledoc """
  A [R]ead [E]valuate [P]rint [L]oop for the Lox programming language.
  """

  alias LixLox.Parser

  @prompt "lixlox> "

  @doc """
  Starts a REPL.
  """
  def loop() do
    IO.gets(@prompt)
    |> Parser.parse()
    |> IO.puts()
    loop()
  end
end
