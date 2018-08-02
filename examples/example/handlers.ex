defmodule Purl.Example.Handers do
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
