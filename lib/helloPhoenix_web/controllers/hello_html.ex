defmodule HelloPhoenixWeb.HelloHTML do
  use HelloPhoenixWeb, :html

  # def index(assigns) do
  #   ~H"""
  #   Hello!
  #   """
  # end
  embed_templates "hello_html/*"

  attr :messenger, :string, required: true

  def greet(assigns) do
    ~H"""
    <h2>Hello Friend, from <%= @messenger %>!</h2>
    """
  end
end
