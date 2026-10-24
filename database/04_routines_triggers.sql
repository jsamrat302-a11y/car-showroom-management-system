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
