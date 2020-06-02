# BroadwayEctoJob

An EctoJob connector for [Broadway](https://github.com/dashbitco/broadway).
For more details on EctoJob see [this repo](https://github.com/mbuhot/ecto_job).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `broadway_ecto_job` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:broadway_ecto_job, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/broadway_ecto_job](https://hexdocs.pm/broadway_ecto_job).

## Usage

Configure Broadway with one or more producers using `BroadwayEctoJob.Producer`:

```elixir
config = EctoJob.Config.new(
  repo: MyRepo,
  schema: MyEctoJobQueue
)

Broadway.start_link(MyBroadway,
  name: MyBroadway,
  producer: [
    module: {BroadwayEctoJob.Producer, config}
  ]
)
```
