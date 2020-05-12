defmodule ExTectonicdb.Commands do
  @moduledoc """
  Execture remote commands and receive results
  """

  alias ExTectonicdb.Connection, as: C
  @type connection :: pid
  @type db_name :: String.t()
  @type row :: map

  # Public API

  @doc """
  Checks if orderbook exists

  `EXISTS [orderbook]`

  Examples:

  iex> {:ok, conn} = ExTectonicdb.Connection.start_link()
  iex> ExTectonicdb.Commands.exists?(conn, "default")
  {:ok, "default"}
  iex> ExTectonicdb.Commands.exists?(conn, "new_db")
  {:error, :missing}
  """
  @spec exists?(connection, db_name) :: {:ok, db_name} | {:error, :missing}
  def exists?(conn, db) do
    case C.send_message(conn, "EXISTS #{db}") do
      {:ok, _} ->
        {:ok, db}

      {:error, "ERR: No db named" <> _} ->
        {:error, :missing}

      e ->
        e
    end
  end

  @doc """
  `PING`

  Examples:

  iex> {:ok, conn} = ExTectonicdb.Connection.start_link()
  iex> ExTectonicdb.Commands.ping(conn)
  {:ok, :pong}
  """
  @spec ping(connection) :: {:ok, :pong} | {:error, any}
  def ping(conn) do
    case C.send_message(conn, "PING") do
      {:ok, "PONG" <> _} -> {:ok, :pong}
      e -> e
    end
  end

  @doc """
  Switch databases

  Examples:

  iex> {:ok, conn} = ExTectonicdb.Connection.start_link()
  iex> ExTectonicdb.Commands.use_db(conn, "default")
  {:ok, "default"}
  iex> ExTectonicdb.Commands.use_db(conn, "my-db")
  {:error, :missing}
  """

  @spec use_db(connection, db_name) :: {:ok, db_name} | {:error, any}
  def use_db(conn, db) do
    case C.send_message(conn, "USE #{db}") do
      {:ok, "SWITCHED TO orderbook `" <> _} ->
        {:ok, db}

      {:error, "ERR: No db named" <> _} ->
        {:error, :missing}

      e ->
        e
    end
  end
end
