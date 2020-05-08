defmodule ExTectonicdb.Connection do
  @moduledoc """
  Handles connection to the database socket
  """

  use GenServer

  defmodule State do
    @type config :: ExTectonicdb.Config.t()
    @type t :: %State{
            config: config
          }

    @enforce_keys ~w[config]a
    defstruct ~w[config]a
  end

  def start_link(args) do
    state = %State{
      config: Keyword.get(args, :config)
    }

    name = Keyword.get(args, :name, __MODULE__)

    GenServer.start_link(__MODULE__, state, name: name)
  end

  def init(state), do: {:ok, state, {:continue, :started}}

  def handle_continue(:started, state) do
    {:noreply, state}
  end
end
