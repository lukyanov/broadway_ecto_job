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
defmodule MyBroadway do
  use Broadway
  
  def start_link(_opts) do
    config =
      EctoJob.Config.new(
        repo: MyRepo,
        schema: MyEctoJobQueue
      )
      |> Map.to_list()

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwayEctoJob.Producer, config},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: 1]
      ]
    )
  end

  @impl true
  def handle_message(:default, message, _context) do
    message = BroadwayEctoJob.Producer.mark_in_progress(message)

    // handle the message here
  end
end
```


