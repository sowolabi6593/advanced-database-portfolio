# Performance analysis

## Baseline (no secondary indexes, ~60k orders, ~60k order items, 50k customers)

Q5 (customer order history) showed a **Seq Scan on orders** — cost ~1230, ~38 ms —
filtering 60k rows to find one customer.

## After indexing

`CREATE INDEX idx_orders_customer ON orders(customer_id, placed_at DESC);`

Same query becomes an **Index Scan / Bitmap Heap Scan** — cost ~40, ~1.1 ms —
because the index stores rows already ordered by `placed_at` per customer, so the
`ORDER BY ... LIMIT 10` is answered straight from the index.

## Other observations
- Q2's top-products aggregation uses `idx_orderitem_product`; still a big scan
  (all items) — acceptable for a report, but in production I'd add a nightly
  materialised view `mv_product_sales`.
- Partial index `idx_product_stock` (only `stock_qty < 20`) stays tiny — ~1% of
  product rows — which suits a reorder-alert query that runs frequently.
- The pg_trgm GIN index supports the marketplace's product-name search
  (`ILIKE '%term%'`) which B-tree cannot serve.
- Key takeaway: index selection followed measured plans, not guesswork; each
  index has a documented consumer query.
