-- Run in TWO psql sessions against naijamart.
-- ============ EXPERIMENT A: lost update under READ COMMITTED ============
-- Product 1 starts at stock_qty = 40.
-- Session A                              -- Session B
BEGIN;                                    BEGIN;
SELECT stock_qty FROM product
WHERE product_id=1;   -- 40               SELECT stock_qty FROM product
                                           WHERE product_id=1; -- also 40
UPDATE product SET stock_qty=40-5
WHERE product_id=1;
                                          UPDATE product SET stock_qty=40-3
                                          WHERE product_id=1; -- BLOCKS on A's lock
COMMIT;
                                          -- B now writes 37, A wrote 35 -> last-writer wins
                                          COMMIT;
-- Result: stock 37, two sales committed, should be 32 -> LOST UPDATE demonstrated.

-- ============ EXPERIMENT B: fix with SELECT ... FOR UPDATE ============
BEGIN;
SELECT stock_qty FROM product WHERE product_id=1 FOR UPDATE; -- row lock
UPDATE product SET stock_qty = stock_qty - 5 WHERE product_id=1;
COMMIT;
-- Session B doing the same pattern now serialises on the row lock -> stock = 32. Correct.

-- ============ EXPERIMENT C: atomic conditional update (the pattern used in prod) ============
UPDATE product SET stock_qty = stock_qty - 5
WHERE product_id = 1 AND stock_qty >= 5;
-- Single statement: read-modify-write under the row lock, CHECK stops negatives.

-- ============ EXPERIMENT D: SERIALIZABLE anomaly detection ============
BEGIN ISOLATION LEVEL SERIALIZABLE;
-- Two concurrent balance-transfer transactions -> one aborts with:
-- ERROR: could not serialize access due to concurrent update  (SQLSTATE 40001)
COMMIT;
