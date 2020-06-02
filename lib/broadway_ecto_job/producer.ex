defmodule BroadwayEctoJob.Producer do
  @moduledoc """
  Documentation for BroadwayEctoJob.Producer.
  """

  @doc """
  Hello world.

  ## Examples

      iex> BroadwayEctoJob.Producer.hello()
      :world

  """
  use GenStage
  @behaviour Broadway.Producer
  alias EctoJob.Producer

  import Supervisor.Spec, only: [worker: 2]

  @impl true
  def init(config) do
    config_ref = Broadway.TermStorage.put(config)
    # TODO: come up with something better
    :erlang.put(:config_ref, config_ref)

    state = %Producer.State{
      repo: config[:repo],
      schema: config[:schema],
      notifier: Process.whereis(notifier_name(config[:schema])),
      demand: 0,
      clock: &DateTime.utc_now/0,
      poll_interval: config[:poll_interval],
      reservation_timeout: config[:reservation_timeout],
      execution_timeout: config[:execution_timeout],
      notifications_listen_timeout: config[:notifications_listen_timeout]
    }

    Producer.init(state)
  end

  @impl true
  def prepare_for_start(_module, opts) do
    {_module, config} = opts[:producer][:module]

    {[
       worker(Postgrex.Notifications, [
         config[:repo].config() ++
           [name: notifier_name(config[:schema])]
       ])
     ], opts}
  end

  @impl true
  def handle_demand(demand, state) do
    {:noreply, jobs, new_state} = Producer.handle_demand(demand, state)
    {:noreply, wrap_jobs(jobs, state), new_state}
  end

  @impl true
  def handle_info(term, state) do
    {:noreply, jobs, new_state} = Producer.handle_info(term, state)
    {:noreply, wrap_jobs(jobs, state), new_state}
  end

  defp wrap_jobs(jobs, state) do
    config_ref = :erlang.get(:config_ref)

    jobs
    |> Enum.map(fn job ->
      %Broadway.Message{
        data: job,
        # metadata: Map.delete(job, :params),
        acknowledger: {BroadwayEctoJob.Acknowledger, :ack_ref, config_ref}
      }
    end)
  end

  defp notifier_name(schema) do
    String.to_atom("#{schema}.Notifier")
  end
end
