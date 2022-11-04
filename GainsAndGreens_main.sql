CREATE DATABASE Gains_and_Greens;

USE Gains_and_Greens;

-- Creating tables; adding relationships -- 

CREATE TABLE customers 
(
cust_id INT NOT NULL,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
work_location VARCHAR(50) NOT NULL,
mobile_no CHAR(11) NOT NULL,
email VARCHAR(50),
PRIMARY KEY (cust_id)
);

CREATE TABLE diet_req 
(
diet_id VARCHAR(2) NOT NULL,
diet VARCHAR(10) NOT NULL,
PRIMARY KEY (diet_id)
);

CREATE TABLE delivery 
(
person_id INT NOT NULL,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
mobile_no CHAR(11) NOT NULL,
pay_per_hour FLOAT(2) NOT NULL,
PRIMARY KEY (person_id)
);

CREATE TABLE menu
(
menu_id INT NOT NULL,
diet VARCHAR(2) NOT NULL,
item_name VARCHAR(50) NOT NULL,
price FLOAT(2) NOT NULL,
protein INT NOT NULL,
carbs INT NOT NULL,
fat INT NOT NULL,
PRIMARY KEY (menu_id),
FOREIGN KEY (diet) REFERENCES diet_req(diet_id)
);

CREATE TABLE orders
(order_id INT NOT NULL AUTO_INCREMENT,
customer INT NOT NULL,
item INT NOT NULL,
delivery_person INT NOT NULL,
order_time TIMESTAMP NOT NULL,
quantity INT NOT NULL,
notes VARCHAR(100),
PRIMARY KEY (order_id),
FOREIGN KEY (customer) REFERENCES customers(cust_id),
FOREIGN KEY (item) REFERENCES menu(menu_id),
FOREIGN KEY (delivery_person) REFERENCES delivery(person_id)
);

-- Inserting table data --

INSERT INTO customers (cust_id, first_name, last_name, work_location, mobile_no, email)
VALUES
(111, 'John', 'Smith', 'D1', '07399432154', 'johnsmith@gmail.com'),
(112, 'Ellen', 'Jones', 'C2', '07498217534', 'ejones@outlook.com'),
(113, 'James', 'Robinson', 'D3', '07746382967', 'jamesrob@gmail.com'),
(114, 'Emma', 'Wright', 'A2', '07865345276', 'emwright@gmail.com'),
(115, 'Natalie', 'Brown', 'B3', '07154236734', 'natbrown@outlook.com'),
(116, 'Jenny', 'Wade', 'A1', '07563213678', 'jwade@outlook.com'),
(117, 'Andrew', 'Levine', 'D1', '07984235456', 'andylevine@outlook.com'),
(118, 'Lauren', 'Godfrey', 'B1', '07546876324', 'laurengodfrey@gmail.com'),
(119, 'Ben', 'Travers', 'A2', '07775674353', 'ben.travers@outlook.com'),
(120, 'Ralph', 'Colbert', 'D2', '07376289543', 'ralphcolbert@gmail.com');

SELECT * FROM customers;

INSERT INTO diet_req (diet_id, diet)
VALUES
('m', 'Meat'),
('v', 'Vegetarian'),
('ve', 'Vegan');

SELECT * FROM diet_req;

INSERT INTO delivery (person_id, first_name, last_name, mobile_no, pay_per_hour)
VALUES
(211, 'Monica', 'Parker', '07543675850', 6.83),
(212, 'Bailey', 'Keegan', '07708956432', 9.18),
(213, 'Shannon', 'McNiven', '07875435643', 9.50),
(214, 'Kiran', 'Bowen', '07230564765', 9.50),
(215, 'Chris', 'Michaelson', '07250678987', 9.18),
(216, 'James', 'Goddard', '07654783219', 6.83),
(217, 'Shelley', 'Warr', '07367421834', 9.18);

SELECT * FROM delivery;

INSERT INTO menu (menu_id, diet, item_name, price, protein, carbs, fat)
VALUES
(1, 'm', 'chicken fajitas', 6.75, 39, 26, 77),
(2, 'v', 'tofu thai green curry', 7.00, 26, 15, 38),
(3, 'm', 'steak burrito bowl', 7.50, 32, 24, 49),
(4, 've', 'chickpea and coconut dhal', 6.00, 16, 18, 25),
(5, 've', 'rainbow buddha bowl', 6.00, 17, 14, 32),
(6, 'v', 'black bean chilli', 6.50, 25, 10, 50),
(7, 'm', 'teriyaki salmon and greens', 7.50, 28, 15, 38),
(8, 'm', 'tuna nicoise pot', 7.50, 30, 15, 12),
(9, 'm', 'coconut and prawn curry', 7.00, 23, 12, 34),
(10, 'v', 'halloumi and roasted veg', 6.50, 27, 24, 53);

SELECT * FROM menu;

INSERT INTO orders (customer, item, delivery_person, order_time, quantity, notes)
VALUES
(111, 2, 211, '2022-09-19 12:01:36', 1, 'jasmine rice'),
(112, 10, 212, '2022-09-19 12:41:40', 1, NULL),
(113, 1, 213, '2022-09-19 12:50:23', 1, 'gluten free wraps'),
(114, 3, 211, '2022-09-19 13:13:42', 2, NULL),
(115, 8, 211, '2022-09-19 13:15:35', 1, NULL),
(116, 9, 212, '2022-09-19 13:34:54', 1, 'sticky rice'),
(117, 7, 213, '2022-09-19 13:02:16', 1, NULL),
(118, 10, 214, '2022-09-20 12:23:43', 1, NULL),
(119, 1, 215, '2022-09-20 12:40:21', 2, 'extra salsa'),
(120, 1, 217, '2022-09-20 12:35:47', 1, NULL);

SELECT * FROM orders;

-- Create a join to show details of order to give to delivery driver; references below function --

CREATE VIEW details
AS
	SELECT 
		t1.first_name, t1.work_location, t1.mobile_no,
        t2.item, estimated_delivery_time(item, order_time) AS estimated_time
	FROM
		customers t1
			INNER JOIN
		orders t2
			ON
            t1.cust_id = t2.customer;
            
SELECT * FROM details;

-- Example subquery e.g. select customers where order is for meat dish... (e.g. can examine how popular...) --

SELECT COUNT(*) AS meat_orders
FROM orders o
WHERE o.item IN (
	SELECT id.menu_id
	FROM menu id
	WHERE id.diet = 'm'
);

-- Estimating the delivery time based on the dish picked --

DELIMITER //

CREATE FUNCTION estimated_delivery_time (item INT, order_time TIMESTAMP)
RETURNS TIMESTAMP
DETERMINISTIC
BEGIN
	DECLARE delivery_time TIMESTAMP;
	IF item = 1 OR 3 OR 7 THEN
		SET delivery_time = order_time + INTERVAL '20' MINUTE;
	ELSEIF item = 2 OR 4 OR 9 THEN
		SET delivery_time = order_time + INTERVAL '15' MINUTE;
	ELSEIF item = 5 OR 6 OR 8 OR 10 THEN
		SET delivery_time = order_time + INTERVAL '10' MINUTE;
	END IF;
    RETURN (delivery_time);

END //

DELIMITER ;

-- TESTING --

SELECT order_id, order_time, estimated_delivery_time(item, order_time) AS estimated_time
FROM orders;

-- Diagram showing relationships is separate! --

-- Stored procedure to add a menu item; with complimentary getting rid of item below to change up menu --

DELIMITER //

CREATE PROCEDURE new_item 
(
IN id INT, 
IN req VARCHAR(2), 
IN name VARCHAR(50), 
IN value FLOAT(2), 
IN p INT, 
IN c INT,
IN f INT
)
BEGIN

    INSERT INTO menu (menu_id, diet, item_name, price, protein, fat, carbs)
    VALUES (id, req, name, value, p, c, f);
    
END //
    
DELIMITER ;

-- TESTING --

CALL new_item(11, 've', 'tofu stir fry', 6.50, 23, 13, 40);

SELECT * FROM menu;

-- Stored procedure to remove a menu item --

DELIMITER //

CREATE PROCEDURE delete_item (IN id INT)
BEGIN

	DELETE FROM menu
	WHERE id = menu_id;
    
END //

DELIMITER ;

CALL delete_item(11);

SELECT * FROM menu;

-- Trigger to ensure consitency when a new customer orders -- 

DELIMITER //

CREATE TRIGGER new_customer_insert
BEFORE INSERT ON customers
FOR EACH ROW
BEGIN
	SET NEW. first_name = CONCAT(UPPER(SUBSTRING(NEW.first_name, 1,1)), LOWER(SUBSTRING(NEW.first_name FROM 2)));
    SET NEW. last_name = CONCAT(UPPER(SUBSTRING(NEW.last_name, 1,1)), LOWER(SUBSTRING(NEW.last_name FROM 2)));
    END //
    
DELIMITER ;

-- TESTING --

INSERT INTO customers (cust_id, first_name, last_name, work_location, mobile_no, email)
VALUES (121, 'JANE', 'Tame', 'D1', '07459327328', 'j.tame@outlook.com');

SELECT * FROM customers;

DELETE FROM customers
WHERE cust_id = 121;