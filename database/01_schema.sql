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
