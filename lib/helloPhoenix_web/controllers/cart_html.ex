defmodule HelloPhoenixWeb.CartHTML do
  use HelloPhoenixWeb, :html

  alias HelloPhoenix.ShoppingCart

  embed_templates "cart_html/*"

  def currency_to_str(%Decimal{} = val), do: "$#{Decimal.round(val, 2)}"
end
