defmodule Purl.Example do
  defstruct api_key: nil, job_id: nil

  use Purl,
    entry_chain: handshake,
    stanzas: Purl.Example.Stanzas

  def init(state), do: state

  proto handshake(accepting: :hello, timeout: 1000) do
    on :start_v1,
      switch_proto: v1_auth
  end

  proto v1_auth(accepting: :apikey, timeout: 1000) do
    on :no_such_api_key,
      reponse: [:error, <<"no such key">>],
      terminate: true

    on :ready,
      switch_proto: :v1_init_job
  end

  proto v1_init_job(accepting: :job_id, timeout: 1000) do
    on :no_such_job_id,
      response: [:error, <<"no such job">>],
      terminate: true

    on :ready,
      switch_proto: :v1_main
  end

  proto v1_main(processing: :run_job, accepting: [:terminate, :client_info_json, :client_info_etf]) do
    on :job_done,
      terminate: true

    on :job_msg,
      response: [:info, data.message]
  end
end
