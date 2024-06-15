-- Create database and use it
CREATE DATABASE IF NOT EXISTS opt_db;
USE opt_db;

-- Create opt_clients table
CREATE TABLE IF NOT EXISTS opt_clients (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    status ENUM('active', 'inactive') NOT NULL
);

-- Create opt_products table
CREATE TABLE IF NOT EXISTS opt_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_category ENUM('Category1', 'Category2', 'Category3', 'Category4', 'Category5') NOT NULL,
    description TEXT
);

-- Create opt_orders table
CREATE TABLE IF NOT EXISTS opt_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    client_id CHAR(36),
    product_id INT,
    FOREIGN KEY (client_id) REFERENCES opt_clients(id),
    FOREIGN KEY (product_id) REFERENCES opt_products(product_id)
);


-- Old one
SELECT 
    p.product_name,
    p.product_category,
    COUNT(*) AS total_quantity
FROM 
    opt_orders o
JOIN 
    opt_clients c ON o.client_id = c.id
JOIN 
    opt_products p ON o.product_id = p.product_id
WHERE 
    c.email = 'williamthompson@example.net'
    AND YEAR(o.order_date) in (
    select Max(YEAR(o.order_date)) from opt_orders o 
    where YEAR(o.order_date) < (select Max(YEAR(o.order_date)) from opt_orders o))
GROUP BY 
    p.product_name, p.product_category;

   
   


-- New one
   
DROP INDEX idx_email ON opt_clients;
CREATE index idx_email on opt_clients(email);

DROP INDEX idx_date ON opt_orders;
CREATE index idx_date on opt_orders(order_date);

WITH max_year AS (
    SELECT MAX(YEAR(order_date)) AS max_year
    FROM opt_orders
),
client_info AS (
    SELECT id
    FROM opt_clients
    WHERE email = 'williamthompson@example.net'
)
SELECT 
    p.product_name,
    p.product_category,
    COUNT(*) AS total_quantity
FROM 
    opt_orders o
JOIN 
    client_info c ON o.client_id = c.id
JOIN 
    opt_products p ON o.product_id = p.product_id
WHERE 
    YEAR(o.order_date) = (SELECT max_year - 1 FROM max_year)
GROUP BY 
    p.product_name, p.product_category;














   
