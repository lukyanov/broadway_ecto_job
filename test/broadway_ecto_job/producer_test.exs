defmodule BroadwayEctoJob.ProducerTest do
  use ExUnit.Case
  doctest BroadwayEctoJob.Producer

  test "greets the world" do
    assert BroadwayEctoJob.Producer.hello() == :world
  end
end
