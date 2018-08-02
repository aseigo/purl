defmodule Purl.Example do
  use Purl, entry_chain: handshake

  def new_state(), do %{api_key: nil, job_id: nil}

  accept init,
    type: :fixed_message,
    match: "HH",
    handler: fn -> :start_v1 end

  accept apikey,
    type: :fixed_size_message,
    size: 36,
    timeout: 1000,
    handler: :verify_key

  accept job_id,
    type: :terminated_buffer,
    end_token: <<0>>,
    timeout: 1000,
    handler: :verify_job_id

  accept terminate,
    type: :tagged_message,
    tag: "99",
    end_token: <<0>>,
    timeout: 1000,
    handler: :abort

  accept client_info,
    type: :tagged_varlength_message,
    tag: "40",
    max_size: 1024,
    handler: :client_message 

  process run_job,
    type: :send,
    timeout: :infinite,
    handler: :exec

  response error,
    type: :tagged_message,
    tag: "11",
    end_token: "\n"

  response info,
    type: :tagged_varlength_message,
    tag: "20"

  proto handshake(accepting: :init) do
    on :start_v1, switch_proto: v1_auth
  end

  proto v1_auth(accepting: :apikey) do
    on :no_such_api_key do
        respond(:error, <<"no such key">>)
        :terminate
    end

    on :ready do, switch_proto: :v1_init_job
  end

  proto v1_init_job(accepting: :job_id) do
    on :no_such_job_id do
        respond(:error, <<"no such job">>)
        :terminate
    end

    on :ready do, switch_proto: :v1_main
  end

  proto v1_main(processing: run_job, accepting: :client_info) do
    on :job_set, do: :run_job

    on :job_done, do: :terminate

    on :job_msg do
      respond(:info, data.message)
      :run_job
    end
  end

  def verify_key(api_key, state) do
    if api_key == "bbe9d0b1-d3d1-40a7-b1fe-392f90c8d471" do
      {:ready, %{state | api_key: api_key}}
    else
      :no_such_api_key
    end
  end

  def verify_job_id(job_id, _state) when byte_size(job_id) < 6 do
    :no_such_job_id
  end

  def verify_job_id(job_id, state) do
    {:ready, %{state | job_id: job_id}}
  end

  def run_job(%{done: true} = state) do
    :job_done
  end

  def run_job(state) do
    {:job_msg, %{msg: "holymoly"}, %{state | done: true}}
  end
end
