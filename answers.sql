Question 1: Achieving 1NF
-- Create a new table in 1NF
CREATE TABLE OrderDetails_1NF AS
SELECT OrderID, CustomerName, TRIM(value) AS Product
FROM ProductDetail
CROSS JOIN STRING_SPLIT(Products, ',');

-- Alternative for databases without STRING_SPLIT function
-- For MySQL:
SELECT OrderID, CustomerName, SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n), ',', -1) AS Product
FROM ProductDetail
JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) numbers
WHERE n <= LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) + 1;

The resulting table would look like:
OrderID | CustomerName | Product
--------|--------------|---------
101     | John Doe     | Laptop
101     | John Doe     | Mouse
102     | Jane Smith   | Tablet
102     | Jane Smith   | Keyboard
102     | Jane Smith   | Mouse
103     | Emily Clark  | Phone

Question 2: Achieving 2NF
To transform the OrderDetails table into 2NF, we need to remove partial dependencies by separating the data into two tables - one for orders and one for order items.

sql
-- Create Orders table (contains order-specific information)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Create OrderItems table (contains items for each order)
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    Product VARCHAR(50),
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Populate Orders table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Populate OrderItems table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;
The resulting normalized schema would have:

Orders table:
OrderID | CustomerName
--------|-------------
101     | John Doe
102     | Jane Smith
103     | Emily Clark
  
OrderItems table:
OrderItemID | OrderID | Product  | Quantity
-----------|---------|----------|---------
1          | 101     | Laptop   | 2
2          | 101     | Mouse    | 1
3          | 102     | Tablet   | 3
4          | 102     | Keyboard | 1
5          | 102     | Mouse    | 2
6          | 103     | Phone    | 1
