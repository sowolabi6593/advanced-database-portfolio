-- Synthetic data generator for Portfolio 2 (idempotent-ish)
SET search_path = naijamart;
INSERT INTO customer(full_name,email,phone)
SELECT 'Customer '||g, 'cust'||g||'@example.com', '+23480'||lpad((g%100000000)::text,8,'0')
FROM generate_series(4,50000) g;

INSERT INTO product(seller_id,category_id,name,price,stock_qty)
SELECT 1+(g%3), 1+(g%4), 'Product '||g, 500+(g%50000), 10+(g%200)
FROM generate_series(6,8000) g;

INSERT INTO orders(customer_id,address_id,status,total_amount,placed_at)
SELECT 1+(g%50000), 1+(g%3),
       (ARRAY['PENDING','PAID','SHIPPED','DELIVERED','CANCELLED'])[1+g%5],
       0, now() - (g%180||' days')::interval
FROM generate_series(1,60000) g;

INSERT INTO order_item(order_id,product_id,quantity,unit_price)
SELECT o.order_id, 1+(o.order_id%8005), 1+(o.order_id%3), 500+(o.order_id%50000)
FROM orders o;
