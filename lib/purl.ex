defmodule Purl do
  @moduledoc """
  A declarative network service framework.
  """
  defmacro __using__(args) do
    stanzas_mod = Keyword.get(args, :stanzas, __MODULE__)
    quote do
      alias unquote(stanzas_mod), as: DefaultStanzas
      import Purl
    end
  end

  defmacro proto(name, definition) do
    #IO.inspect(name, label: "proto")
    #IO.inspect(definition, label: "  def")
    does = Keyword.get(definition, :does) |> IO.inspect(label: "Doing")
    quote do
      def unquote(name)() do
        unquote(does)
      end
    end
  end

  defmacro on(msg, action) do
    #IO.inspect(msg, label: "on msg")
    #IO.inspect(action, label: "  action")
    quote do
      []
    end
  end
end
