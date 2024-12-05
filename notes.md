# Phoenix Guides

## Useful commands

- `mix phx.gen.schema User users name:string email:string bio:string number_of_pets:integer`
- `mix phx.gen.html Catalog Product products title:string description:string price:decimal views:integer`
- `mix phx.gen.context Catalog Category categories title:string:unique`
- `mix ecto.gen.migration create_product_categories`
- `mix phx.gen.context ShoppingCart Cart carts user_uuid:uuid:unique`
- `mix phx.gen.context ShoppingCart CartItem cart_items cart_id:references:carts product_id:references:products price_when_carted:decimal quantity:integer`
- `mix phx.gen.context Orders Order orders user_uuid:uuid total_price:decimal`
- `mix phx.gen.context Orders LineItem order_line_items price:decimal quantity:integer order_id:references:orders product_id:references:products`
- `mix phx.gen.json Urls Url urls link:string title:string`

## Important Notes

- A `Catalog` context is a natural place for the management of our product details and the showcasing of those products we have for sale.
  - In ThePantry(tm) our `Catalog` is the items that a user has in their inventory so we can call it `Inventory`
- If you're stuck when trying to come up with a context name when the grouped functionality in your system isn't yet clear, you can simply use the plural form of the resource you're creating. For example, a Products context for managing products. As you grow your application and the parts of your system become clear, you can simply rename the context to a more refined one.
- Our Phoenix controller is the web interface into our greater application.
- It shouldn't be concerned with the details of how products are fetched from the database or persisted into storage. We only care about telling our application to perform some work for us.
- This is great because our business logic and storage details are decoupled from the web layer of our application.
- All interaction with our product changesets is done through the public Catalog context.
- Let's create a ShoppingCart context to handle basic cart duties.
- From the description, it's clear we need a Cart resource for storing the user's cart, along with a CartItem to track products in the cart.
- We generated a new resource inside our ShoppingCart named CartItem. This schema and table will hold references to a cart and product, along with the price at the time we added the item to our cart, and the quantity the user wishes to purchase
- We used the :delete_all strategy again to enforce data integrity. This way, when a cart or product is deleted from the application, we don't have to rely on application code in our ShoppingCart or Catalog contexts to worry about cleaning up the records. This keeps our application code decoupled and the data integrity enforcement where it belongs – in the database. We also added a unique constraint to ensure a duplicate product is not allowed to be added to a cart. As with the product_categories table, using a multi-column index lets us remove the separate index for the leftmost field (cart_id). With our database tables in place, we can now migrate up:
- Our database is ready to go with new carts and cart_items tables, but now we need to map that back into application code. You may be wondering how we can mix database foreign keys across different tables and how that relates to the context pattern of isolated, grouped functionality. Let's jump in and discuss the approaches and their tradeoffs.
- Our Catalog.Product resource serves to keep the responsibilities of representing a product inside the catalog, but ultimately for an item to exist in the cart, a product from the catalog must be present. Given this, our ShoppingCart context will have a data dependency on the Catalog context. With that in mind, we have two options. One is to expose APIs on the Catalog context that allows us to efficiently fetch product data for use in the ShoppingCart system, which we would manually stitch together. Or we can use database joins to fetch the dependent data. Both are valid options given your tradeoffs and application size, but joining data from the database when you have a hard data dependency is just fine for a large class of applications and is the approach we will take here.
- First, we replaced the cart_id field with a standard belongs_to pointing at our ShoppingCart.Cart schema. Next, we replaced our product_id field by adding our first cross-context data dependency with a belongs_to for the Catalog.Product schema. Here, we intentionally coupled the data boundaries because it provides exactly what we need: an isolated context API with the bare minimum knowledge necessary to reference a product in our system. Next, we added a new validation to our changeset. With validate_number/3, we ensure any quantity provided by user input is between 0 and 100.
- We started much like how our out-of-the-box code started – we take the cart struct and cast the user input to a cart changeset, except this time we use Ecto.Changeset.cast_assoc/3 to cast the nested item data into CartItem changesets. Remember the <.inputs_for /> call in our cart form template? That hidden ID data is what allows Ecto's cast_assoc to map item data back to existing item associations in the cart. Next we use Ecto.Multi.new/0, which you may not have seen before. Ecto's Multi is a feature that allows lazily defining a chain of named operations to eventually execute inside a database transaction. Each operation in the multi chain receives the values from the previous steps and executes until a failed step is encountered. When an operation fails, the transaction is rolled back and an error is returned, otherwise the transaction is committed.
- For our multi operations, we start by issuing an update of our cart, which we named :cart. After the cart update is issued, we perform a multi delete_all operation, which takes the updated cart and applies our zero-quantity logic. We prune any items in the cart with zero quantity by returning an ecto query that finds all cart items for this cart with an empty quantity. Calling Repo.transaction/1 with our multi will execute the operations in a new transaction and we return the success or failure result to the caller just like the original function.
- The orders table alone doesn't hold much information, but we know we'll need to store point-in-time product price information of all the items in the order. For that, we'll add an additional struct for this context named LineItem. Line items will capture the price of the product at payment transaction time
- We used has_many :line_items to associate orders and line items, just like we've seen before. Next, we used the :through feature of has_many, which allows us to instruct ecto how to associate resources across another relationship. In this case, we can associate products of an order by finding all products through associated line items. Next, let's wire up the association in the other direction in `lib/hello/orders/line_item.ex`:
- We used belongs_to to associate line items to orders and products. With our associations in place, we can start integrating the web interface into our order process.
-
