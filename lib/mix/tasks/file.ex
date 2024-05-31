defmodule Mix.Tasks.File do
  @moduledoc """
  Interprets a Lox source file
  """

  use Mix.Task
  alias LixLox.File

  @impl Mix.Task
  def run(args) do
    File.run(args)
  end
end
