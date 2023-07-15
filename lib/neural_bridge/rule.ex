defmodule NeuralBridge.Rule do
  @moduledoc false
  import NeuralBridge.SanskritInterpreter
  defstruct [:id, :given, :then]
  require Logger

  defmodule Error do
    defexception [:message]
  end

  def new(id: id, given: given, then: then) when is_binary(given) and is_binary(then) do
    with {:ok, parsed_given} <- to_production(given),
         _ <- validate_given(parsed_given, given, id),
         {:ok, then} <-
           to_production(then) do
      %__MODULE__{id: id, given: parsed_given, then: then}
    end
  end

  def new(id: id, given: given, then: then) when is_binary(given) and is_function(then) do
    with {:ok, given_prod} <- to_production(given),
         _ <- validate_given(given_prod, given, id) do
      %__MODULE__{id: id, given: given_prod, then: then}
    end
  end

  defp validate_given(given, original_given, id) when is_list(given) do
    Enum.map(given, fn statement ->
      unless Retex.Protocol.AlphaNetwork.impl_for(statement) do
        line = Enum.find_index(given, fn element -> element == statement end)
        statement = String.split(original_given, "\n") |> Enum.at(line)
        {_, impls} = Retex.Protocol.AlphaNetwork.__protocol__(:impls)

        Logger.error("""
        Allowed facts in a given of a rule are: #{inspect(impls)}
        """)

        raise Error,
          message:
            "Invalid statement in the given of the rule id #{id} at line #{line + 1}: #{statement}"
      end
    end)
  end
end
