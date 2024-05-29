defmodule LixLox.Repl do
  @moduledoc """
  A [R]ead [E]valuate [P]rint [L]oop for the Lox programming language.
  """

  @prompt "lixlox> "

  @doc """
  Starts a REPL.
  """
  def loop() do
    input = IO.gets(@prompt)
    IO.puts(input)
    loop()
  end
end
