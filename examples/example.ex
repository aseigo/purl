defmodule Purl.Example do
  use Purl, entry_chain: handshake

  def new_state(), do %{api_key: nil, job_id: nil}

  accept init,
    type: :fixed_message,
    message: "HH",
    handler: fn -> :start_v1 end

  accept apikey,
    type: :fixed_size_message,
    size: 36,
    handler: :verify_key

  accept job_id,
    type: :terminated_buffer,
    end_token: <<0>>,
    handler: :verify_job_id

  accept terminate,
    type: :fixed_message,
    message: "99",
    handler: fn -> :terminate end

  accept ping,
    type: :tagged_message,
    tag: "ping",
    end_token: <<0>>,
    response: :pong

  accept client_info,
    type: :tagged_varlength_message,
    tag: "40",
    max_size: 1024,
    handler: :client_message 

  process run_job,
    type: :send,
    timeout: :infinite,
    handler: :exec

  respond error,
    type: :tagged_message,
    tag: "11",
    end_token: "\n"

  respond info,
    type: :tagged_varlength_message,
    tag: "20"

  respond pong,
    type: :fixed_message
    message: "pong" <> <<0>>
    

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
