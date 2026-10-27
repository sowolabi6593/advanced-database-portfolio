SET search_path = naijamart;
\timing on

-- ============ T1: place an order atomically (COMMIT) ============
BEGIN;
INSERT INTO orders(customer_id,address_id,status,total_amount)
VALUES (1,1,'PENDING',0) RETURNING order_id;              -- say returns 70001

UPDATE product SET stock_qty = stock_qty - 2
WHERE product_id = 1 AND stock_qty >= 2;                 -- stock check guards oversell

INSERT INTO order_item(order_id,product_id,quantity,unit_price)
SELECT 70001, 1, 2, price FROM product WHERE product_id=1;

UPDATE orders SET total_amount =
  (SELECT sum(quantity*unit_price) FROM order_item WHERE order_id=70001)
WHERE order_id=70001;
COMMIT;

-- ============ T2: failed payment -> ROLLBACK ============
BEGIN;
INSERT INTO payment(order_id,method,status,amount) VALUES (70001,'CARD','INITIATED',570000);
-- gateway returns failure:
ROLLBACK;                                               -- payment row disappears

-- ============ T3: savepoints — partial failure inside order batch ============
BEGIN;
INSERT INTO orders(customer_id,address_id,status,total_amount)
VALUES (2,2,'PENDING',0) RETURNING order_id;              -- 70002
SAVEPOINT before_items;
UPDATE product SET stock_qty=stock_qty-999 WHERE product_id=1;  -- violates CHECK
-- ERROR: new row violates check constraint
ROLLBACK TO SAVEPOINT before_items;                      -- keep order, undo stock hit
UPDATE product SET stock_qty=stock_qty-5 WHERE product_id=1;    -- valid qty
INSERT INTO order_item(order_id,product_id,quantity,unit_price)
SELECT 70002,1,5,price FROM product WHERE product_id=1;
COMMIT;
