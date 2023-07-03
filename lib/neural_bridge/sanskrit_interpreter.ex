defmodule NeuralBridge.SanskritInterpreter do
  import Retex.Facts

  @spec to_production(binary()) :: {:ok, list(Retex.Fact.t())} | {:error, any()}
  def to_production(conditions) when is_binary(conditions) do
    with {:ok, ast} <- parse(conditions) do
      {:ok, interpret(ast)}
    end
  end

  @spec to_production!(binary()) :: list(Retex.Fact.t())
  def to_production!(conditions) when is_binary(conditions) do
    {:ok, ast} = to_production(conditions)
    ast
  end

  defp parse(str) do
    Sanskrit.parse(str)
  end

  defp interpret(ast) when is_list(ast) do
    for node <- ast, do: do_interpret(node)
  end

  defp do_interpret({:filter, type, kind, value}) do
    filter(type, kind, value)
  end

  defp do_interpret({:not_existing_attribute, type, attr}) do
    not_existing_attribute(type, attr)
  end

  defp do_interpret({:negation, variable, type}) do
    is_not(variable, type)
  end

  defp do_interpret({:wme, type, attr, value}) do
    Retex.Wme.new(type, attr, value)
  end

  defp do_interpret({:isa, var, type}) do
    isa(var, type)
  end

  defp do_interpret({:has_attribute, type, attr, kind, value}) do
    has_attribute(type, attr, kind, value)
  end
end
