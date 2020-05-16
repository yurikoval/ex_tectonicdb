defmodule ExTectonicdb.Commands do
  @moduledoc """
  Execture remote commands and receive results
  """

  alias ExTectonicdb.{Connection, Info}

  @type connection :: pid
  @type db_name :: String.t()
  @type row :: ExTectonicdb.Dtf.t()

  # Public API

  @doc """
  Add record to current database

  `ADD [ts], [seq], [is_trade], [is_bid], [price], [size];`

  Examples:

  iex> row = %ExTectonicdb.Dtf{timestamp: 1505177459.685, seq: 139010, is_trade: true, is_bid: false, price: 0.0703620, size: 7.65064240}
  iex> {:ok, conn} = ExTectonicdb.Connection.start_link()
  iex> ExTectonicdb.Commands.add(conn, row)
  {:ok, %ExTectonicdb.Dtf{timestamp: 1505177459.685, seq: 139010, is_trade: true, is_bid: false, price: 0.0703620, size: 7.65064240}}
  """
  @spec add(connection, row) :: {:ok, row} | {:error, :db_not_found}
  def add(conn, row) do
    case Connection.send_message(conn, "ADD #{row};") do
      {:ok, ""} -> {:ok, row}
      {:error, "ERR: No db named" <> _} -> {:error, :db_not_found}
      e -> e
    end
  end

  @doc """
  Create database

  `CREATE database`

  Examples:

  iex> {:ok, conn} = ExTectonicdb.Connection.start_link()
  iex> ExTectonicdb.Commands.create(conn, "my_new_db")
  {:ok, "my_new_db"}
  """
  @spec create(connection, db_name) :: {:ok, db_name} | {:error, :db_not_found}
  def create(conn, db) do
    case Connection.send_message(conn, "CREATE #{db}") do
      {:ok, _} -> {:ok, db}
      e -> e
    end
  end

  @doc """
  Checks if orderbook exists

  `EXISTS [orderbook]`

  Examples:

  iex> {:ok, conn} = ExTectonicdb.Connection.start_link()
  iex> ExTectonicdb.Commands.exists?(conn, "default")
  {:ok, "default"}
  iex> ExTectonicdb.Commands.exists?(conn, "new_db")
  {:error, :db_not_found}
  """
  @spec exists?(connection, db_name) :: {:ok, db_name} | {:error, :db_not_found}
  def exists?(conn, db) do
    case Connection.send_message(conn, "EXISTS #{db}") do
      {:ok, _} ->
        {:ok, db}

      {:error, "ERR: No db named" <> _} ->
        {:error, :db_not_found}

      e ->
        e
    end
  end

  @doc """
  Add record into a database

  `INSERT 1505177459.685, 139010, t, f, 0.0703620, 7.65064240; INTO dbname`

  Examples:

  iex> row = %ExTectonicdb.Dtf{timestamp: 1505177459.685, seq: 139010, is_trade: true, is_bid: false, price: 0.0703620, size: 7.65064240}
  iex> {:ok, conn} = ExTectonicdb.Connection.start_link()
  iex> ExTectonicdb.Commands.insert_into(conn, row, "default")
  {:ok, %ExTectonicdb.Dtf{timestamp: 1505177459.685, seq: 139010, is_trade: true, is_bid: false, price: 0.0703620, size: 7.65064240}, "default"}
  iex> ExTectonicdb.Commands.insert_into(conn, row, "i-dont-exist")
  {:error, :db_not_found}
  """
  @spec insert_into(connection, row, db_name) :: {:ok, row, String.t()} | {:error, :db_not_found}
  def insert_into(conn, row, db) do
    case Connection.send_message(conn, "INSERT #{row}; INTO #{db}") do
      {:ok, ""} -> {:ok, row, db}
      {:error, "ERR: DB" <> _} -> {:error, :db_not_found}
      e -> e
    end
  end

  @doc """
  `INFO`
  """
  @spec info(connection) :: {:ok, :pong} | {:error, any}
  def info(conn) do
    case Connection.send_message(conn, "INFO") do
      {:ok, resp} -> resp |> Jason.decode!(keys: :atoms!) |> Info.from_json!()
      e -> e
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
    case Connection.send_message(conn, "PING") do
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
  {:error, :db_not_found}
  """

  @spec use_db(connection, db_name) :: {:ok, db_name} | {:error, any}
  def use_db(conn, db) do
    case Connection.send_message(conn, "USE #{db}") do
      {:ok, "SWITCHED TO orderbook `" <> _} ->
        {:ok, db}

      {:error, "ERR: No db named" <> _} ->
        {:error, :db_not_found}

      e ->
        e
    end
  end
end
