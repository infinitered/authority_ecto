defmodule Authority.Ecto.Enum do
  @moduledoc """
  An `Ecto.Type` for an [enum](https://en.wikipedia.org/wiki/Enumerated_type).
  It acts as a whitelist and prevents invalid values from being saved to the
  database.

  ## Configuration

  Define a module that will become an enum:

    defmodule MyApp.Accounts.Token.Purpose do
      use Authority.Ecto.Enum, values: [:any, :recovery]
    end

  The `:values` option is **required** and should be a list of atoms.

  ## Usage

  You can use your enum to define a field:

      schema "tokens" do
        field :purpose, MyApp.Accounts.Token.Purpose
      end

  The only acceptable values for the `purpose` field are:

    * `nil`
    * `:any`
    * `"any"`
    * `:recovery`
    * `"recovery"`

  If you attempt to insert any other value, the insert will fail.
  """

  defmacro __using__(opts) do
    values = Keyword.fetch!(opts, :values)

    quote bind_quoted: [values: values] do
      @behaviour Ecto.Type

      def type, do: :string

      def cast(nil), do: {:ok, nil}
      def dump(nil), do: {:ok, nil}
      def load(nil), do: {:ok, nil}

      for value <- values, atom = value, string = Atom.to_string(value) do
        def cast(unquote(atom)), do: {:ok, unquote(atom)}
        def cast(unquote(string)), do: {:ok, unquote(atom)}
        def load(unquote(string)), do: {:ok, unquote(atom)}
        def dump(unquote(string)), do: {:ok, unquote(string)}
        def dump(unquote(atom)), do: {:ok, unquote(string)}
      end

      def cast(_), do: :error
      def load(_), do: :error
      def dump(_), do: :error
    end
  end
end
