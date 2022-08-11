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
  alias EctoJob.{Producer, JobQueue}
  alias Broadway.Message

  @impl true
  def init(config) do
    # TODO: come up with something better
    :erlang.put(:config, config)

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
       Postgrex.Notifications,
       [
         config[:repo].config() ++
           [name: notifier_name(config[:schema])]
       ]
     ], opts}
  end

  @impl true
  def handle_demand(demand, state) do
    {:noreply, jobs, new_state} = Producer.handle_demand(demand, state)
    {:noreply, wrap_jobs(jobs), new_state}
  end

  @impl true
  def handle_info(term, state) do
    {:noreply, jobs, new_state} = Producer.handle_info(term, state)
    {:noreply, wrap_jobs(jobs), new_state}
  end

  def mark_in_progress(message) do
    config = message.metadata[:config]

    {:ok, updated_job} =
      JobQueue.update_job_in_progress(
        config[:repo],
        message.metadata[:job],
        DateTime.utc_now(),
        config[:execution_timeout]
      )

    new_metadata = Keyword.put(message.metadata, :job, updated_job)
    %Message{message | metadata: new_metadata}
  end

  defp wrap_jobs([]), do: []

  defp wrap_jobs(jobs) do
    config = :erlang.get(:config)

    jobs
    |> Enum.map(fn job ->
      metadata = [
        # ?
        job: Map.delete(job, :params),
        config: config
      ]

      %Message{
        data: job.params,
        metadata: metadata,
        acknowledger: {BroadwayEctoJob.Acknowledger, :ack_ref, :ack_data}
      }
    end)
  end

  defp notifier_name(schema) do
    String.to_atom("#{schema}.Notifier")
  end
end
