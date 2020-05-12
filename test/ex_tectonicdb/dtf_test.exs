defmodule ExTectonicdb.DtfTest do
  use ExUnit.Case

  test "converts to text" do
    row = %ExTectonicdb.Dtf{
      timestamp: 1_505_177_459.685,
      seq: 139_010,
      is_trade: true,
      is_bid: false,
      price: 0.0703620,
      size: 7.65064240
    }

    assert "1505177459.685, 139010, t, f, 0.070362, 7.6506424" = "#{row}"
  end
end
