-- ============================================================
--   RESTAURANT MANAGEMENT SYSTEM
--   Database: MySQL / PostgreSQL Compatible
-- ============================================================

-- ============================================================
-- 1. DATABASE CREATION
-- ============================================================
CREATE DATABASE IF NOT EXISTS RestaurantDB;
USE RestaurantDB;

-- ============================================================
-- 2. TABLE CREATION (DDL)
-- ============================================================

-- 2.1 Employees
CREATE TABLE Employee (
    emp_id       INT PRIMARY KEY AUTO_INCREMENT,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    role         VARCHAR(30)  NOT NULL,    -- Manager, Waiter, Chef, Cashier, etc.
    phone        VARCHAR(15)  UNIQUE,
    email        VARCHAR(100) UNIQUE,
    hire_date    DATE         NOT NULL,
    salary       DECIMAL(10,2) NOT NULL,
    shift        ENUM('Morning','Evening','Night') NOT NULL
);

-- 2.2 Tables in the restaurant
CREATE TABLE RestaurantTable (
    table_id     INT PRIMARY KEY AUTO_INCREMENT,
    table_number INT          NOT NULL UNIQUE,
    capacity     INT          NOT NULL,
    location     VARCHAR(30)  DEFAULT 'Indoor',   -- Indoor / Outdoor / Private
    status       ENUM('Available','Occupied','Reserved') DEFAULT 'Available'
);

-- 2.3 Menu Categories
CREATE TABLE Category (
    category_id   INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description   VARCHAR(200)
);

-- 2.4 Menu Items
CREATE TABLE MenuItem (
    item_id       INT PRIMARY KEY AUTO_INCREMENT,
    item_name     VARCHAR(100) NOT NULL,
    category_id   INT          NOT NULL,
    price         DECIMAL(8,2) NOT NULL,
    description   VARCHAR(255),
    is_available  BOOLEAN      DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- 2.5 Customers
CREATE TABLE Customer (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    phone         VARCHAR(15) UNIQUE,
    email         VARCHAR(100) UNIQUE,
    loyalty_points INT        DEFAULT 0,
    registered_on  DATE
);

-- 2.6 Reservations
CREATE TABLE Reservation (
    reservation_id  INT PRIMARY KEY AUTO_INCREMENT,
    customer_id     INT  NOT NULL,
    table_id        INT  NOT NULL,
    reserved_date   DATE NOT NULL,
    reserved_time   TIME NOT NULL,
    party_size      INT  NOT NULL,
    status          ENUM('Confirmed','Cancelled','Completed') DEFAULT 'Confirmed',
    special_request VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (table_id)    REFERENCES RestaurantTable(table_id)
);

-- 2.7 Orders
CREATE TABLE Orders (
    order_id     INT PRIMARY KEY AUTO_INCREMENT,
    customer_id  INT,
    table_id     INT          NOT NULL,
    emp_id       INT          NOT NULL,   -- Waiter who took the order
    order_date   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status       ENUM('Pending','Preparing','Served','Paid','Cancelled') DEFAULT 'Pending',
    order_type   ENUM('Dine-In','Takeaway','Delivery') DEFAULT 'Dine-In',
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (table_id)    REFERENCES RestaurantTable(table_id),
    FOREIGN KEY (emp_id)      REFERENCES Employee(emp_id)
);

-- 2.8 Order Details (Items in an order)
CREATE TABLE OrderDetail (
    detail_id    INT PRIMARY KEY AUTO_INCREMENT,
    order_id     INT          NOT NULL,
    item_id      INT          NOT NULL,
    quantity     INT          NOT NULL DEFAULT 1,
    unit_price   DECIMAL(8,2) NOT NULL,
    special_note VARCHAR(200),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (item_id)  REFERENCES MenuItem(item_id)
);

-- 2.9 Payments
CREATE TABLE Payment (
    payment_id     INT PRIMARY KEY AUTO_INCREMENT,
    order_id       INT          NOT NULL UNIQUE,
    payment_date   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount         DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Cash','Card','UPI','Online') NOT NULL,
    discount       DECIMAL(5,2) DEFAULT 0.00,
    tax            DECIMAL(5,2) DEFAULT 5.00,   -- in percent
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- 2.10 Inventory
CREATE TABLE Inventory (
    ingredient_id  INT PRIMARY KEY AUTO_INCREMENT,
    ingredient_name VARCHAR(100) NOT NULL UNIQUE,
    quantity        DECIMAL(10,2) NOT NULL DEFAULT 0,
    unit            VARCHAR(20)  NOT NULL,   -- kg, liters, pieces
    reorder_level   DECIMAL(10,2) NOT NULL,
    supplier_name   VARCHAR(100),
    last_updated    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2.11 Suppliers
CREATE TABLE Supplier (
    supplier_id   INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name  VARCHAR(100),
    phone         VARCHAR(15),
    email         VARCHAR(100),
    address       VARCHAR(255)
);

-- 2.12 Feedback
CREATE TABLE Feedback (
    feedback_id   INT PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT,
    order_id      INT,
    rating        INT CHECK (rating BETWEEN 1 AND 5),
    comments      TEXT,
    feedback_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (order_id)    REFERENCES Orders(order_id)
);

-- ============================================================
-- 3. SAMPLE DATA (DML - INSERT)
-- ============================================================

INSERT INTO Employee (first_name, last_name, role, phone, email, hire_date, salary, shift) VALUES
('Rajesh',  'Kumar',  'Manager',  '9000000001', 'rajesh.k@restaurant.com',  '2020-01-15', 55000.00, 'Morning'),
('Priya',   'Sharma', 'Chef',     '9000000002', 'priya.s@restaurant.com',   '2021-03-20', 40000.00, 'Morning'),
('Anil',    'Verma',  'Waiter',   '9000000003', 'anil.v@restaurant.com',    '2022-06-01', 22000.00, 'Evening'),
('Sunita',  'Rao',    'Waiter',   '9000000004', 'sunita.r@restaurant.com',  '2022-08-15', 22000.00, 'Morning'),
('Deepak',  'Nair',   'Chef',     '9000000005', 'deepak.n@restaurant.com',  '2021-11-10', 38000.00, 'Evening'),
('Meena',   'Patel',  'Cashier',  '9000000006', 'meena.p@restaurant.com',   '2023-01-05', 25000.00, 'Morning'),
('Rohit',   'Singh',  'Waiter',   '9000000007', 'rohit.s@restaurant.com',   '2023-04-12', 21000.00, 'Night'),
('Kavita',  'Joshi',  'Manager',  '9000000008', 'kavita.j@restaurant.com',  '2019-07-22', 58000.00, 'Evening');

INSERT INTO RestaurantTable (table_number, capacity, location, status) VALUES
(1,  2, 'Indoor',  'Available'),
(2,  4, 'Indoor',  'Occupied'),
(3,  4, 'Indoor',  'Available'),
(4,  6, 'Outdoor', 'Reserved'),
(5,  6, 'Outdoor', 'Available'),
(6,  8, 'Private', 'Available'),
(7,  2, 'Indoor',  'Occupied'),
(8,  4, 'Indoor',  'Available'),
(9, 10, 'Private', 'Reserved'),
(10, 4, 'Outdoor', 'Available');

INSERT INTO Category (category_name, description) VALUES
('Starters',   'Appetizers and soups'),
('Main Course','Rice, Biryani, Curries, and Breads'),
('Beverages',  'Hot and cold drinks'),
('Desserts',   'Sweets and ice creams'),
('Fast Food',  'Burgers, Sandwiches, and Fries');

INSERT INTO MenuItem (item_name, category_id, price, description, is_available) VALUES
('Veg Spring Roll',      1, 120.00, 'Crispy spring rolls with veggies',       TRUE),
('Chicken Soup',         1, 150.00, 'Hot and spicy chicken broth',            TRUE),
('Paneer Tikka',         1, 200.00, 'Grilled cottage cheese with spices',     TRUE),
('Chicken Biryani',      2, 320.00, 'Fragrant Hyderabadi biryani',            TRUE),
('Dal Makhani',          2, 180.00, 'Slow cooked black lentils',              TRUE),
('Butter Naan',          2,  40.00, 'Soft tandoor bread with butter',         TRUE),
('Veg Fried Rice',       2, 160.00, 'Wok-fried rice with vegetables',         TRUE),
('Cold Coffee',          3,  90.00, 'Blended coffee with ice cream',          TRUE),
('Fresh Lime Soda',      3,  60.00, 'Fresh lime with sparkling soda',         TRUE),
('Mango Lassi',          3,  80.00, 'Yogurt drink with mango pulp',           TRUE),
('Gulab Jamun',          4, 100.00, 'Deep fried milk dumplings in syrup',     TRUE),
('Ice Cream (2 scoops)', 4, 120.00, 'Choice of vanilla, chocolate, mango',   TRUE),
('Veg Burger',           5, 130.00, 'Burger with grilled veggie patty',       TRUE),
('Chicken Sandwich',     5, 160.00, 'Grilled chicken with lettuce & mayo',    TRUE),
('French Fries',         5,  80.00, 'Crispy golden salted fries',             TRUE);

INSERT INTO Customer (first_name, last_name, phone, email, loyalty_points, registered_on) VALUES
('Arjun',   'Reddy',   '8100000001', 'arjun.r@gmail.com',   150, '2022-03-10'),
('Sneha',   'Kulkarni','8100000002', 'sneha.k@gmail.com',   200, '2022-07-05'),
('Mohan',   'Das',     '8100000003', 'mohan.d@gmail.com',    50, '2023-01-20'),
('Lakshmi', 'Iyer',    '8100000004', 'lakshmi.i@gmail.com', 320, '2021-11-15'),
('Vikram',  'Choudhary','8100000005','vikram.c@gmail.com',   80, '2023-05-08'),
('Pooja',   'Mehta',   '8100000006', 'pooja.m@gmail.com',   500, '2020-09-22'),
('Suresh',  'Babu',    '8100000007', 'suresh.b@gmail.com',  120, '2022-12-01'),
('Ananya',  'Pillai',  '8100000008', 'ananya.p@gmail.com',  250, '2023-02-14');

INSERT INTO Reservation (customer_id, table_id, reserved_date, reserved_time, party_size, status, special_request) VALUES
(1, 4, '2024-06-10', '19:00:00', 4, 'Confirmed',  'Window seat preferred'),
(2, 9, '2024-06-11', '20:00:00', 8, 'Confirmed',  'Birthday decoration please'),
(3, 1, '2024-06-12', '13:00:00', 2, 'Cancelled',  NULL),
(4, 6, '2024-06-13', '21:00:00', 5, 'Completed',  'Vegetarian menu only'),
(5, 3, '2024-06-14', '18:30:00', 3, 'Confirmed',  NULL),
(6, 4, '2024-06-14', '12:00:00', 6, 'Completed',  'Anniversary surprise');

INSERT INTO Orders (customer_id, table_id, emp_id, order_date, status, order_type) VALUES
(1,  2, 3, '2024-06-10 19:15:00', 'Paid',      'Dine-In'),
(2,  7, 4, '2024-06-11 20:10:00', 'Paid',      'Dine-In'),
(3,  3, 3, '2024-06-12 13:05:00', 'Paid',      'Dine-In'),
(4,  6, 7, '2024-06-13 21:00:00', 'Paid',      'Dine-In'),
(5,  2, 4, '2024-06-14 18:35:00', 'Served',    'Dine-In'),
(6,  4, 3, '2024-06-14 12:05:00', 'Paid',      'Dine-In'),
(7,  8, 4, '2024-06-15 14:00:00', 'Preparing', 'Takeaway'),
(8,  1, 7, '2024-06-15 19:00:00', 'Pending',   'Dine-In'),
(NULL,3, 3, '2024-06-15 10:30:00', 'Paid',     'Takeaway'),
(1,  7, 4, '2024-06-15 20:00:00', 'Paid',      'Dine-In');

INSERT INTO OrderDetail (order_id, item_id, quantity, unit_price, special_note) VALUES
(1, 4,  1, 320.00, NULL),
(1, 6,  2,  40.00, NULL),
(1, 8,  1,  90.00, NULL),
(2, 3,  2, 200.00, 'Less spicy'),
(2, 7,  1, 160.00, NULL),
(2, 10, 2,  80.00, NULL),
(3, 1,  2, 120.00, NULL),
(3, 9,  2,  60.00, NULL),
(4, 5,  2, 180.00, NULL),
(4, 6,  4,  40.00, NULL),
(4, 11, 2, 100.00, NULL),
(5, 4,  2, 320.00, 'Extra rice'),
(5, 13, 1, 130.00, NULL),
(6, 4,  3, 320.00, NULL),
(6, 6,  3,  40.00, NULL),
(6, 12, 2, 120.00, NULL),
(7, 14, 2, 160.00, NULL),
(7, 15, 2,  80.00, NULL),
(8, 2,  1, 150.00, NULL),
(8, 3,  1, 200.00, NULL),
(9, 13, 2, 130.00, NULL),
(9, 15, 1,  80.00, NULL),
(10,4,  1, 320.00, NULL),
(10,11, 1, 100.00, NULL);

INSERT INTO Payment (order_id, payment_date, amount, payment_method, discount, tax) VALUES
(1, '2024-06-10 20:30:00', 510.00, 'UPI',    0.00, 5.00),
(2, '2024-06-11 21:45:00', 770.00, 'Card',   5.00, 5.00),
(3, '2024-06-12 14:00:00', 378.00, 'Cash',   0.00, 5.00),
(4, '2024-06-13 22:30:00', 620.00, 'Card',  10.00, 5.00),
(6, '2024-06-14 13:30:00',1134.00, 'UPI',    0.00, 5.00),
(9, '2024-06-15 11:00:00', 357.00, 'Cash',   0.00, 5.00),
(10,'2024-06-15 21:00:00', 441.00, 'Online', 0.00, 5.00);

INSERT INTO Inventory (ingredient_name, quantity, unit, reorder_level, supplier_name) VALUES
('Chicken',       20.00,  'kg',     5.00,  'Fresh Farms'),
('Rice',          50.00,  'kg',    10.00,  'Grain Suppliers'),
('Milk',          15.00,  'liters', 5.00,  'Dairy Fresh'),
('Paneer',         8.00,  'kg',     2.00,  'Dairy Fresh'),
('Onions',        10.00,  'kg',     3.00,  'Veggie World'),
('Tomatoes',       8.00,  'kg',     3.00,  'Veggie World'),
('Cooking Oil',   20.00,  'liters', 5.00,  'Oil Depot'),
('Flour',         25.00,  'kg',     5.00,  'Grain Suppliers'),
('Sugar',         10.00,  'kg',     3.00,  'Sweet Mart'),
('Coffee Powder',  2.00,  'kg',     0.50,  'Brew House');

INSERT INTO Supplier (supplier_name, contact_name, phone, email, address) VALUES
('Fresh Farms',      'Ramesh Babu',   '7700000001', 'fresh@farms.com',    'Kurnool Market'),
('Grain Suppliers',  'Sanjay Gupta',  '7700000002', 'grain@supply.com',   'Hyderabad Mandi'),
('Dairy Fresh',      'Lakshman Rao',  '7700000003', 'dairy@fresh.com',    'Nandyal Road'),
('Veggie World',     'Padma Devi',    '7700000004', 'veggie@world.com',   'Local Market'),
('Oil Depot',        'Suresh Nair',   '7700000005', 'oil@depot.com',      'Industrial Area'),
('Brew House',       'Kiran Mehta',   '7700000006', 'brew@house.com',     'City Center');

INSERT INTO Feedback (customer_id, order_id, rating, comments, feedback_date) VALUES
(1, 1, 5, 'Excellent biryani! Will definitely come back.',     '2024-06-10 21:00:00'),
(2, 2, 4, 'Good food, slightly long wait time.',               '2024-06-11 22:00:00'),
(3, 3, 3, 'Average experience, could be better.',              '2024-06-12 14:30:00'),
(4, 4, 5, 'Loved the ambiance and food quality.',              '2024-06-13 23:00:00'),
(6, 6, 5, 'Perfect anniversary dinner, great service!',        '2024-06-14 14:00:00'),
(7, 9, 4, 'Takeaway was packed well, food was fresh.',         '2024-06-15 11:30:00');

-- ============================================================
-- 4. QUERIES
-- ============================================================

-- -----------------------------------------------
-- 4.1 BASIC SELECT QUERIES
-- -----------------------------------------------

-- Q1: List all menu items with category name
SELECT m.item_id, m.item_name, c.category_name, m.price, m.is_available
FROM MenuItem m
JOIN Category c ON m.category_id = c.category_id
ORDER BY c.category_name, m.price;

-- Q2: List all available menu items only
SELECT item_name, price
FROM MenuItem
WHERE is_available = TRUE
ORDER BY price;

-- Q3: View all current reservations (Confirmed only)
SELECT r.reservation_id, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       t.table_number, r.reserved_date, r.reserved_time, r.party_size, r.special_request
FROM Reservation r
JOIN Customer c ON r.customer_id = c.customer_id
JOIN RestaurantTable t ON r.table_id = t.table_id
WHERE r.status = 'Confirmed'
ORDER BY r.reserved_date, r.reserved_time;

-- Q4: Show all orders with customer and waiter details
SELECT o.order_id, CONCAT(c.first_name,' ',c.last_name) AS customer,
       t.table_number,
       CONCAT(e.first_name,' ',e.last_name) AS waiter,
       o.order_date, o.status, o.order_type
FROM Orders o
LEFT JOIN Customer c ON o.customer_id = c.customer_id
JOIN RestaurantTable t ON o.table_id = t.table_id
JOIN Employee e ON o.emp_id = e.emp_id
ORDER BY o.order_date DESC;

-- Q5: View full order details (items in each order)
SELECT o.order_id, m.item_name, od.quantity, od.unit_price,
       (od.quantity * od.unit_price) AS subtotal, od.special_note
FROM OrderDetail od
JOIN Orders o ON od.order_id = o.order_id
JOIN MenuItem m ON od.item_id = m.item_id
ORDER BY o.order_id;

-- -----------------------------------------------
-- 4.2 AGGREGATE & GROUP BY QUERIES
-- -----------------------------------------------

-- Q6: Total revenue per day
SELECT DATE(payment_date) AS sale_date,
       COUNT(*) AS total_orders,
       SUM(amount) AS total_revenue
FROM Payment
GROUP BY DATE(payment_date)
ORDER BY sale_date;

-- Q7: Total revenue by payment method
SELECT payment_method,
       COUNT(*) AS transactions,
       SUM(amount) AS total_amount
FROM Payment
GROUP BY payment_method
ORDER BY total_amount DESC;

-- Q8: Most ordered menu items (by quantity)
SELECT m.item_name, SUM(od.quantity) AS total_ordered, SUM(od.quantity * od.unit_price) AS revenue
FROM OrderDetail od
JOIN MenuItem m ON od.item_id = m.item_id
GROUP BY m.item_id, m.item_name
ORDER BY total_ordered DESC;

-- Q9: Revenue by category
SELECT c.category_name,
       SUM(od.quantity * od.unit_price) AS category_revenue
FROM OrderDetail od
JOIN MenuItem m ON od.item_id = m.item_id
JOIN Category c ON m.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY category_revenue DESC;

-- Q10: Average rating per order type
SELECT o.order_type, AVG(f.rating) AS avg_rating, COUNT(f.feedback_id) AS reviews
FROM Feedback f
JOIN Orders o ON f.order_id = o.order_id
GROUP BY o.order_type;

-- Q11: Employee performance (orders handled per waiter)
SELECT CONCAT(e.first_name,' ',e.last_name) AS waiter_name,
       e.role, COUNT(o.order_id) AS orders_handled
FROM Employee e
LEFT JOIN Orders o ON e.emp_id = o.emp_id
GROUP BY e.emp_id
ORDER BY orders_handled DESC;

-- -----------------------------------------------
-- 4.3 JOINS
-- -----------------------------------------------

-- Q12: Customers with their total spending (INNER JOIN)
SELECT CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       COUNT(o.order_id) AS total_orders,
       SUM(p.amount) AS total_spent
FROM Customer c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Payment p ON o.order_id = p.order_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- Q13: Orders with no payment yet (LEFT JOIN)
SELECT o.order_id, o.order_date, o.status,
       CONCAT(c.first_name,' ',c.last_name) AS customer
FROM Orders o
LEFT JOIN Payment p ON o.order_id = p.order_id
LEFT JOIN Customer c ON o.customer_id = c.customer_id
WHERE p.payment_id IS NULL;

-- Q14: Tables currently occupied with ongoing orders
SELECT t.table_number, t.capacity, t.location,
       o.order_id, o.order_date, o.status
FROM RestaurantTable t
JOIN Orders o ON t.table_id = o.table_id
WHERE t.status = 'Occupied';

-- Q15: Inventory items below reorder level
SELECT ingredient_name, quantity, unit, reorder_level, supplier_name
FROM Inventory
WHERE quantity <= reorder_level;

-- -----------------------------------------------
-- 4.4 SUBQUERIES
-- -----------------------------------------------

-- Q16: Find customers who spent more than the average spending
SELECT CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       SUM(p.amount) AS total_spent
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payment p ON o.order_id = p.order_id
GROUP BY c.customer_id
HAVING total_spent > (
    SELECT AVG(total_per_customer)
    FROM (
        SELECT SUM(p2.amount) AS total_per_customer
        FROM Orders o2
        JOIN Payment p2 ON o2.order_id = p2.order_id
        WHERE o2.customer_id IS NOT NULL
        GROUP BY o2.customer_id
    ) sub
);

-- Q17: Most expensive item in each category
SELECT c.category_name, m.item_name, m.price
FROM MenuItem m
JOIN Category c ON m.category_id = c.category_id
WHERE m.price = (
    SELECT MAX(price)
    FROM MenuItem
    WHERE category_id = m.category_id
)
ORDER BY c.category_name;

-- Q18: Customers who have never given feedback
SELECT CONCAT(first_name,' ',last_name) AS customer_name, email
FROM Customer
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id FROM Feedback WHERE customer_id IS NOT NULL
);

-- Q19: Items that have never been ordered
SELECT item_name, price
FROM MenuItem
WHERE item_id NOT IN (SELECT DISTINCT item_id FROM OrderDetail);

-- -----------------------------------------------
-- 4.5 UPDATE QUERIES
-- -----------------------------------------------

-- Q20: Mark an order as Paid
UPDATE Orders SET status = 'Paid' WHERE order_id = 5;

-- Q21: Update table status to Available after customer leaves
UPDATE RestaurantTable SET status = 'Available' WHERE table_id = 2;

-- Q22: Increase salary by 10% for all chefs
UPDATE Employee SET salary = salary * 1.10 WHERE role = 'Chef';

-- Q23: Deactivate an unavailable menu item
UPDATE MenuItem SET is_available = FALSE WHERE item_id = 2;

-- Q24: Add loyalty points to a customer (10 points per 100 spent)
UPDATE Customer
SET loyalty_points = loyalty_points + 51
WHERE customer_id = 1;

-- Q25: Update inventory quantity after restocking
UPDATE Inventory
SET quantity = quantity + 10
WHERE ingredient_name = 'Chicken';

-- -----------------------------------------------
-- 4.6 DELETE QUERIES
-- -----------------------------------------------

-- Q26: Delete a cancelled reservation
DELETE FROM Reservation WHERE status = 'Cancelled';

-- Q27: Remove a menu item that no longer exists
-- (Only if not referenced in any order detail)
DELETE FROM MenuItem WHERE item_id = 15 AND item_id NOT IN (SELECT item_id FROM OrderDetail);

-- -----------------------------------------------
-- 4.7 VIEWS
-- -----------------------------------------------

-- V1: Daily Sales Summary View
CREATE OR REPLACE VIEW DailySalesSummary AS
SELECT DATE(p.payment_date) AS sale_date,
       COUNT(DISTINCT p.order_id)     AS total_orders,
       SUM(p.amount)                  AS gross_revenue,
       SUM(p.discount)                AS total_discounts,
       SUM(p.amount * p.tax / 100)    AS total_tax_collected
FROM Payment p
GROUP BY DATE(p.payment_date);

-- V2: Customer Order History View
CREATE OR REPLACE VIEW CustomerOrderHistory AS
SELECT CONCAT(c.first_name,' ',c.last_name) AS customer_name,
       c.phone, c.loyalty_points,
       o.order_id, o.order_date, o.status,
       p.amount, p.payment_method
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
LEFT JOIN Payment p ON o.order_id = p.order_id;

-- V3: Popular Items View (ordered more than once)
CREATE OR REPLACE VIEW PopularItems AS
SELECT m.item_name, c.category_name,
       SUM(od.quantity) AS times_ordered,
       SUM(od.quantity * od.unit_price) AS revenue_generated
FROM OrderDetail od
JOIN MenuItem m ON od.item_id = m.item_id
JOIN Category c ON m.category_id = c.category_id
GROUP BY m.item_id
HAVING times_ordered > 1
ORDER BY times_ordered DESC;

-- V4: Low Inventory Alert View
CREATE OR REPLACE VIEW LowInventoryAlert AS
SELECT ingredient_name, quantity, unit, reorder_level,
       (reorder_level - quantity) AS shortage,
       supplier_name
FROM Inventory
WHERE quantity <= reorder_level;

-- -----------------------------------------------
-- 4.8 STORED PROCEDURES
-- -----------------------------------------------

DELIMITER $$

-- SP1: Place a new order
CREATE PROCEDURE PlaceOrder(
    IN p_customer_id INT,
    IN p_table_id    INT,
    IN p_emp_id      INT,
    IN p_order_type  VARCHAR(20),
    OUT p_order_id   INT
)
BEGIN
    INSERT INTO Orders (customer_id, table_id, emp_id, order_date, status, order_type)
    VALUES (p_customer_id, p_table_id, p_emp_id, NOW(), 'Pending', p_order_type);
    SET p_order_id = LAST_INSERT_ID();
    UPDATE RestaurantTable SET status = 'Occupied' WHERE table_id = p_table_id;
END$$

-- SP2: Process payment for an order
CREATE PROCEDURE ProcessPayment(
    IN p_order_id  INT,
    IN p_method    VARCHAR(20),
    IN p_discount  DECIMAL(5,2)
)
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT SUM(quantity * unit_price) INTO v_total
    FROM OrderDetail WHERE order_id = p_order_id;

    SET v_total = v_total * (1 - p_discount/100) * 1.05; -- apply discount & 5% tax

    INSERT INTO Payment (order_id, payment_date, amount, payment_method, discount, tax)
    VALUES (p_order_id, NOW(), v_total, p_method, p_discount, 5.00);

    UPDATE Orders SET status = 'Paid' WHERE order_id = p_order_id;
END$$

-- SP3: Get all items for an order
CREATE PROCEDURE GetOrderItems(IN p_order_id INT)
BEGIN
    SELECT m.item_name, od.quantity, od.unit_price,
           (od.quantity * od.unit_price) AS subtotal, od.special_note
    FROM OrderDetail od
    JOIN MenuItem m ON od.item_id = m.item_id
    WHERE od.order_id = p_order_id;
END$$

DELIMITER ;

-- -----------------------------------------------
-- 4.9 TRIGGERS
-- -----------------------------------------------

DELIMITER $$

-- T1: Auto-update table status to Available when order is Paid
CREATE TRIGGER trg_order_paid
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'Paid' AND OLD.status != 'Paid' THEN
        UPDATE RestaurantTable SET status = 'Available' WHERE table_id = NEW.table_id;
    END IF;
END$$

-- T2: Prevent deleting a menu item that has active order details
CREATE TRIGGER trg_prevent_item_delete
BEFORE DELETE ON MenuItem
FOR EACH ROW
BEGIN
    DECLARE cnt INT;
    SELECT COUNT(*) INTO cnt FROM OrderDetail WHERE item_id = OLD.item_id;
    IF cnt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete menu item with existing order details.';
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------
-- 4.10 INDEX CREATION
-- -----------------------------------------------

CREATE INDEX idx_orders_date       ON Orders(order_date);
CREATE INDEX idx_orders_status     ON Orders(status);
CREATE INDEX idx_payment_method    ON Payment(payment_method);
CREATE INDEX idx_menuitem_category ON MenuItem(category_id);
CREATE INDEX idx_reservation_date  ON Reservation(reserved_date);

-- ============================================================
-- 5. REPORTING QUERIES
-- ============================================================

-- R1: Monthly Revenue Report
SELECT YEAR(payment_date)  AS year,
       MONTH(payment_date) AS month,
       COUNT(*)            AS total_payments,
       SUM(amount)         AS total_revenue,
       AVG(amount)         AS avg_bill
FROM Payment
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY year, month;

-- R2: Top 5 Customers by Spending
SELECT CONCAT(c.first_name,' ',c.last_name) AS customer,
       c.loyalty_points,
       COUNT(o.order_id)  AS visits,
       SUM(p.amount)      AS total_spent
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payment p ON o.order_id = p.order_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 5;

-- R3: Employee Shift-wise Order Report
SELECT e.shift,
       CONCAT(e.first_name,' ',e.last_name) AS employee,
       e.role,
       COUNT(o.order_id) AS orders_handled,
       SUM(p.amount)     AS revenue_generated
FROM Employee e
LEFT JOIN Orders o ON e.emp_id = o.emp_id
LEFT JOIN Payment p ON o.order_id = p.order_id
GROUP BY e.emp_id
ORDER BY e.shift, revenue_generated DESC;

-- R4: Table Utilization Report
SELECT t.table_number, t.capacity, t.location,
       COUNT(o.order_id) AS total_orders,
       SUM(p.amount)     AS revenue_from_table
FROM RestaurantTable t
LEFT JOIN Orders o ON t.table_id = o.table_id
LEFT JOIN Payment p ON o.order_id = p.order_id
GROUP BY t.table_id
ORDER BY revenue_from_table DESC;

-- R5: Feedback / Rating Summary
SELECT AVG(rating)  AS avg_rating,
       COUNT(*)     AS total_reviews,
       SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) AS five_star,
       SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) AS four_star,
       SUM(CASE WHEN rating <= 3 THEN 1 ELSE 0 END) AS below_avg
FROM Feedback;

-- End of Script