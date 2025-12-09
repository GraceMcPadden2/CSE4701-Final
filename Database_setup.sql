DROP TABLE Line_Item CASCADE CONSTRAINTS;
DROP TABLE Transaction_Sale CASCADE CONSTRAINTS;
DROP TABLE Product CASCADE CONSTRAINTS;
DROP TABLE Product_Type CASCADE CONSTRAINTS;
DROP TABLE Brand CASCADE CONSTRAINTS;
DROP TABLE Store CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;
DROP TABLE Vendor CASCADE CONSTRAINTS;
DROP TABLE Enterprise CASCADE CONSTRAINTS;
-- 2. Strong Entities

CREATE TABLE Enterprise (
    enterprise_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    headquarters_address VARCHAR2(255)
);

CREATE TABLE Vendor (
    vendor_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    address VARCHAR2(255),
    contact_info VARCHAR2(255)
);

CREATE TABLE Customer (
    customer_id NUMBER(10) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    password VARCHAR2(255) NOT NULL,
    username VARCHAR2(255) NOT NULL UNIQUE,
    phone VARCHAR2(20),
    loyalty_card_no VARCHAR2(50) UNIQUE
);

CREATE TABLE Store (
    store_id NUMBER(10) PRIMARY KEY,
    enterprise_id NUMBER(10) NOT NULL,
    address VARCHAR2(255),
    city VARCHAR2(50),
    state VARCHAR2(50),
    hours VARCHAR2(100),
    FOREIGN KEY (enterprise_id) REFERENCES Enterprise(enterprise_id)
);

CREATE TABLE Brand (
    brand_id NUMBER(10) PRIMARY KEY,
    vendor_id NUMBER(10) NOT NULL,
    name VARCHAR2(255) NOT NULL,
    description VARCHAR2(4000), 
    FOREIGN KEY (vendor_id) REFERENCES Vendor(vendor_id)
);

-- 3. Hierarchical Entity

CREATE TABLE Product_Type (
    type_id NUMBER(10) PRIMARY KEY,
    parent_type_id NUMBER(10), 
    type_name VARCHAR2(255) NOT NULL,
    FOREIGN KEY (parent_type_id) REFERENCES Product_Type(type_id)
);

-- 4. Product 

CREATE TABLE Product (
    product_id NUMBER(10) PRIMARY KEY,
    brand_id NUMBER(10) NOT NULL,
    type_id NUMBER(10) NOT NULL,
    name VARCHAR2(255) NOT NULL,
    -- Renamed 'size' to 'product_size'
    product_size VARCHAR2(50), 
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES Brand(brand_id),
    FOREIGN KEY (type_id) REFERENCES Product_Type(type_id)
);

-- 5. Transaction Entity

CREATE TABLE Transaction_Sale (
    transaction_id NUMBER(10) PRIMARY KEY,
    store_id NUMBER(10) NOT NULL,
    customer_id NUMBER(10) NOT NULL,
    -- Replaced DATETIME with DATE
    transaction_date DATE NOT NULL, 
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (store_id) REFERENCES Store(store_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- 7. Weak/Associative Entity (Line Item)

CREATE TABLE Line_Item (
    transaction_id NUMBER(10) NOT NULL,
    product_id NUMBER(10) NOT NULL,
    quantity NUMBER(10) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES Transaction_Sale(transaction_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Cart_Item (
    customer_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    PRIMARY KEY (customer_id, product_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);
--Insert Mock Enterprise Data--
INSERT INTO Enterprise VALUES (1, 'RetailCorp', '123 Corporate Way, NY');
INSERT INTO Enterprise VALUES (2, 'MegaStores', '889 Market St, CA');

--Insert Vendor Mock Data--
INSERT INTO Vendor VALUES (1, 'FreshFoods Inc.', '12 Farm Rd, IA', '555-1111');
INSERT INTO Vendor VALUES (2, 'TechSupply Co.', '89 Silicon Ave, CA', '555-2222');

--Insert Customer Mock Data--
INSERT INTO Customer VALUES (1, 'Alice Johnson', 'alice@example.com', '555-1001', 'LC1001');
INSERT INTO Customer VALUES (2, 'Bob Smith', 'bob@example.com', '555-1002', 'LC1002');
INSERT INTO Customer VALUES (3, 'Charlie Davis', 'charlie@example.com', '555-1003', 'LC1003');

--Insert Stores Mock Data--
INSERT INTO Store VALUES (1, 1, '101 Main St', 'New York', 'NY', '9am-9pm');
INSERT INTO Store VALUES (2, 1, '202 Broadway', 'Brooklyn', 'NY', '10am-8pm');
INSERT INTO Store VALUES (3, 2, '77 Market Ave', 'San Jose', 'CA', '9am-10pm');

--Insert Brands Mock Data--
INSERT INTO Brand VALUES (1, 1, 'FreshFarm', 'Organic grocery products');
INSERT INTO Brand VALUES (2, 2, 'TechPro', 'Consumer electronics');
INSERT INTO Brand VALUES (3, 1, 'NatureLife', 'Eco-friendly household goods');

--Insert Product Types (Hierarchy)
INSERT INTO Product_Type VALUES (1, NULL, 'Food');
INSERT INTO Product_Type VALUES (2, 1, 'Fruit');
INSERT INTO Product_Type VALUES (3, 1, 'Snacks');
INSERT INTO Product_Type VALUES (4, NULL, 'Electronics');
INSERT INTO Product_Type VALUES (5, 4, 'Headphones');

--Insert Products Mock Data--
INSERT INTO Product VALUES (1, 1, 2, 'Banana Bunch', '1 lb', 1.99);
INSERT INTO Product VALUES (2, 1, 3, 'Granola Bar', 'Single', 0.99);
INSERT INTO Product VALUES (3, 2, 5, 'TechPro Headphones', 'Standard', 49.99);
INSERT INTO Product VALUES (4, 3, 3, 'Organic Chips', 'Medium Bag', 2.49);
INSERT INTO Product VALUES (5, 3, 2, 'Organic Apples', '2 lb Bag', 3.99);

--Insert Transaction Date--
INSERT INTO Transaction_Sale VALUES (1, 1, 1, DATE '2024-01-15', 52.97);
INSERT INTO Transaction_Sale VALUES (2, 2, 2, DATE '2024-01-17', 4.48);
INSERT INTO Transaction_Sale VALUES (3, 3, 3, DATE '2024-01-18', 1.99);

--Insert Line Item (Weak Entity) Mock Data--
-- Transaction 1
INSERT INTO Line_Item VALUES (1, 3, 1, 49.99);  -- Headphones
INSERT INTO Line_Item VALUES (1, 4, 1, 2.49);   -- Organic Chips
INSERT INTO Line_Item VALUES (1, 1, 1, 1.99);   -- Banana

-- Transaction 2
INSERT INTO Line_Item VALUES (2, 5, 1, 3.99);   -- Organic Apples
INSERT INTO Line_Item VALUES (2, 2, 1, 0.49);   -- Granola Bar (discount example)

-- Transaction 3
INSERT INTO Line_Item VALUES (3, 1, 1, 1.99);   -- Banana

COMMIT;
