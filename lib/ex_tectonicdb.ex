defmodule ExTectonicdb do
  @moduledoc """
  TectonicDB Client for Elixir
  """
  alias ExTectonicdb.{Config, Connection}

  # Public API

  @doc """
  Open connection to the database server
  """
  @default_host {127, 0, 0, 1}
  @default_port 9001
  def start_link(args) do
    host = Keyword.get(args, :host, @default_host)
    port = Keyword.get(args, :port, @default_port)
    name = Keyword.get(args, :name)
    config = %Config{host: host, port: port}
    Connection.start_link(config: config, name: name)
  end
end
