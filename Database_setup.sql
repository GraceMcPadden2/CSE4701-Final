-- =========================================================
-- 1. DROP TABLES / VIEWS / INDEXES
-- =========================================================

DROP TABLE Line_Item CASCADE CONSTRAINTS;
DROP TABLE Transaction_Sale CASCADE CONSTRAINTS;
DROP TABLE Cart_Item CASCADE CONSTRAINTS;
DROP TABLE Product CASCADE CONSTRAINTS;
DROP TABLE Product_Type CASCADE CONSTRAINTS;
DROP TABLE Brand CASCADE CONSTRAINTS;
DROP TABLE Store CASCADE CONSTRAINTS;
DROP TABLE Employee CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;
DROP TABLE Vendor CASCADE CONSTRAINTS;
DROP TABLE Enterprise CASCADE CONSTRAINTS;

-- =========================================================
-- 2. CREATE TABLES
-- =========================================================
CREATE TABLE Enterprise (
    enterprise_id NUMBER(10) PRIMARY KEY,
    name VARCHAR(25) NOT NULL,
    headquarters VARCHAR2(70)
);

CREATE TABLE Vendor (
    vendor_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(70) NOT NULL,
    contact_email VARCHAR2(50)
);

CREATE TABLE Brand (
    brand_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(70) NOT NULL,
    vendor_id NUMBER(10) REFERENCES Vendor(vendor_id)
);

CREATE TABLE Store (
    store_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(70) NOT NULL,
    location VARCHAR2(70),
    max_capacity NUMBER(5),
    enterprise_id NUMBER(10) REFERENCES Enterprise(enterprise_id)
);
    
CREATE TABLE Customer (
    customer_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(70) NOT NULL,
    email VARCHAR2(70) UNIQUE NOT NULL,
    password VARCHAR2(255) NOT NULL
);

CREATE TABLE Product_Type (
    type_id NUMBER(10) PRIMARY KEY,
    name VARCHAR(70) NOT NULL
);

CREATE TABLE Product (
    product_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(70) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    stock NUMBER(10) DEFAULT 0,
    brand_id NUMBER(10) REFERENCES Brand(brand_id),
    type_id NUMBER(10) REFERENCES Product_Type(type_id)
);

CREATE INDEX idx_product_name ON Product(name);

CREATE TABLE Cart_Item (
    customer_id NUMBER(10) REFERENCES Customer(customer_id),
    product_id NUMBER(10) REFERENCES Product(product_id),
    quantity NUMBER(5) DEFAULT 1,
    PRIMARY KEY (customer_id, product_id)
);

CREATE TABLE Transaction_Sale (
    transaction_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10) REFERENCES Customer(customer_id),
    store_id NUMBER(10) REFERENCES Store(store_id),
    total_amount NUMBER(10,2),
    transaction_date DATE DEFAULT SYSDATE
);

CREATE INDEX idx_tsale_store ON Transaction_Sale(store_id);

CREATE TABLE Line_Item (
    transaction_id NUMBER(10) REFERENCES Transaction_Sale(transaction_id),
    product_id NUMBER(10) REFERENCES Product(product_id),
    quantity NUMBER(5) DEFAULT 1,
    price NUMBER(10,2),
    PRIMARY KEY (transaction_id, product_id)
);

CREATE OR REPLACE VIEW Purchase_History_V AS
SELECT c.customer_id, c.name AS customer_name, t.transaction_id, t.transaction_date, 
       p.product_id, p.name AS product_name, l.quantity, l.price
FROM Customer c
JOIN Transaction_Sale t ON c.customer_id = t.customer_id
JOIN Line_Item l ON t.transaction_id = l.transaction_id
JOIN Product p ON l.product_id = p.product_id;

CREATE OR REPLACE VIEW Cart_Summary_V AS
SELECT c.customer_id, c.name AS customer_name, p.product_id, p.name AS product_name, ci.quantity, p.price
FROM Customer c
JOIN Cart_Item ci ON c.customer_id = ci.customer_id
JOIN Product p ON ci.product_id = p.product_id;

INSERT INTO Enterprise VALUES (1,'RetailCorp','New York');
INSERT INTO Vendor VALUES (1,'BestVendor','vendor1@retail.com');
INSERT INTO Vendor VALUES (2,'QualitySupplier','vendor2@retail.com');
INSERT INTO Brand VALUES (1,'BrandA',1);
INSERT INTO Brand VALUES (2,'BrandB',2);
INSERT INTO Store VALUES (1,'Downtown Store','NYC',100,1);
INSERT INTO Store VALUES (2,'Uptown Store','NYC',150,1);
INSERT INTO Product_Type VALUES (1,'Electronics');
INSERT INTO Product_Type VALUES (2,'Books');
INSERT INTO Product VALUES (1,'Laptop',1000,50,1,1);
INSERT INTO Product VALUES (2,'Headphones',100,200,1,1);
INSERT INTO Product VALUES (3,'Book - SQL Basics',25,300,2,2);
INSERT INTO Customer VALUES (1,'Alice Smith','alice@example.com','alice123');
INSERT INTO Customer VALUES (2,'Bob Johnson','bob@example.com','bob123');
INSERT INTO Cart_Item VALUES (1,1,1);
INSERT INTO Cart_Item VALUES (1,3,2);
INSERT INTO Cart_Item VALUES (2,2,1);
INSERT INTO Transaction_Sale VALUES (1,1,1,1050,SYSDATE);
INSERT INTO Transaction_Sale VALUES (2,2,2,100,SYSDATE);
INSERT INTO Line_Item VALUES (1,1,1,1000);
INSERT INTO Line_Item VALUES (1,3,2,50);
INSERT INTO Line_Item VALUES (2,2,1,100);

COMMIT;

