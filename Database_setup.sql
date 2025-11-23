-- PRODUCT TYPE
CREATE TABLE product_type (
    type_id        SERIAL PRIMARY KEY,
    parent_type_id INT,
    type_name      VARCHAR(100) NOT NULL,
    CONSTRAINT fk_product_type_parent
        FOREIGN KEY (parent_type_id)
        REFERENCES product_type(type_id)
);

-- BRAND
CREATE TABLE brand (
    brand_id   SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
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
