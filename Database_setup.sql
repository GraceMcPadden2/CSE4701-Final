DROP TABLE Line_Item CASCADE CONSTRAINTS;
DROP TABLE Transaction_Sale CASCADE CONSTRAINTS;
DROP TABLE Cart_Item CASCADE CONSTRAINTS;
DROP TABLE Store_Product CASCADE CONSTRAINTS;
DROP TABLE Product CASCADE CONSTRAINTS;
DROP TABLE Product_Type CASCADE CONSTRAINTS;
DROP TABLE Brand CASCADE CONSTRAINTS;
DROP TABLE Store CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;
DROP TABLE Vendor CASCADE CONSTRAINTS;
DROP TABLE Enterprise CASCADE CONSTRAINTS;

CREATE TABLE Enterprise (
    enterprise_id NUMBER(6) PRIMARY KEY,
    name          VARCHAR2(80) NOT NULL,
    headquarters  VARCHAR2(120)
);

------------------------------------------------------------
-- 2. VENDOR
------------------------------------------------------------
CREATE TABLE Vendor (
    vendor_id     NUMBER(6) PRIMARY KEY,
    name          VARCHAR2(80) NOT NULL UNIQUE,
    contact_email VARCHAR2(255),
    CONSTRAINT ck_vendor_email CHECK (contact_email IS NULL OR contact_email LIKE '%@%')
);

------------------------------------------------------------
-- 3. BRAND
------------------------------------------------------------
CREATE TABLE Brand (
    brand_id  NUMBER(6) PRIMARY KEY,
    name      VARCHAR2(80) NOT NULL UNIQUE,
    vendor_id NUMBER(6) NOT NULL,
    CONSTRAINT fk_brand_vendor FOREIGN KEY (vendor_id)
        REFERENCES Vendor(vendor_id)
        ON DELETE CASCADE
);

------------------------------------------------------------
-- 4. STORE
------------------------------------------------------------
CREATE TABLE Store (
    store_id      NUMBER(6) PRIMARY KEY,
    name          VARCHAR2(80) NOT NULL,
    location      VARCHAR2(120),
    max_capacity  NUMBER(5) DEFAULT 500 CHECK (max_capacity > 0),
    enterprise_id NUMBER(6) NOT NULL,
    CONSTRAINT fk_store_enterprise FOREIGN KEY (enterprise_id)
        REFERENCES Enterprise(enterprise_id)
        ON DELETE CASCADE
);

------------------------------------------------------------
-- 5. CUSTOMER
------------------------------------------------------------
CREATE TABLE Customer (
    customer_id NUMBER(6) PRIMARY KEY,
    name        VARCHAR2(80) NOT NULL,
    email       VARCHAR2(255) NOT NULL UNIQUE,
    password    VARCHAR2(255) NOT NULL,
    CONSTRAINT ck_customer_email CHECK (email LIKE '%@%')
);

------------------------------------------------------------
-- 6. PRODUCT_TYPE
------------------------------------------------------------
CREATE TABLE Product_Type (
    type_id NUMBER(6) PRIMARY KEY,
    name    VARCHAR2(80) NOT NULL UNIQUE
);

------------------------------------------------------------
-- 7. PRODUCT
------------------------------------------------------------
CREATE TABLE Product (
    product_id NUMBER(6) PRIMARY KEY,
    name       VARCHAR2(100) NOT NULL,
    price      NUMBER(8,2) NOT NULL CHECK (price > 0),
    brand_id   NUMBER(6) NOT NULL,
    type_id    NUMBER(6) NOT NULL,
    CONSTRAINT fk_product_brand FOREIGN KEY (brand_id)
        REFERENCES Brand(brand_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_product_type FOREIGN KEY (type_id)
        REFERENCES Product_Type(type_id)
        ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_product_name ON Product(name);

------------------------------------------------------------
-- 8. STORE_PRODUCT (stock per store)
------------------------------------------------------------
CREATE TABLE Store_Product (
    store_id   NUMBER(6),
    product_id NUMBER(6),
    stock      NUMBER(5) DEFAULT 0 CHECK (stock >= 0),
    PRIMARY KEY (store_id, product_id),
    CONSTRAINT fk_sp_store FOREIGN KEY (store_id)
        REFERENCES Store(store_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_sp_product FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
);

------------------------------------------------------------
-- 9. CART_ITEM
------------------------------------------------------------
CREATE TABLE Cart_Item (
    customer_id NUMBER(6),
    product_id  NUMBER(6),
    quantity    NUMBER(3) DEFAULT 1 CHECK (quantity > 0),
    PRIMARY KEY (customer_id, product_id),
    CONSTRAINT fk_ci_customer FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ci_product FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
);

------------------------------------------------------------
-- 10. TRANSACTION_SALE
------------------------------------------------------------
CREATE TABLE Transaction_Sale (
    transaction_id   NUMBER(8) PRIMARY KEY,
    customer_id      NUMBER(6) NOT NULL,
    store_id         NUMBER(6) NOT NULL,
    total_amount     NUMBER(10,2) NOT NULL CHECK (total_amount >= 0),
    transaction_date DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_ts_customer FOREIGN KEY (customer_id)
        REFERENCES Customer(customer_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_ts_store FOREIGN KEY (store_id)
        REFERENCES Store(store_id)
        ON DELETE SET NULL
);

------------------------------------------------------------
-- 11. LINE_ITEM
------------------------------------------------------------
CREATE TABLE Line_Item (
    transaction_id NUMBER(8),
    product_id     NUMBER(6),
    quantity       NUMBER(3) DEFAULT 1 CHECK (quantity > 0),
    price          NUMBER(8,2) NOT NULL CHECK (price > 0),
    PRIMARY KEY (transaction_id, product_id),
    CONSTRAINT fk_li_transaction FOREIGN KEY (transaction_id)
        REFERENCES Transaction_Sale(transaction_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_li_product FOREIGN KEY (product_id)
        REFERENCES Product(product_id)
        ON DELETE CASCADE
);

------------------------------------------------------------
-- 12. VIEWS
------------------------------------------------------------
CREATE OR REPLACE VIEW Purchase_History_V AS
SELECT c.customer_id,
       c.name AS customer_name,
       t.transaction_id,
       t.transaction_date,
       p.product_id,
       p.name AS product_name,
       l.quantity,
       l.price
FROM Customer c
JOIN Transaction_Sale t ON c.customer_id = t.customer_id
JOIN Line_Item l ON t.transaction_id = l.transaction_id
JOIN Product p ON l.product_id = p.product_id;

CREATE OR REPLACE VIEW Cart_Summary_V AS
SELECT c.customer_id,
       c.name AS customer_name,
       p.product_id,
       p.name AS product_name,
       ci.quantity,
       p.price
FROM Customer c
JOIN Cart_Item ci ON c.customer_id = ci.customer_id
JOIN Product p ON ci.product_id = p.product_id;
-- =========================================================
-- 4. SAMPLE DATA
-- =========================================================
-- ENTERPRISE
INSERT INTO Enterprise VALUES (1, 'TechCorp', 'New York');

-- VENDOR
INSERT INTO Vendor VALUES (1, 'MegaTech', 'contact@megatech.com');
INSERT INTO Vendor VALUES (2, 'BookWorld', 'info@bookworld.com');

-- BRAND
INSERT INTO Brand VALUES (1, 'MegaBrand', 1);
INSERT INTO Brand VALUES (2, 'BookBrand', 2);

-- STORE
INSERT INTO Store VALUES (1, 'Tech Store', 'NYC', 1000, 1);

-- CUSTOMER
INSERT INTO Customer VALUES (1, 'Alice Smith', 'alice@example.com', 'password123');
INSERT INTO Customer VALUES (2, 'Bob Jones', 'bob@example.com', 'password456');

-- PRODUCT_TYPE
INSERT INTO Product_Type VALUES (1, 'Electronics');
INSERT INTO Product_Type VALUES (2, 'Books');

-- PRODUCT
INSERT INTO Product VALUES (1, 'Laptop', 1000, 1, 1);
INSERT INTO Product VALUES (2, 'Headphones', 100, 1, 1);
INSERT INTO Product VALUES (3, 'Book - SQL Basics', 25, 2, 2);

-- STORE_PRODUCT
INSERT INTO Store_Product VALUES (1, 1, 50);
INSERT INTO Store_Product VALUES (1, 2, 200);
INSERT INTO Store_Product VALUES (1, 3, 300);

-- CART_ITEM
INSERT INTO Cart_Item VALUES (1, 1, 1);
INSERT INTO Cart_Item VALUES (1, 3, 2);
INSERT INTO Cart_Item VALUES (2, 2, 1);

-- TRANSACTION_SALE
INSERT INTO Transaction_Sale VALUES (1, 1, 1, 1050, SYSDATE);
INSERT INTO Transaction_Sale VALUES (2, 2, 1, 100, SYSDATE);

-- LINE_ITEM
INSERT INTO Line_Item VALUES (1, 1, 1, 1000);
INSERT INTO Line_Item VALUES (1, 3, 2, 25);
INSERT INTO Line_Item VALUES (2, 2, 1, 100);

COMMIT;
