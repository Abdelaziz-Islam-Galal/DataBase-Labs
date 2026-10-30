CREATE DATABASE IF NOT EXISTS `Order processing System`;
USE `Order processing System`;

CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE `order` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATETIME NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    unit_price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE order_item (
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES `order`(order_id),
    FOREIGN KEY (item_id) REFERENCES item(item_id)
);

CREATE TABLE warehouse (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_city VARCHAR(100) NOT NULL
);

CREATE TABLE shipment (
    order_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    ship_date DATETIME NOT NULL,
    PRIMARY KEY (order_id, warehouse_id),
    FOREIGN KEY (order_id) REFERENCES `order`(order_id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(warehouse_id)
);

-- ---------------------------------------------------------------------------

-- DELETE FROM customer;

-- DELETE FROM item;

-- DELETE FROM `order`;

-- DELETE FROM order_item;

-- DELETE FROM shipment;

-- DELETE FROM warehouse;

-- ---------------------------------------------------------------------------

SELECT customer_name 
FROM customer
WHERE customer_name LIKE 'Ma%';

SELECT order_item.order_id, 
       SUM(order_item.quantity) AS total_items_count, 
       SUM(order_item.quantity * item.unit_price) AS total_order_price
FROM order_item INNER JOIN item ON order_item.item_id = item.item_id
GROUP BY order_item.order_id;

SELECT shipment.order_id
FROM shipment INNER JOIN warehouse ON shipment.warehouse_id = warehouse.warehouse_id
WHERE warehouse.warehouse_city = 'Arica';

SELECT SUM(order_item.quantity * item.unit_price) AS total_order_price
FROM order_item 
INNER JOIN item ON order_item.item_id = item.item_id 
INNER JOIN shipment ON order_item.order_id = shipment.order_id WHERE shipment.warehouse_id = 8
-- (order_item INTERSECT item where order_item.item_id = item.item_id) INTERSECT shipment WHERE order_item.order_id = shipment.order_id
-- after the intersections filter the results by shipment.warehouse_id = 8