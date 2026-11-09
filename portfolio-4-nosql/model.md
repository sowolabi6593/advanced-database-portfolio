# NaijaMart in MongoDB — design rationale

## What stays a document
- **products**: embedded `attributes` object — electronics have `ram/storage`,
  fabrics have `material/length`; a document model absorbs this without EAV or
  dozens of nullable columns.
- **orders**: embed `items[]` and `payment` — an order is always fetched whole in
  the app (order page / confirmation email), so one document = one read.
- **customers**: embed `addresses[]` — small, bounded, always read with customer.

## What stays a reference
- `orders.customer_id` → `customers` (customer record outlives an order)
- `order_items.product_id` → `products` (price/name change after purchase; we
  *snapshot* `price_at_purchase` into the item — same rule as the SQL design)
- `products.seller_id` → `sellers`

## Trade-offs vs the relational model
- Denormalised reads are faster (no joins for order display) but
  seller-side fan-out updates (e.g. renaming a shop) touch fewer places because
  sellers stay referenced.
- Stock decrement uses `findOneAndUpdate({stock:{$gte:q}},{$inc:{stock:-q}})` —
  atomic conditional update mirroring Portfolio 3's guarded UPDATE.
- Transactions: multi-document `session.withTransaction()` exists but the model
  is designed so the hot path stays single-document atomic.
