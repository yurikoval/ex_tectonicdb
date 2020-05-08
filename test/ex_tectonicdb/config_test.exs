defmodule ExTectonicdb.ConfigTest do
  use ExUnit.Case
  alias ExTectonicdb.Config
  doctest Config

  test "default values" do
    assert %{host: {127, 0, 0, 1}, port: 9001} = %Config{}
  end
end
