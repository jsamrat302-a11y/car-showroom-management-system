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
