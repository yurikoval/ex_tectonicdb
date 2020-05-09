defmodule ExTectonicdb.ConnectionTest do
  use ExUnit.Case

  test "opens connection" do
    config = %ExTectonicdb.Config{host: {127, 0, 0, 1}, port: 9001}
    start_supervised!({ExTectonicdb.Connection, config: config, name: __MODULE__})

    state =
      __MODULE__
      |> Process.whereis()
      |> :sys.get_state()

    assert state.config.host == config.host
    assert state.config.port == config.port
    assert !!state.socket, "client property is set after connection"
  end
end
