-- NaijaMart relational schema — PostgreSQL 15
-- Portfolio 1: MIT 8103 CA, Stanley Owolabi
DROP SCHEMA IF EXISTS naijamart CASCADE;
CREATE SCHEMA naijamart;
SET search_path = naijamart;

CREATE TABLE customer (
    customer_id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name    VARCHAR(120) NOT NULL,
    email        VARCHAR(180) NOT NULL UNIQUE,
    phone        VARCHAR(20),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE seller (
    seller_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shop_name      VARCHAR(120) NOT NULL UNIQUE,
    contact_email  VARCHAR(180) NOT NULL,
    rating         NUMERIC(3,2) DEFAULT 0 CHECK (rating BETWEEN 0 AND 5),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE category (
    category_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         VARCHAR(80) NOT NULL UNIQUE,
    parent_id    INT REFERENCES category(category_id)
);

CREATE TABLE product (
    product_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_id    BIGINT NOT NULL REFERENCES seller(seller_id),
    category_id  INT  NOT NULL REFERENCES category(category_id),
    name         VARCHAR(200) NOT NULL,
    description  TEXT,
    price        NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    stock_qty    INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE address (
    address_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  BIGINT NOT NULL REFERENCES customer(customer_id),
    line1        VARCHAR(160) NOT NULL,
    city         VARCHAR(80) NOT NULL,
    state        VARCHAR(80) NOT NULL,
    country      VARCHAR(80) NOT NULL DEFAULT 'Nigeria'
);

CREATE TABLE orders (
    order_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   BIGINT NOT NULL REFERENCES customer(customer_id),
    address_id    BIGINT NOT NULL REFERENCES address(address_id),
    status        VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                  CHECK (status IN ('PENDING','PAID','SHIPPED','DELIVERED','CANCELLED')),
    total_amount  NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    placed_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE order_item (
    order_id    BIGINT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id  BIGINT NOT NULL REFERENCES product(product_id),
    quantity    INT NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payment (
    payment_id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id    BIGINT NOT NULL REFERENCES orders(order_id),
    method      VARCHAR(20) NOT NULL CHECK (method IN ('CARD','TRANSFER','USSD','WALLET')),
    status      VARCHAR(20) NOT NULL DEFAULT 'INITIATED'
                CHECK (status IN ('INITIATED','SUCCESS','FAILED','REFUNDED')),
    amount      NUMERIC(14,2) NOT NULL CHECK (amount >= 0),
    paid_at     TIMESTAMPTZ
);

CREATE TABLE shipment (
    shipment_id  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id     BIGINT NOT NULL REFERENCES orders(order_id),
    courier      VARCHAR(60) NOT NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                 CHECK (status IN ('PENDING','IN_TRANSIT','DELIVERED','FAILED')),
    shipped_at   TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ
);

CREATE TABLE review (
    review_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  BIGINT NOT NULL REFERENCES customer(customer_id),
    product_id   BIGINT NOT NULL REFERENCES product(product_id),
    rating       SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (customer_id, product_id)   -- one review per customer per product
);

-- Seed data (small, for demos/tests)
INSERT INTO category(name) VALUES ('Electronics'),('Fashion'),('Groceries'),('Home & Kitchen');
INSERT INTO seller(shop_name,contact_email,rating) VALUES
 ('TechPoint NG','sales@techpoint.ng',4.6),('Lagos Fabrics','hello@lagosfabrics.ng',4.3),
 ('FarmFresh','orders@farmfresh.ng',4.8);
INSERT INTO customer(full_name,email,phone) VALUES
 ('Adaeze Okafor','adaeze.okafor@example.com','+2348012345678'),
 ('Tunde Balogun','tunde.balogun@example.com','+2348098765432'),
 ('Fatima Musa','fatima.musa@example.com','+2348055512345');
INSERT INTO address(customer_id,line1,city,state) VALUES
 (1,'12 Adeola Odeku St','Lagos','Lagos'),(2,'45 Wuse Zone 4','Abuja','FCT'),
 (3,'8 GRA Phase 2','Port Harcourt','Rivers');
INSERT INTO product(seller_id,category_id,name,price,stock_qty) VALUES
 (1,1,'Infinix Note 40 Pro',285000.00,40),(1,1,'Oraimo PowerBank 20000mAh',18500.00,150),
 (2,2,'Ankara Fabric 6 yards',12500.00,300),(3,3,'Ofada Rice 5kg',9800.00,500),
 (3,4,'Palm Oil 5L',15000.00,220);
