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
    @type t :: %State{
            socket: socket,
            config: config,
            queue: :queue.queue()
          }

    @enforce_keys ~w[config queue]a
    defstruct ~w[config socket queue]a
  end

  def send_message(pid, message) do
    GenServer.call(pid, {:message, message})
  end

  def start_link(args \\ []) do
    state = %State{
      config: Keyword.get(args, :config, %ExTectonicdb.Config{}),
      queue: :queue.new()
    }

    opts = Keyword.take(args, [:name])
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    {:ok, state, {:continue, :connect}}
  end

  def handle_continue(:connect, %{config: config} = state) do
    Logger.info("Connecting to #{:inet.ntoa(config.host)}:#{config.port}")

    case :gen_tcp.connect(config.host, config.port, packet: :raw, active: true) do
      {:ok, socket} ->
        {:noreply, %{state | socket: socket}}

      {:error, reason} ->
        disconnect(state, reason)
    end
  end

  def handle_info({:tcp, socket, [success_bit | data]}, %{socket: socket} = state) do
    {{:value, from}, new_queue} = :queue.out(state.queue)
    msg = from_packet(data)

    if success_bit == 1 do
      GenServer.reply(from, {:ok, msg})
    else
      GenServer.reply(from, {:error, msg})
    end

    {:noreply, %{state | queue: new_queue}}
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
    Logger.info("Disconnected: #{reason}")
    {:stop, :normal, state}
  end

  @packet_endian 32

  defp to_packet(msg) do
    size = byte_size(msg)
    :binary.bin_to_list(<<size::@packet_endian, msg::binary>>)
  end

  defp from_packet(packet) do
    <<_size::@packet_endian*2, msg::binary>> = :binary.list_to_bin(packet)
    msg
  end
end
