defmodule BroadwayEctoJob.Acknowledger do
  @behaviour Broadway.Acknowledger
  alias EctoJob.JobQueue
  alias Broadway.Message

  @impl true
  def ack(_ack_ref, successful, failed) do
    failed
    |> Enum.each(&mark_failed(&1))

    successful
    |> Enum.each(&delete_successful(&1))
  end

  defp mark_failed(message) do
    %Message{acknowledger: {_, _, config_ref}} = message
    config = Broadway.TermStorage.get!(config_ref)
    JobQueue.job_failed(config[:repo], message.data, DateTime.utc_now(), config[:retry_timeout])
  end

  defp delete_successful(message) do
    %Message{acknowledger: {_, _, config_ref}} = message
    config = Broadway.TermStorage.get!(config_ref)

    message.data
    |> JobQueue.initial_multi()
    |> config[:repo].transaction()
  end
end
