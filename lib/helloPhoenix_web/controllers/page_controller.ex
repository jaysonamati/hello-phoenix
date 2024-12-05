defmodule HelloPhoenixWeb.PageController do
  use HelloPhoenixWeb, :controller

  # plug HelloPhoenixWeb.Plugs.Locale, "en"
  plug HelloPhoenixWeb.Plugs.Locale, "en" when action in [:index]

  plug :put_view, html: HelloPhoenixWeb.PageHTML, json: HelloPhoenixWeb.PageJSON

  def index(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
  # def home(conn, _params) do
  #   conn
  #   |> put_resp_content_type("text/plain")
  #   |> send_resp(201, "")
  # end

  # def home(conn, _params) do
  #   conn
  #   |> put_resp_content_type("text/xml")
  #   |> render(:home, content: some_xml_content) #We would then need to provide an home.xml.eex template which created valid XML, and we would be done.
  # end

  # def home(conn, _params) do
  #   conn
  #   |> put_status(202)
  #   |> render(:home, layout: false)
  # end

  # def home(conn, _params) do
  #   redirect(conn, to: ~p"/redirect_test")
  # end

  # def home(conn, _params) do
  #   redirect(conn, external: "https://elixir-lang.org/")
  # end

  # def home(conn, _params) do
  #   conn
  #   |> put_flash(:error, "Let's pretend we have an error.")
  #   |> render(:home, layout: false)
  # end

  def home(conn, _params) do
    conn
    |> put_flash(:error, "Let's pretend we have an error.")
    |> redirect(to: ~p"/redirect_test")
  end

  def redirect_test(conn, _params) do
    render(conn, :home, layout: false)
  end
end
