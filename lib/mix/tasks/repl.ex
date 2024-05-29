defmodule Mix.Tasks.Repl do
  @moduledoc """
  Starts a REPL for LixLox
  """

  use Mix.Task
  alias LixLox.Repl

  @impl Mix.Task
  def run(_args) do
    Repl.loop()
  end
end
