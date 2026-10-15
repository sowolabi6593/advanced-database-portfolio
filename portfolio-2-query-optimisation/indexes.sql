SET search_path = naijamart;
-- Indexes justified by EXPLAIN evidence (see evidence/explain_after.txt)
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id, placed_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status   ON orders(status) WHERE status <> 'DELIVERED';
CREATE INDEX IF NOT EXISTS idx_orderitem_product ON order_item(product_id);
CREATE INDEX IF NOT EXISTS idx_product_stock   ON product(stock_qty) WHERE stock_qty < 20;
CREATE INDEX IF NOT EXISTS idx_product_name_trgm ON product USING gin (name gin_trgm_ops);
