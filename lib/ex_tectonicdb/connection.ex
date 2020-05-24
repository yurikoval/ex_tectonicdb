defmodule ExTectonicdb.Connection do
  @moduledoc """
  Handles connection to the database socket

  `tdb-server` uses first bit in the reply to denote success/failure, so `:gen_tcp` needs to connect with `packet: :raw`.

  Incoming message format: 1 byte for success failure, 8 bytes big endian (64 bit) for length n, and n bytes for body
  Outgoing message format: 4 byte big endian for length n, and n bytes for body
  """

  require Logger
  use GenServer

  defmodule State do
    @type config :: ExTectonicdb.Config.t()
    @type socket :: :gen_tcp.socket()
    @type message_length :: non_neg_integer
    @type buffered_message :: list(non_neg_integer) | nil
    @type t :: %State{
            socket: socket,
            config: config,
            queue: :queue.queue(),
            buffer: {message_length, buffered_message}
          }

    @enforce_keys ~w[config buffer queue]a
    defstruct ~w[config buffer socket queue]a
  end

  def send_message(pid, message) do
    GenServer.call(pid, {:message, message})
  end

  def start_link(args \\ []) do
    state = %State{
      config: Keyword.get(args, :config, %ExTectonicdb.Config{}),
      queue: :queue.new(),
      buffer: {0, nil}
    }

    opts = Keyword.take(args, [:name])
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    {:ok, state, {:continue, :connect}}
  end

  def handle_continue(:connect, %{config: config} = state) do
    :ok = Logger.info("Connecting to #{:inet.ntoa(config.host)}:#{config.port}")

    case :gen_tcp.connect(
           config.host,
           config.port,
           Keyword.merge(config.tcp_opts, packet: :raw, active: true)
         ) do
      {:ok, socket} -> {:noreply, %{state | socket: socket}}
      {:error, reason} -> disconnect(state, reason)
    end
  end

  # start of new message
  def handle_info({:tcp, socket, data}, %{socket: socket, buffer: {0, _buf}} = state) do
    {:ok, [buffer: buffer_size]} = :inet.getopts(socket, [:buffer])
    {_success, _msg, msg_len} = from_packet(data)

    new_state =
      if msg_len < buffer_size do
        process_and_reply(state, data)
      else
        %{state | buffer: {msg_len, data}}
      end

    {:noreply, new_state}
  end

  # buffered message
  def handle_info({:tcp, socket, data}, %{socket: socket, buffer: {msg_len, buf}} = state) do
    agg_data = buf ++ data

    new_state =
      if length(agg_data) >= msg_len do
        process_and_reply(state, agg_data)
      else
        %{state | buffer: {msg_len, agg_data}}
      end

    {:noreply, new_state}
  end

  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}
  def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}

  def handle_call({:message, message}, from, %{socket: socket, queue: queue} = state) do
    # format message to binary and send over tcp
    packet = to_packet(message)
    :ok = :gen_tcp.send(socket, packet)

    # queue client for later reply
    q = :queue.in(from, queue)
    state = %{state | queue: q}
    {:noreply, state}
  end

  def disconnect(state, reason) do
    :ok = Logger.info("Disconnected: #{reason}")
    {:stop, :normal, state}
  end

  defp process_and_reply(state, data) do
    {{:value, from}, new_queue} = :queue.out(state.queue)
    {success, msg, _length} = from_packet(data)
    GenServer.reply(from, {success, msg})
    %{state | queue: new_queue, buffer: {0, nil}}
  end

  @send_length_byte_size 32
  defp to_packet(msg) do
    size = byte_size(msg)
    :binary.bin_to_list(<<size::@send_length_byte_size, msg::binary>>)
  end

  @recv_length_byte_size 64
  defp from_packet(packet) do
    case :binary.list_to_bin(packet) do
      <<1, len::@recv_length_byte_size, msg::binary>> -> {:ok, msg, len}
      <<0, len::@recv_length_byte_size, msg::binary>> -> {:error, msg, len}
    end
  end
end
