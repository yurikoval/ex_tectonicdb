defmodule ExTectonicdb.Config do
  @moduledoc """
  Connection config
  """

  alias __MODULE__

  @type t :: %Config{
          host: String.t(),
          port: non_neg_integer,
          tcp_opts: [any]
        }

  defstruct host: {127, 0, 0, 1},
            port: 9001,
            tcp_opts: []
end
