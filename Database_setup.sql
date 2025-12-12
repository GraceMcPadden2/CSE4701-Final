DROP TABLE Line_Item CASCADE CONSTRAINTS;
DROP TABLE Transaction_Sale CASCADE CONSTRAINTS;
DROP TABLE Cart_Item CASCADE CONSTRAINTS;
DROP TABLE Cart CASCADE CONSTRAINTS;
DROP TABLE Product CASCADE CONSTRAINTS;
DROP TABLE Product_Type CASCADE CONSTRAINTS;
DROP TABLE Brand CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;
DROP TABLE Vendor CASCADE CONSTRAINTS;

CREATE TABLE Customer (
    customer_id     NUMBER PRIMARY KEY,
    name            VARCHAR2(100) NOT NULL,
    email           VARCHAR2(255) NOT NULL UNIQUE,
    username        VARCHAR2(50) NOT NULL UNIQUE,
    password_hash   VARCHAR2(255) NOT NULL
);

CREATE TABLE Vendor (
    vendor_id   NUMBER PRIMARY KEY,
    name        VARCHAR2(100) NOT NULL UNIQUE
);

CREATE TABLE Brand (
    brand_id    NUMBER PRIMARY KEY,
    name        VARCHAR2(100) NOT NULL,
    vendor_id   NUMBER NOT NULL,
    CONSTRAINT fk_brand_vendor
        FOREIGN KEY (vendor_id) REFERENCES Vendor(vendor_id)
);

CREATE TABLE Product_Type (
    type_id     NUMBER PRIMARY KEY,
    type_name   VARCHAR2(100) NOT NULL UNIQUE
);

CREATE TABLE Product (
    product_id   NUMBER PRIMARY KEY,
    name         VARCHAR2(150) NOT NULL,
    price        NUMBER(10,2) NOT NULL CHECK (price >= 0),
    quantity     NUMBER NOT NULL CHECK (quantity >= 0),
    description  VARCHAR2(500),
    type_id      NUMBER NOT NULL,
    brand_id     NUMBER NOT NULL,
    CONSTRAINT fk_prod_type
        FOREIGN KEY (type_id) REFERENCES Product_Type(type_id),
    CONSTRAINT fk_prod_brand
        FOREIGN KEY (brand_id) REFERENCES Brand(brand_id)
);

CREATE TABLE Transaction_Sale (
    transaction_id   NUMBER PRIMARY KEY,
    customer_id      NUMBER NOT NULL,
    amount           NUMBER(10,2) NOT NULL CHECK (amount >= 0),
    created_at       DATE DEFAULT SYSDATE,
    CONSTRAINT fk_trans_customer
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Line_Item (
    transaction_id   NUMBER NOT NULL,
    product_id       NUMBER NOT NULL,
    quantity         NUMBER NOT NULL CHECK (quantity > 0),
    CONSTRAINT pk_lineitem PRIMARY KEY (transaction_id, product_id),
    CONSTRAINT fk_li_trans
        FOREIGN KEY (transaction_id) REFERENCES Transaction_Sale(transaction_id),
    CONSTRAINT fk_li_prod
        FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Cart (
    cart_id      NUMBER PRIMARY KEY,
    customer_id  NUMBER NOT NULL,
    created_at   DATE DEFAULT SYSDATE,
    updated_at   DATE DEFAULT SYSDATE,
    CONSTRAINT fk_cart_customer
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Cart_Item (
    cart_id     NUMBER NOT NULL,
    product_id  NUMBER NOT NULL,
    quantity    NUMBER NOT NULL CHECK (quantity > 0),
    CONSTRAINT pk_cartitem PRIMARY KEY (cart_id, product_id),
    CONSTRAINT fk_ci_cart
        FOREIGN KEY (cart_id) REFERENCES Cart(cart_id),
    CONSTRAINT fk_ci_prod
        FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE INDEX idx_product_type ON Product(type_id);
CREATE INDEX idx_product_brand ON Product(brand_id);
CREATE INDEX idx_trans_customer ON Transaction_Sale(customer_id);
CREATE INDEX idx_cart_customer ON Cart(customer_id);

-- Customers
INSERT INTO Customer VALUES (1, 'Alice Johnson', 'alice@example.com', 'alicej', 'hash123');
INSERT INTO Customer VALUES (2, 'Bob Smith', 'bob@example.com', 'bobsmith', 'hash456');

-- Vendors
INSERT INTO Vendor VALUES (1, 'Acme Suppliers');
INSERT INTO Vendor VALUES (2, 'Global Goods Inc.');

-- Brands
INSERT INTO Brand VALUES (1, 'FreshFarm', 1);
INSERT INTO Brand VALUES (2, 'TechNova', 2);

-- Product Types
INSERT INTO Product_Type VALUES (1, 'Food');
INSERT INTO Product_Type VALUES (2, 'Electronics');

-- Products
INSERT INTO Product 
VALUES (1, 'Organic Apples', 3.99, 120, 'Fresh red apples from local farms', 1, 1);

INSERT INTO Product 
VALUES (2, 'LED Monitor 24-inch', 149.99, 45, '1080p HD LED monitor', 2, 2);

INSERT INTO Product 
VALUES (3, 'Granola Bars (Pack of 12)', 7.49, 60, 'Assorted flavors', 1, 1);

-- Transactions
INSERT INTO Transaction_Sale (transaction_id, customer_id, amount)
VALUES (1, 1, 11.48);

INSERT INTO Transaction_Sale (transaction_id, customer_id, amount)
VALUES (2, 2, 149.99);

-- Line Items
INSERT INTO Line_Item VALUES (1, 1, 2);
INSERT INTO Line_Item VALUES (1, 3, 1);
INSERT INTO Line_Item VALUES (2, 2, 1);

-- Carts
INSERT INTO Cart (cart_id, customer_id) VALUES (1, 1);
INSERT INTO Cart (cart_id, customer_id) VALUES (2, 2);

-- Cart Items
INSERT INTO Cart_Item VALUES (1, 1, 3);
INSERT INTO Cart_Item VALUES (1, 3, 2);
INSERT INTO Cart_Item VALUES (2, 2, 1);
