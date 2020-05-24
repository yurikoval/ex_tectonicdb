# ExTectonicdb

![Elixir Test](https://github.com/yurikoval/ex_tectonicdb/workflows/Test/badge.svg)

[TectonicDB](https://github.com/0b01/tectonicdb) client library for Elixir to read/write L2 order book data

Documentation:

* [ex_tectonicdb](https://hexdocs.pm/ex_tectonicdb)
* [TectonicDB](https://docs.rs/crate/tectonicdb)

## Examples

```elixir
# open connection
{:ok, conn} = ExTectonicdb.start_link(host: {127, 0, 0, 1}, port: 9001)

# switch database
{:ok, _name} = ExTectonicdb.Commands.use_db(conn, "binance-btc_usdt")

# insert row
# ADD 1505177459.685, 139010, t, f, 0.0703620, 7.65064240;
row = %ExTectonicdb.Row{timestamp: 1505177459.685, sequence: 139010, is_trade: true, is_bid: false, price: 0.0703620, size: 7.65064240}
{:ok, row} = ExTectonicdb.Commands.add(conn, [row])

# INSERT 1505177459.685, 139010, t, f, 0.0703620, 7.65064240; INTO dbname
{:ok, row} = ExTectonicdb.Commands.insert_into(conn, "binance-btc_usdt", [row])
```

## Installation

The package can be installed by adding `ex_tectonicdb` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_tectonicdb, "~> 0.1.1"}
  ]
end
```

## Development / Test

To run tests, you must have `tectonicdb` running for tests to work. This can be done either by starting tectonicdb on port `9001` manually or running docker compose:

- `docker-compose up`
- Then, run the tests with `mix test`

## Authors

* Yuri Koval'ov - hello@yurikoval.com

## License

`ex_tectonicdb` is released under the [MIT license](./LICENSE.md)
