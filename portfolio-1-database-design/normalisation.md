# Normalisation walk-through (to 3NF)

Starting point — a single "flat" order record as often exported from a legacy sheet:

`order_line(order_id, customer_name, customer_email, phone, address, product_name,
seller_name, category, unit_price, qty, payment_method, paid_at, courier, ship_status)`

Problems: heavy redundancy (customer/seller/product repeated per line), update
anomalies (change seller name → many rows), delete anomalies (last order deleted →
customer lost).

## 1NF
Split repeating groups: one row per order item; atomic attributes only.
Relation: `order_line(order_id, line_no, customer_*, product_*, qty, price)`.
PK: (order_id, line_no). Still redundant but atomic.

## 2NF
Remove partial dependencies on the composite key:
- `customer_name,email,phone` depend only on customer → `customer` table.
- `product_name,seller,category` depend only on product → `product` table.
- `qty,unit_price` depend on (order_id, product_id) → stays in `order_item`.

## 3NF
Remove transitive dependencies:
- `seller_name` was reachable via product → `seller` table.
- `category` name moved to `category` (self-referencing `parent_id` for
  sub-categories without a fourth table).
- `payment_*`, `shipment_*` factored into `payment` and `shipment` (1 order → N
  payment attempts / shipments).
- `address` extracted because a customer reuses addresses across orders.

## Result — all tables in 3NF
Every non-key attribute depends on the key, the whole key, and nothing but the key.
`order_item.unit_price` intentionally duplicates `product.price` at purchase time —
this is a controlled snapshot, not a normalisation violation (documented business rule).
