defmodule Purl.Stanzas do
  defmacro __using__(args) do
    handler_mod = Keyword.get(args, :handlers, __MODULE__)
    quote do
      alias unquote(handler_mod), as: DefaultHandlers
      import Purl.Stanzas
    end
  end

  defmacro accept(name, definition) do
    IO.inspect(name, label: "Accepter:")
    IO.inspect(definition, label: "  Definition:")
  end

  defmacro process(name, definition) do

  end

  defmacro respond(name, definition) do

  end
end
