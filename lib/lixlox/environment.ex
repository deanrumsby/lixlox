defmodule LixLox.Environment do
  @moduledoc """
  An environment for code execution
  """

  defstruct [:scope, :outer]

  @type t :: %__MODULE__{scope: map(), outer: t()}

  def new(outer \\ nil) do
    %LixLox.Environment{scope: %{}, outer: outer}
  end

  def init(env, identifier, value \\ nil),
    do: %{env | scope: Map.put(env.scope, identifier, value)}

  def get(env, identifier) when is_map_key(env.scope, identifier),
    do: {:ok, env.scope[identifier]}

  def get(env, identifier) when is_map(env.outer) do
    with true <- is_map_key(env.outer, identifier) do
      get(env.outer, identifier)
    end
  end

  def get(_env, identifier), do: {:error, "undefined variable: #{identifier}"}

  def update(env, identifier, value) when is_map_key(env.scope, identifier),
    do: {:ok, %{env | scope: Map.put(env.scope, identifier, value)}}

  def update(env, identifier, value) when is_map(env.outer) do
    with {:ok, outer} <- update(env.outer, identifier, value) do
      {:ok, %{env | outer: outer}}
    end
  end

  def update(_env, identifier, _value), do: {:error, "undefined variable: #{identifier}"}
end
