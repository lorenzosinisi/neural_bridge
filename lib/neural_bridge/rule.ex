defmodule NeuralBridge.Rule do
  import NeuralBridge.SanskritInterpreter
  defstruct [:id, :given, :then]

  def new(id: id, given: given, then: then) when is_binary(given) and is_binary(then) do
    with {:ok, given} <- to_production(given),
         {:ok, then} <- to_production(then) do
      %__MODULE__{id: id, given: given, then: then}
    end
  end

  def new(id: id, given: given, then: then) when is_binary(given) and is_function(then) do
    with {:ok, given} <- to_production(given) do
      %__MODULE__{id: id, given: given, then: then}
    end
  end
end
