 -- Enterprise
CREATE TABLE Enterprise (
    enterprise_id        NUMBER PRIMARY KEY,
    name                 VARCHAR2(255) NOT NULL,
    headquarters_address VARCHAR2(255)
);

-- Vendor
CREATE TABLE VENDOR (
    vendor_id            NUMBER PRIMARY KEY,
    name                 VARCHAR2(255) NOT NULL,
    address              VARCHAR2(255),
    contact_info         VARCHAR2(255)
);

-- Store
CREATE TABLE STORE (
    store_id             NUMBER PRIMARY KEY,
    enterprise_id        NUMBER NOT NULL,
    vendor_id            NUMBER,
    address              VARCHAR2(255),
    city                 VARCHAR2(100),
    state                VARCHAR2(50),
    hours                VARCHAR2(255),

    CONSTRAINT fk_store_enterprise FOREIGN KEY (enterprise_id)
        REFERENCES Enterprise (enterprise_id),

    CONSTRAINT fk_store_vendor FOREIGN KEY (vendor_id)
        REFERENCES VENDOR (vendor_id)
);

CREATE INDEX idx_store_enterprise ON Store (enterprise_id);
CREATE INDEX idx_store_vendor ON Store (vendor_id);

 -- Brand
CREATE TABLE Brand (
    brand_id             NUMBER PRIMARY KEY,
    vendor_id            NUMBER NOT NULL,
    name                 VARCHAR2(255) NOT NULL,
    description          VARCHAR2(400),

    CONSTRAINT fk_brand_vendor FOREIGN KEY (vendor_id)
        REFERENCES Vendor (vendor_id)
);

CREATE INDEX idx_brand_vendor ON Brand (vendor_id);

-- PRODUCT TYPE
CREATE TABLE product_type (
    type_id        SERIAL PRIMARY KEY,
    parent_type_id INT,
    type_name      VARCHAR(100) NOT NULL,
    CONSTRAINT fk_product_type_parent
        FOREIGN KEY (parent_type_id)
        REFERENCES product_type(type_id)
);

-- PRODUCT
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    brand_id   INT NOT NULL,
    type_id    INT NOT NULL,
    name       VARCHAR(150) NOT NULL,
    size       VARCHAR(50),
    price      NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES brand(brand_id),
    FOREIGN KEY (type_id) REFERENCES product_type(type_id)
);

-- CUSTOMER
CREATE TABLE customer (
    customer_id     SERIAL PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    email           VARCHAR(150) UNIQUE,
    phone           VARCHAR(30),
    loyalty_card_no VARCHAR(50) UNIQUE
);

-- STORE
CREATE TABLE store (
    store_id   SERIAL PRIMARY KEY,
    name       VARCHAR(150) NOT NULL,
    address    VARCHAR(255),
    city       VARCHAR(100),
    state      VARCHAR(50),
    hours      VARCHAR(100)
);

-- TRANSACTION / SALE
CREATE TABLE transaction_sale (
    transaction_id   SERIAL PRIMARY KEY,
    store_id         INT NOT NULL,
    customer_id      INT,
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount     NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- MARKET BASKET / LINE ITEM
CREATE TABLE line_item (
    line_id        SERIAL PRIMARY KEY,
    transaction_id INT NOT NULL,
    product_id     INT NOT NULL,
    quantity       INT NOT NULL CHECK (quantity > 0),
    subtotal       NUMERIC(10,2) NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transaction_sale(transaction_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);
