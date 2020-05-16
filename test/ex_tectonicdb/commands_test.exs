defmodule ExTectonicdb.CommandsTest do
  use ExUnit.Case, async: false
  doctest ExTectonicdb.Commands

  setup do
    {:ok, conn} = ExTectonicdb.Connection.start_link()
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
end
