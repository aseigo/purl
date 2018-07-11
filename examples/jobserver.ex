defmodule PleiadesWebapi.Storage.Job.Listener do
  use Purl, entry_chain: handshake

  def new_state(), do %{auth: false, id: nil}

  chain handshake(timeout: 1000, entry_loop: init) do
    loop init <<0xFF, 0x01>>, do: switch_to_chain(v1)
  end

  chain v1(timeout: 1000, entry_loop: auth) do
    loop auth,
      type: :chunk,
      end_token: <<0>>,
      handler: :verify_key
    do
      :no_such_key ->
        send_to_client(<<0xFF, "no such key", 0>>)
        :terminate

      :default -> :set_job
    end

    loop set_job,
      type: :chunk,
      end_token: <<0>>,
      handler: :verify_job_id
    do
      :no_such_job ->
        send_to_client(<<0xFF, "no such job", 0>>)
        :terminate

      :default -> :run_job
    end

    loop run_job,
      type: :send,
      timeout: :infinite,
      handler: :exec
    do
      :done -> :terminate

      msg ->
        send_to_client(msg)
        :run_job
    end
  end

  def verify_key(api_key, state) do
    if PleiadesWebapi.Storage.Apikey.exists?(api_key) do
      %{state | auth: true}
    else
      :no_such_key
    end
  end

  def verify_job_id(job_id, state) do
    case PleiadesWebapi.Storage.Jobs.get(job_id) do
      nil -> :no_such_job
      job -> Map.put(state, :job, job)
    end
  end

  def run_job(%{done: true} = state) do
    :terminate
  end

  def run_job(state) do
    {<<0x01, "holymoly", 0>>, Map.put(state, :done, true)}
  end
end
