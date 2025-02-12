defmodule FamdashWeb.AuthController do
  use FamdashWeb, :controller
  alias Famdash.Accounts
  alias Famdash.Repo
  alias FamdashWeb.UserAuth

  @spec request(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def request(conn, %{"provider" => provider}) do
    config = config!(provider)
    case config[:strategy].authorize_url(config) do
      {:ok, %{url: url}} -> redirect(conn, external: url)
      {:error, reason} -> conn |> put_flash(:error, "OAuth request error: #{inspect(reason)}") |> redirect(to: "/")
    end
  end


  def callback(conn, params) do
    config = config!(params["provider"])
    |> Keyword.put(:session_params, %{ state: params["state"], code: params["code"], scope: params["scope"] })

    case config[:strategy].callback(config, params) do
      {:ok, auth_data} ->
        social_user = SocialUserMapper.map(String.to_atom(params["provider"]), auth_data.user)
        user = find_or_create_user(social_user)
        conn
        |> UserAuth.log_in_user(user)
        |> put_flash(:info, "Welcome, #{user.email}!")

      {:error, reason} ->
        conn
        |> put_flash(:error, "OAuth callback error: #{inspect(reason)}")
        |> redirect(to: "/")
    end
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end

  defp find_or_create_user(%{provider: provider, uid: uid, email: email}) do
    case Repo.get_by(Accounts.User, provider: provider, uid: uid) do
      nil ->
        %Accounts.User{}
        |> Accounts.User.registration_changeset(%{email: email, provider: provider, uid: uid})
        |> Repo.insert!()
      user -> user
    end
  end

  @spec config!(charlist()) :: map()
  defp config!(provider) do
    strategies = Application.get_env(:famdash, :auth_strategies) ||
      raise "No auth strategies configured"
    strategies[String.to_atom(provider)]
  end
end

defmodule SocialUserMapper do
  def map(:google, %{"email" => email, "sub" => uid}) do
    %{email: email, uid: uid, provider: "google"}
  end
end
