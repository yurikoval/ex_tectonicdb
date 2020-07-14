defmodule ExTectonicdb.DtfTest do
  use ExUnit.Case

  setup do
    row = %ExTectonicdb.Dtf{
      timestamp: 1_505_177_459.685,
      seq: 139_010,
      is_trade: true,
      is_bid: false,
      price: 0.0703620,
      size: 7.65064240
    }

    [row: row]
  end

  test "converts to text", %{row: row} do
    assert "1505177459.685, 139010, t, f, 0.07036200, 7.65064240" = "#{row}"
  end

  test "formats floats correctly", %{row: r} do
    row = %{r | price: 1000.0}
    assert "1505177459.685, 139010, t, f, 1000.00000000, 7.65064240" = "#{row}"
  end
end
