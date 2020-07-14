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

  def from_csv(str) do
    [timestamp, seq, is_trade, is_bid, price, size] = String.split(str, ",", trim: true)

    %Dtf{
      timestamp: to_float(timestamp),
      seq: to_int(seq),
      is_trade: boolean(is_trade),
      is_bid: boolean(is_bid),
      price: to_float(price),
      size: to_float(size)
    }
  end

  defp boolean("t"), do: true
  defp boolean(_), do: false

  defp to_float(v) do
    case Float.parse(v) do
      {f, _} -> f
      e -> e
    end
  end

  defp to_int(v) do
    case Integer.parse(v) do
      {i, _} -> i
      e -> e
    end
  end
end

defimpl String.Chars, for: ExTectonicdb.Dtf do
  def to_string(dtf) do
    ~w[timestamp seq is_trade is_bid price size]a
    |> Enum.map(fn r ->
      case Map.get(dtf, r) do
        true -> "t"
        false -> "f"
        e when is_float(e) and r in ~w(price size)a -> :erlang.float_to_binary(e, decimals: 8)
        e -> e
      end
    end)
    |> Enum.join(", ")
  end
end
