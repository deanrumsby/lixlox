defmodule LixLox.File do
  @moduledoc """
  Interprets a Lox source file
  """

  alias LixLox.Parser
  alias LixLox.Interpreter

  def run(args) do
    input = List.first(args) |> File.read!()

    case Parser.parse(input) do
      {:ok, statements, _rest} ->
        statements
        |> Enum.reduce(%{}, &(Interpreter.interpret(&1, &2) |> elem(1)))

      {:error, reason} ->
        IO.puts(reason)
    end
  end
end
