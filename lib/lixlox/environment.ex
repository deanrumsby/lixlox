defmodule LixLox.Environment do
  @moduledoc """
  An environment for code execution, with functions for creating and returning
  from alternative scopes.
  """

  defstruct [:scope, :outer]

  alias LixLox.Parser

  @typedoc "The environment"
  @type t :: %__MODULE__{scope: map(), outer: t() | nil}

  @doc """
  Create a new environment. If an outer environment is provided this can 
  be considered as creating a new local scope.
  """
  @spec new(t() | nil) :: t()
  def new(outer \\ nil) do
    %__MODULE__{scope: %{}, outer: outer}
  end

  @doc """
  Return from a locally scoped environment. 
  Calling this without an outer scope available will return an error
  """
  @spec return(t()) :: {:ok, t()} | {:error, String.t()}
  def return(env)

  def return(%__MODULE__{outer: outer}) when is_map(outer),
    do: {:ok, %__MODULE__{scope: outer.scope, outer: outer.outer}}

  def return(_env), do: {:error, "no outer scope to return to"}

  @doc """
  Initialize a variable in the current scope
  """
  @spec init(t(), atom(), Parser.literal()) :: t()
  def init(env, identifier, value \\ nil),
    do: %{env | scope: Map.put(env.scope, identifier, value)}

  @doc """
  Fetch the value of an identifier.
  Starts by looking at the current scope, and then recursively checks 
  each enclosing scope. Returns an error if no lookup succeeds.
  """
  @spec get(t(), atom()) :: {:ok, Parser.literal()} | {:error, String.t()}
  def get(env, identifier) when is_map_key(env.scope, identifier),
    do: {:ok, env.scope[identifier]}

  def get(env, identifier) when is_map(env.outer), do: get(env.outer, identifier)      
  
  def get(_env, identifier), do: {:error, "undefined variable: #{identifier}"}

  @doc """
  Updates the value of a variable. If the variable is not found in the current
  scope it recursively searches the enclosing scopes until it is found. 
  Returns an error if the variable lookup does not succeed.
  """
  @spec update(t(), atom(), Parser.literal()) :: {:ok, t()} | {:error, String.t()}
  def update(env, identifier, value) when is_map_key(env.scope, identifier),
    do: {:ok, %{env | scope: Map.put(env.scope, identifier, value)}}

  def update(env, identifier, value) when is_map(env.outer) do
    with {:ok, outer} <- update(env.outer, identifier, value) do
      {:ok, %{env | outer: outer}}
    end
  end

  def update(_env, identifier, _value), do: {:error, "undefined variable: #{identifier}"}
end
