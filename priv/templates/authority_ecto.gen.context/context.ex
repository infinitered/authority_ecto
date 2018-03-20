defmodule <%= inspect context.module %> do
  use Authority.Ecto.Template,
    behaviours: [
      <%= Enum.map_join(behaviours, ",\n      ", &inspect/1) %>
    ],
    config: [
      <%= Enum.map_join(config, ",\n      ", fn {k, v} -> "#{k}: #{inspect(v)}" end) %>
    ]
  <%= if Authority.Recovery in behaviours do %>
  @doc """
  Send a password recovery email to the user.
  """
  def send_forgot_password_email(email, token) do
    IO.warn("Recovering '#{email}' with token '#{token.token}'.")
  end<% end %>
end
