defmodule <%= inspect context.module %> do
  use Authority.Ecto.Template,
<%= [behaviours: behaviours, config: config]
    |> inspect()
    |> Code.format_string!()
    |> IO.iodata_to_binary()
    |> String.split("\n")
    |> Enum.map(fn line -> "  " <> line <> "\n" end)
    |> List.delete_at(0)
    |> List.delete_at(-1) %>
  <%= if options[:recovery] do %>
  @doc """
  Send a password recovery email to the user.
  """
  def send_forgot_password_email(email, token) do
    IO.warn("Recovering '#{email}' with token '#{token.token}'.")
  end<% end %>
end
