-- =====================================================================
-- CAR SHOWROOM MANAGEMENT SYSTEM - SCHEMA (MySQL 8.0.16+)
-- Lab 4: NOT NULL, UNIQUE, CHECK, PRIMARY KEY, FOREIGN KEY, DEFAULT
-- =====================================================================
CREATE DATABASE IF NOT EXISTS CarShowroomDB;
USE CarShowroomDB;

CREATE TABLE IF NOT EXISTS Supplier (
    Supplier_ID  VARCHAR(10)  PRIMARY KEY,
    Name         VARCHAR(100) NOT NULL,
    Company_Type VARCHAR(50),
    Address      VARCHAR(200),
    Est_Year     INT                      -- Years_In_Business is derived from this
);

-- Multivalued attributes of Supplier
CREATE TABLE IF NOT EXISTS Supplier_Email (
    Supplier_ID VARCHAR(10),
    Email       VARCHAR(100),
    PRIMARY KEY (Supplier_ID, Email),
    FOREIGN KEY (Supplier_ID) REFERENCES Supplier(Supplier_ID) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS Supplier_Phone (
    Supplier_ID VARCHAR(10),
    Phone_No    VARCHAR(15),
    PRIMARY KEY (Supplier_ID, Phone_No),
    FOREIGN KEY (Supplier_ID) REFERENCES Supplier(Supplier_ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Vehicle_Model (
    Model_ID   VARCHAR(10)  PRIMARY KEY,
    Model_Name VARCHAR(100) NOT NULL,
    Fuel_Type  VARCHAR(20),
    Category   VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS Vehicle_Inventory (
    Inventory_ID     VARCHAR(10) PRIMARY KEY,
    Model_ID         VARCHAR(10) NOT NULL,
    Manufacture_Date DATE,
    Status           VARCHAR(20) DEFAULT 'Available',
    Location         VARCHAR(100),
    CONSTRAINT chk_inventory_status CHECK (Status IN ('Available','Reserved','Sold')),
    FOREIGN KEY (Model_ID) REFERENCES Vehicle_Model(Model_ID)
);

CREATE TABLE IF NOT EXISTS Vehicle_Delivery (
    Delivery_ID   VARCHAR(10) PRIMARY KEY,
    Supplier_ID   VARCHAR(10) NOT NULL,
    Inventory_ID  VARCHAR(10) NOT NULL,
    Delivery_Date DATE        NOT NULL,
    Quantity      INT,
    CONSTRAINT chk_delivery_qty CHECK (Quantity > 0),
    FOREIGN KEY (Supplier_ID)  REFERENCES Supplier(Supplier_ID),
    FOREIGN KEY (Inventory_ID) REFERENCES Vehicle_Inventory(Inventory_ID)
);

CREATE TABLE IF NOT EXISTS Showroom_Branch (
    Branch_ID      VARCHAR(10)  PRIMARY KEY,
    Name           VARCHAR(100) NOT NULL,
    Address        VARCHAR(200),
    Contact_Number VARCHAR(15)
);

CREATE TABLE IF NOT EXISTS Customer (
    Customer_ID  VARCHAR(10)  PRIMARY KEY,
    Branch_ID    VARCHAR(10)  NOT NULL,
    Name         VARCHAR(100) NOT NULL,
    Gender       VARCHAR(10),
    Age          INT,
    Phone_Number VARCHAR(15),
    CONSTRAINT uq_customer_phone UNIQUE (Phone_Number),
    CONSTRAINT chk_customer_age  CHECK (Age >= 18),
    FOREIGN KEY (Branch_ID) REFERENCES Showroom_Branch(Branch_ID)
);

CREATE TABLE IF NOT EXISTS Sales_Order (
    Order_ID          VARCHAR(10) PRIMARY KEY,
    Customer_ID       VARCHAR(10) NOT NULL,
    Branch_ID         VARCHAR(10) NOT NULL,
    Inventory_ID      VARCHAR(10) NOT NULL,
    Order_Date        DATE        NOT NULL,
    Quantity_Required INT,
    Status            VARCHAR(20),
    Total_Amount      DECIMAL(6,2) DEFAULT 0,      -- in Rs lakh
    CONSTRAINT chk_order_qty    CHECK (Quantity_Required > 0),
    CONSTRAINT chk_order_status CHECK (Status IN ('Pending','Confirmed','Fulfilled','Cancelled')),
    FOREIGN KEY (Customer_ID)  REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Branch_ID)    REFERENCES Showroom_Branch(Branch_ID),
    FOREIGN KEY (Inventory_ID) REFERENCES Vehicle_Inventory(Inventory_ID)
);

-- Lab 4 demonstration table (PRIMARY KEY, FOREIGN KEY, DEFAULT)
CREATE TABLE IF NOT EXISTS Test_Drive (
    Drive_ID     VARCHAR(10) PRIMARY KEY,
    Customer_ID  VARCHAR(10) NOT NULL,
    Inventory_ID VARCHAR(10) NOT NULL,
    Drive_Date   DATE NOT NULL,
    Status       VARCHAR(20) DEFAULT 'Booked',
    FOREIGN KEY (Customer_ID)  REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Inventory_ID) REFERENCES Vehicle_Inventory(Inventory_ID)
);

-- Lab 12: written to by the after_order_insert trigger
CREATE TABLE IF NOT EXISTS Order_Log (
    Log_ID      INT AUTO_INCREMENT PRIMARY KEY,
    Order_ID    VARCHAR(10),
    Action_Text VARCHAR(50),
    Action_Time DATETIME
);
-- SAMPLE DATA (matches the sample records used in the lab record)
USE CarShowroomDB;

INSERT INTO Supplier VALUES
('S01','Tata Motors Ltd','Manufacturer','Pune, MH',1945),
('S02','Maruti Suzuki India','Manufacturer','Gurugram, HR',1981),
('S03','Hyundai Motor India','Manufacturer','Chennai, TN',1996);
INSERT INTO Supplier_Email VALUES ('S01','contact@tatamotors.com'),('S03','contact@hyundai.example.com');
INSERT INTO Supplier_Phone VALUES ('S01','9876543210'),('S02','9812345678');

INSERT INTO Vehicle_Model VALUES
('M01','Nexon','Petrol','SUV'),
('M02','Tiago','Petrol','Hatchback'),
('M03','Swift','Petrol','Hatchback'),
('M04','Creta','Diesel','SUV');

INSERT INTO Showroom_Branch VALUES
('B01','City Center Branch','MG Road, Jaipur','0141234567'),
('B02','Airport Road Branch','Airport Road, Jaipur','0141765432'),
('B03','Civil Lines Branch','Civil Lines, Jodhpur','0291456789');

INSERT INTO Vehicle_Inventory VALUES
('I01','M01','2026-01-15','Available','Bay-1'),
('I02','M02','2026-02-10','Sold','Bay-2'),
('I03','M03','2026-03-05','Available','Bay-3'),
('I04','M01','2026-03-20','Reserved','Bay-1');

INSERT INTO Vehicle_Delivery VALUES
('D01','S01','I01','2026-01-20',1),
('D02','S01','I02','2026-02-15',1),
('D03','S02','I03','2026-03-10',1),
('D04','S01','I04','2026-03-25',1);

INSERT INTO Customer VALUES
('C01','B01','Aarav Mehta','Male',32,'9123456789'),
('C02','B01','Diya Sharma','Female',28,'9812345670'),
('C03','B02','Kabir Singh','Male',41,'9700011122');

INSERT INTO Sales_Order VALUES
('O01','C01','B01','I02','2026-02-12',1,'Fulfilled',7.50),
('O02','C02','B01','I04','2026-03-25',1,'Confirmed',12.00),
('O03','C03','B02','I01','2026-04-02',1,'Pending',11.50),
('O04','C01','B01','I03','2026-04-10',1,'Cancelled',6.80);
-- LAB 10: VIEWS
USE CarShowroomDB;

CREATE OR REPLACE VIEW Available_Vehicles AS
SELECT vi.Inventory_ID, vm.Model_Name, vm.Category, vi.Location
FROM Vehicle_Inventory vi
JOIN Vehicle_Model vm ON vi.Model_ID = vm.Model_ID
WHERE vi.Status = 'Available';

CREATE OR REPLACE VIEW Order_Summary_View AS
SELECT o.Order_ID, c.Name AS Customer, b.Name AS Branch,
       vm.Model_Name, o.Total_Amount, o.Status
FROM Sales_Order o
JOIN Customer c ON o.Customer_ID = c.Customer_ID
JOIN Showroom_Branch b ON o.Branch_ID = b.Branch_ID
JOIN Vehicle_Inventory vi ON o.Inventory_ID = vi.Inventory_ID
JOIN Vehicle_Model vm ON vi.Model_ID = vm.Model_ID;

CREATE OR REPLACE VIEW Model_Stock AS
SELECT vm.Model_Name, COUNT(vi.Inventory_ID) AS Units
FROM Vehicle_Model vm
LEFT JOIN Vehicle_Inventory vi ON vm.Model_ID = vi.Model_ID
GROUP BY vm.Model_Name;
-- LAB 12: TRIGGERS AND STORED PROCEDURES
-- Run AFTER the sample data so the seed rows do not fire the triggers.
USE CarShowroomDB;
DROP TRIGGER IF EXISTS after_order_insert;
DROP TRIGGER IF EXISTS before_order_insert;
DROP TRIGGER IF EXISTS after_order_fulfilled;
DROP PROCEDURE IF EXISTS GetOrdersByStatus;
DROP PROCEDURE IF EXISTS GetAvailableVehicles;

DELIMITER //

-- logs every new order into Order_Log
CREATE TRIGGER after_order_insert
AFTER INSERT ON Sales_Order
FOR EACH ROW
BEGIN
    INSERT INTO Order_Log (Order_ID, Action_Text, Action_Time)
    VALUES (NEW.Order_ID, 'Order inserted', NOW());
END //

-- business rule: a vehicle that is already Sold cannot be ordered again
CREATE TRIGGER before_order_insert
BEFORE INSERT ON Sales_Order
FOR EACH ROW
BEGIN
    IF (SELECT Status FROM Vehicle_Inventory WHERE Inventory_ID = NEW.Inventory_ID) = 'Sold' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This vehicle is already sold.';
    END IF;
END //

-- keeps inventory in step with sales
CREATE TRIGGER after_order_fulfilled
AFTER UPDATE ON Sales_Order
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Fulfilled' THEN
        UPDATE Vehicle_Inventory SET Status = 'Sold'
        WHERE Inventory_ID = NEW.Inventory_ID;
    END IF;
END //

CREATE PROCEDURE GetOrdersByStatus(IN p_status VARCHAR(20))
BEGIN
    SELECT Order_ID, Customer_ID, Total_Amount
    FROM Sales_Order
    WHERE Status = p_status;
END //

CREATE PROCEDURE GetAvailableVehicles()
BEGIN
    SELECT * FROM Available_Vehicles;
END //

DELIMITER ;
