defmodule Purl.Example do
  defstruct api_key: nil, job_id: nil
  use Purl,
    entry_chain: handshake,
    stanzas: Purl.Example.Stanzas

  def init(state), do: state

  proto :handshake,
    accepting: :hello,
    timeout: 1000,
    does: [
      on(:start_v1, switch_proto: :v1_auth)
    ]

  proto :v1_auth,
    accepting: :apikey,
    timeout: 1000,
    does: [
      on(:no_such_api_key,
      [
        reponse: [:error, <<"no such key">>],
        terminate: true
      ]),

      on(:ready, switch_proto: :v1_init_job)
    ]

  proto :v1_init_job,
    accepting: :job_id,
    timeout: 1000,
    does: [
      on(:no_such_job_id,
      [
        response: [:error, <<"no such job">>],
        terminate: true
      ]),

      on(:ready, switch_proto: :v1_main)
    ]

  proto :v1_main,
    processing: :run_job,
    accepting: [:abort, :client_info_json, :client_info_etf],
    does: [
      on(:job_done, [terminate: true]),
      on(:abort, [terminate: true]),
      on(:job_msg, [response: [:info, data.message]]),
      on(:received_info, [log: {:debug, msg}])
    ]
end
