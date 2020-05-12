defmodule ExTectonicdb.Dtf do
  @moduledoc """
  Dense Tick Format
  """
  alias __MODULE__

  @type t :: %Dtf{
          timestamp: any,
          seq: any,
          is_trade: boolean,
          is_bid: boolean,
          price: any,
          size: any
        }

  @enforce_keys ~w[timestamp seq is_trade is_bid price size]a
  defstruct ~w[timestamp seq is_trade is_bid price size]a
end

defimpl String.Chars, for: ExTectonicdb.Dtf do
  def to_string(dtf) do
    ~w[timestamp seq is_trade is_bid price size]a
    |> Enum.map(fn r ->
      case Map.get(dtf, r) do
        true -> "t"
        false -> "f"
        e -> e
      end
    end)
    |> Enum.join(", ")
  end
end
