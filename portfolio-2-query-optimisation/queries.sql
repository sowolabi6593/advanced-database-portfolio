SET search_path = naijamart;
\timing on

-- Q1: monthly revenue by month (last 12)
SELECT date_trunc('month', placed_at) AS month,
       count(*) AS orders, sum(total_amount) AS revenue
FROM orders
WHERE status IN ('PAID','SHIPPED','DELIVERED')
GROUP BY 1 ORDER BY 1 DESC LIMIT 12;

-- Q2: top-10 products by quantity sold
SELECT p.name, sum(oi.quantity) AS units, sum(oi.quantity*oi.unit_price) AS sales
FROM order_item oi JOIN product p USING (product_id)
GROUP BY p.name ORDER BY units DESC LIMIT 10;

-- Q3: seller performance leaderboard (window function)
SELECT s.shop_name,
       sum(o.total_amount) AS seller_revenue,
       rank() OVER (ORDER BY sum(o.total_amount) DESC) AS rnk
FROM orders o
JOIN customer c ON c.customer_id=o.customer_id
JOIN order_item oi ON oi.order_id=o.order_id
JOIN product p ON p.product_id=oi.product_id
JOIN seller s ON s.seller_id=p.seller_id
GROUP BY s.shop_name ORDER BY seller_revenue DESC;

-- Q4: customers with >5 delivered orders (HAVING + subquery)
SELECT c.full_name, count(*) AS delivered_orders
FROM orders o JOIN customer c USING (customer_id)
WHERE o.status='DELIVERED'
GROUP BY c.full_name HAVING count(*)>5 ORDER BY 2 DESC LIMIT 20;

-- Q5: hot-point query — one customer's recent orders with items (the app hot path)
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, o.placed_at, o.status, p.name, oi.quantity, oi.unit_price
FROM orders o
JOIN order_item oi ON oi.order_id=o.order_id
JOIN product p ON p.product_id=oi.product_id
WHERE o.customer_id = 1234
ORDER BY o.placed_at DESC LIMIT 10;

-- Q6: stock alert — products below reorder level, joined to category
SELECT c.name AS category, p.name, p.stock_qty
FROM product p JOIN category c USING (category_id)
WHERE p.stock_qty < 20 ORDER BY p.stock_qty;
