defmodule Purl.Example.Stanzas do
  use Purl.Stanzas, handlers_module: Purl.Example.Handlers

  //TODO: other types:
  //  * :stream
  //  * :varlength_message

  accept hello,
    type: :literal,
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
    type: :literal,
    message: "99",
    handler: fn -> :terminate end

  accept ping,
    type: :tagged_message,
    tag: "ping",
    end_token: <<0>>,
    response: :pong

  accept client_info_json,
    type: :tagged_varlength_message,
    tag: "40",
    format: :json,
    max_length: 4 * 1024,
    handler: :client_message 

  accept client_info_etf,
    type: :tagged_varlength_message,
    tag: "41",
    format: :etf,
    max_length: 4 * 1024,
    handler: :client_message 

  process run_job,
    handler: :exec,
    async: true

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
end
