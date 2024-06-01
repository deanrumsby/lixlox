defmodule LixLox.Environment do
  @moduledoc """
  An environment for code execution
  """

  defstruct [:scope, :outer]

  @type t :: %__MODULE__{scope: map(), outer: t() | nil}

  def new(outer \\ nil) do
    %__MODULE__{scope: %{}, outer: outer}
  end

  def return(env)

  def return(%__MODULE__{outer: outer}) when is_map(outer),
    do: {:ok, %__MODULE__{scope: outer.scope, outer: outer.outer}}

  def return(_env), do: {:error, "no outer scope to return to"}

  def init(env, identifier, value \\ nil),
    do: %{env | scope: Map.put(env.scope, identifier, value)}

  def get(env, identifier) when is_map_key(env.scope, identifier),
    do: {:ok, env.scope[identifier]}

  def get(env, identifier) when is_map(env.outer), do: get(env.outer, identifier)      
  

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
