defmodule FamdashWeb.UserSettingsLive do
  use FamdashWeb, :live_view

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <div class="space-y-12 divide-y">

    </div>
    """
  end

  def mount(%{"token" => _token}, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end
end
