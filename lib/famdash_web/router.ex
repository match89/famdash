defmodule FamdashWeb.Router do
  use FamdashWeb, :router

  import FamdashWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FamdashWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  scope "/", FamdashWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:famdash, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FamdashWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", FamdashWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{FamdashWeb.UserAuth, :redirect_if_user_is_authenticated}] do
        get "/auth/:provider", AuthController, :request
        get "/auth/:provider/callback", AuthController, :callback
    end
  end

  scope "/", FamdashWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{FamdashWeb.UserAuth, :ensure_authenticated}] do
      get "/logout", AuthController, :logout
      live "/users/settings", UserSettingsLive, :edit
    end
  end

  scope "/", FamdashWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{FamdashWeb.UserAuth, :mount_current_user}] do
    end
  end
end
