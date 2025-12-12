DROP TABLE Line_Item CASCADE CONSTRAINTS;
DROP TABLE Transaction_Sale CASCADE CONSTRAINTS;
DROP TABLE Product CASCADE CONSTRAINTS;
DROP TABLE Product_Type CASCADE CONSTRAINTS;
DROP TABLE Brand CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;
DROP TABLE Vendor CASCADE CONSTRAINTS;
DROP TABLE Cart_Item CASCADE CONSTRAINTS;


DROP SEQUENCE customer_seq;
DROP SEQUENCE transaction_seq;
DROP SEQUENCE enterprise_seq;
DROP SEQUENCE product_seq;
DROP SEQUENCE product_type_seq;

--Sequences
CREATE SEQUENCE customer_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE transaction_seq
START WITH 1
INCREMENT BY 1;


CREATE SEQUENCE enterprise_seq
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE product_seq
START WITH 1
INCREMENT BY 1;


CREATE SEQUENCE product_type_seq
START WITH 1
INCREMENT BY 1;


--Vendor
CREATE TABLE Vendor (
    vendor_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL
);

--Customer
CREATE TABLE Customer (
    customer_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    username VARCHAR2(255) NOT NULL UNIQUE,
    password VARCHAR2(255) NOT NULL,
    email VARCHAR2(20)
);

--Brand
CREATE TABLE Brand (
    brand_id NUMBER(10) PRIMARY KEY,
    vendor_id NUMBER(10) NOT NULL,
    name VARCHAR2(255) NOT NULL,
    FOREIGN KEY (vendor_id) REFERENCES Vendor(vendor_id)
);

--Product Type
CREATE TABLE Product_Type (
    type_id NUMBER(10) PRIMARY KEY,
    type_name VARCHAR2(255) NOT NULL    
);

-- Product
CREATE TABLE Product (
    product_id NUMBER(10) PRIMARY KEY,
    product_name VARCHAR2(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock NUMBER(10) NOT NULL,
    description VARCHAR2(255),
    brand_id NUMBER(10) NOT NULL,
    type_id NUMBER(10) NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES Brand(brand_id),
    FOREIGN KEY (type_id) REFERENCES Product_Type(type_id)
);

-- Transaction_sale
CREATE TABLE Transaction_sale (
    transaction_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10) NOT NULL,
    transaction_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- Line Item (weak entity)
CREATE TABLE Line_item (
    transaction_id NUMBER(10) NOT NULL,
    product_id NUMBER(10) NOT NULL,
    quantity NUMBER(10) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES Transaction_Sale(transaction_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Cart Item (weak entity)
CREATE TABLE Cart_Item (
    customer_id NUMBER(10) NOT NULL,
    product_id NUMBER(10) NOT NULL,
    quantity NUMBER(10) NOT NULL,
    PRIMARY KEY (customer_id, product_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);


--AI GENERATED DATA
/* ===========================
   VENDORS
   =========================== */
INSERT INTO Vendor (vendor_id, name) VALUES (1, 'Global Foods Inc');
INSERT INTO Vendor (vendor_id, name) VALUES (2, 'TechGear Supply');
INSERT INTO Vendor (vendor_id, name) VALUES (3, 'Home Essentials Co');

/* ===========================
   CUSTOMERS
   =========================== */
INSERT INTO Customer (customer_id, name, username, password, email)
VALUES (customer_seq.NEXTVAL, 'Alice Johnson', 'alicej', 'pass123', 'alice@shop.com');

INSERT INTO Customer (customer_id, name, username, password, email)
VALUES (customer_seq.NEXTVAL, 'Bob Smith', 'bobsmith', 'secure456', 'bob@shop.com');

INSERT INTO Customer (customer_id, name, username, password, email)
VALUES (customer_seq.NEXTVAL, 'Carol White', 'carolw', 'mypassword', 'carol@shop.com');

/* ===========================
   BRANDS
   =========================== */
INSERT INTO Brand (brand_id, vendor_id, name)
VALUES (1, 1, 'FreshFarm');

INSERT INTO Brand (brand_id, vendor_id, name)
VALUES (2, 2, 'UltraTech');

INSERT INTO Brand (brand_id, vendor_id, name)
VALUES (3, 3, 'CozyHome');

/* ===========================
   PRODUCT TYPES
   =========================== */
INSERT INTO Product_Type (type_id, type_name)
VALUES (product_type_seq.NEXTVAL, 'Food');

INSERT INTO Product_Type (type_id, type_name)
VALUES (product_type_seq.NEXTVAL, 'Electronics');

INSERT INTO Product_Type (type_id, type_name)
VALUES (product_type_seq.NEXTVAL, 'Home Goods');

/* ===========================
   PRODUCTS
   =========================== */
INSERT INTO Product
SELECT product_seq.NEXTVAL,
       'Organic Apples',
       3.99,
       100,
       'Fresh organic apples',
       1,
       pt.type_id
FROM Product_Type pt
WHERE pt.type_name = 'Food';

INSERT INTO Product
SELECT product_seq.NEXTVAL,
       'Wireless Headphones',
       89.99,
       50,
       'Noise cancelling headphones',
       2,
       pt.type_id
FROM Product_Type pt
WHERE pt.type_name = 'Electronics';

INSERT INTO Product
SELECT product_seq.NEXTVAL,
       'Throw Blanket',
       24.99,
       75,
       'Soft fleece blanket',
       3,
       pt.type_id
FROM Product_Type pt
WHERE pt.type_name = 'Home Goods';

/* ===========================
   TRANSACTIONS
   =========================== */
INSERT INTO Transaction_Sale
SELECT transaction_seq.NEXTVAL,
       c.customer_id,
       SYSDATE,
       97.97
FROM Customer c
WHERE c.username = 'alicej';

INSERT INTO Transaction_Sale
SELECT transaction_seq.NEXTVAL,
       c.customer_id,
       SYSDATE - 1,
       24.99
FROM Customer c
WHERE c.username = 'bobsmith';

/* ===========================
   LINE ITEMS
   =========================== */
INSERT INTO Line_Item
SELECT t.transaction_id,
       p.product_id,
       5,
       19.95
FROM Transaction_Sale t
JOIN Customer c ON t.customer_id = c.customer_id
JOIN Product p ON p.product_name = 'Organic Apples'
WHERE c.username = 'alicej';

INSERT INTO Line_Item
SELECT t.transaction_id,
       p.product_id,
       1,
       89.99
FROM Transaction_Sale t
JOIN Customer c ON t.customer_id = c.customer_id
JOIN Product p ON p.product_name = 'Wireless Headphones'
WHERE c.username = 'alicej';

INSERT INTO Line_Item
SELECT t.transaction_id,
       p.product_id,
       1,
       24.99
FROM Transaction_Sale t
JOIN Customer c ON t.customer_id = c.customer_id
JOIN Product p ON p.product_name = 'Throw Blanket'
WHERE c.username = 'bobsmith';

/* ===========================
   CART ITEMS
   =========================== */
INSERT INTO Cart_Item
SELECT c.customer_id,
       p.product_id,
       1
FROM Customer c
JOIN Product p ON p.product_name = 'Wireless Headphones'
WHERE c.username = 'carolw';

INSERT INTO Cart_Item
SELECT c.customer_id,
       p.product_id,
       3
FROM Customer c
JOIN Product p ON p.product_name = 'Organic Apples'
WHERE c.username = 'bobsmith';

COMMIT;
