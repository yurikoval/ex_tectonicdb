defmodule ExTectonicdb.Info do
  @moduledoc """
  Info struct
  """

  defmodule Database do
    @derive Jason.Encoder
    @type t :: %Database{
            count: non_neg_integer,
            in_memory: non_neg_integer,
            name: String.t()
          }
    defstruct ~w(count in_memory name)a
  end

  defmodule Meta do
    @derive Jason.Encoder
    @type t :: %Meta{
            autoflush_enabled: boolean,
            autoflush_interval: non_neg_integer,
            clis: non_neg_integer,
            dtf_folder: String.t(),
            subs: non_neg_integer,
            total_count: non_neg_integer,
            total_in_memory_count: non_neg_integer,
            ts: non_neg_integer
          }

    defstruct ~w(
      autoflush_enabled
      autoflush_interval
      clis
      dtf_folder
      subs
      total_count
      total_in_memory_count
      ts
    )a
  end

  alias __MODULE__

  @derive Jason.Encoder
  @type t :: %Info{
          dbs: list(Database.t()),
          meta: Meta.t()
        }

  defstruct ~w(dbs meta)a

  def from_json!(j) do
    dbs = Enum.map(Map.fetch!(j, :dbs), &struct!(Database, &1))
    meta = struct!(Meta, Map.fetch!(j, :meta))
    {:ok, struct!(Info, %{dbs: dbs, meta: meta})}
  end
end
