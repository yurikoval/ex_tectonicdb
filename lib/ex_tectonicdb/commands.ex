defmodule ExTectonicdb.Commands do
  @moduledoc """
  Execture remote commands and receive results
  """

  alias ExTectonicdb.Connection, as: C
  @type connection :: pid
  @type db_name :: String.t()
  @type row :: map

  # Public API

  @spec add(connection, list(row)) :: {:ok, {db_name, list(row)}} | {:error, any}
  def add(conn, rows), do: GenServer.call(conn, :send_msg, [rows])

  @spec insert_into(connection, db_name, list(row)) :: {:ok, {db_name, list(row)}} | {:error, any}
  def insert_into(conn, db, rows), do: GenServer.call(conn, :send_msg, [db, rows])

  @spec use(connection, db_name) :: {:ok, db_name} | {:error, any}
  def use(conn, db), do: GenServer.call(conn, :send_msg, [db])
end
