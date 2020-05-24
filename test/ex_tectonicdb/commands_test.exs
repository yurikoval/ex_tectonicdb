defmodule ExTectonicdb.CommandsTest do
  use ExUnit.Case, async: false
  doctest ExTectonicdb.Commands

  setup do
    config = %ExTectonicdb.Config{}
    {:ok, conn} = ExTectonicdb.Connection.start_link(config: config)
    :ok = ExTectonicdb.Commands.clear(conn)
    {:ok, [conn: conn]}
  end

  describe ".info" do
    test "returns formatted struct", %{conn: conn} do
      assert {:ok,
              %ExTectonicdb.Info{
                dbs: [%ExTectonicdb.Info.Database{} | _],
                meta: %ExTectonicdb.Info.Meta{}
              }} = ExTectonicdb.Commands.info(conn)
    end
  end

  describe ".get_all" do
    test "returns formatted struct", %{conn: conn} do
      row = %ExTectonicdb.Dtf{
        timestamp: 1_505_177_459.685,
        seq: 139_010,
        is_trade: true,
        is_bid: false,
        price: 0.0703620,
        size: 7.65064240
      }

      for i <- 0..2, do: ExTectonicdb.Commands.add(conn, %{row | seq: row.seq + i})
      assert {:ok, [^row | _] = rows} = ExTectonicdb.Commands.get_all(conn)
      assert length(rows) == 3
    end
  end
end
