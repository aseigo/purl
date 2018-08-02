defmodule Purl.Example do
  defstruct api_key: nil, job_id: nil

  use Purl,
    entry_chain: handshake,
    stanzas: __MODULE__.Stanzas

  def init(state), do: state

  proto handshake(accepting: :init, timeout: 1000) do
    on :start_v1, switch_proto: v1_auth
  end

  proto v1_auth(accepting: :apikey, timeout: 1000) do
    on :no_such_api_key do
        response(:error, <<"no such key">>)
        :terminate
    end

    on :ready do, switch_proto: :v1_init_job
  end

  proto v1_init_job(accepting: :job_id, timeout: 1000) do
    on :no_such_job_id do
        response(:error, <<"no such job">>)
        :terminate
    end

    on :ready do, switch_proto: :v1_main
  end

  proto v1_main(processing: run_job, accepting: [:terminate, :client_info]) do
    on :job_set, do: :run_job

    on :job_done, do: :terminate

    on :job_msg do
      response(:info, data.message)
      :run_job
    end
  end
end
