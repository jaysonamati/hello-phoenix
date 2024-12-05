defmodule HelloPhoenixWeb.Router do
  # alias HelloPhoenixWeb.ProductController
  use HelloPhoenixWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HelloPhoenixWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HelloPhoenixWeb.Plugs.Locale, "en"
    plug :fetch_current_user
    plug :fetch_current_cart
  end

  defp fetch_current_user(conn, _) do
    if user_uuid = get_session(conn, :current_uuid) do
      assign(conn, :current_uuid, user_uuid)
    else
      new_uuid = Ecto.UUID.generate()

      conn
      |> assign(:current_uuid, new_uuid)
      |> put_session(:current_uuid, new_uuid)
    end
  end

  alias HelloPhoenix.ShoppingCart

  defp fetch_current_cart(conn, _opts) do
    if cart = ShoppingCart.get_cart_by_user_uuid(conn.assigns.current_uuid) do
      assign(conn, :cart, cart)
    else
      {:ok, new_cart} = ShoppingCart.create_cart(conn.assigns.current_uuid)
      assign(conn, :cart, new_cart)
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug :browser
    # plug :ensure_authenticated_user
    # plug :ensure_user_owns_review
  end

  # scope "/reviews", HelloPhoenixWeb do
  #   pipe_through :auth

  #   resources "/", ReviewController
  # end

  # scope "/api", HelloPhoenixWeb.Api, as: :api do
  #   pipe_through :api

  #   scope "/v1", V1, as: :v1 do
  #     resources "/images", ImageController
  #     resources "/reviews", ReviewController
  #     resources "/users", UserController
  #   end
  # end

  # scope "/admin", HelloPhoenixWeb.Admin do
  #   pipe_through :browser

  #   resources "/images", ImageController
  #   resources "/reviews", ReviewController
  #   resources "/users", UserController

  # end

  scope "/api", HelloPhoenixWeb do
    pipe_through :api
    resources "/urls", UrlController, except: [:new, :edit]
  end

  scope "/", HelloPhoenixWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/products", ProductController

    resources "/cart_items", CartItemController, only: [:create, :delete]

    get "/cart", CartController, :show
    put "/cart", CartController, :update

    resources "/orders", OrderController, only: [:create, :show]
    # get "/redirect_test", PageController, :redirect_test
    # resources "/users", UserController do
    #   resources "/posts", PostController
    # end
    # resources "/comments", CommentController, except: [:delete]
    # get "/hello", HelloController, :index
    # get "/hello/:messenger", HelloController, :show
    # resources "/reviews", ReviewController
  end

  # Other scopes may use custom stacks.
  # scope "/api", HelloPhoenixWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:helloPhoenix, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HelloPhoenixWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
