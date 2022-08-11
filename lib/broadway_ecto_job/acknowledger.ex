defmodule BroadwayEctoJob.Acknowledger do
  @behaviour Broadway.Acknowledger
  alias EctoJob.JobQueue

  @impl true
  def ack(_ack_ref, successful, failed) do
    failed
    |> Enum.each(&mark_failed(&1))

    successful
    |> Enum.each(&delete_successful(&1))
  end

  defp mark_failed(message) do
    config = message.metadata[:config]

    JobQueue.job_failed(
      config[:repo],
      message.metadata[:job],
      DateTime.utc_now(),
      config[:retry_timeout]
    )
  end

  defp delete_successful(message) do
    config = message.metadata[:config]

    message.metadata[:job]
    |> JobQueue.initial_multi()
    |> config[:repo].transaction()
  end
end
