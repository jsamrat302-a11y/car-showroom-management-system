-- LAB 12: TCL (COMMIT, ROLLBACK, SAVEPOINT) - run these by hand to see the effect
USE CarShowroomDB;

START TRANSACTION;                       -- COMMIT
UPDATE Vehicle_Inventory SET Status = 'Sold' WHERE Inventory_ID = 'I04';
COMMIT;

START TRANSACTION;                       -- ROLLBACK
UPDATE Vehicle_Inventory SET Status = 'Reserved' WHERE Inventory_ID = 'I03';
ROLLBACK;
SELECT Inventory_ID, Status FROM Vehicle_Inventory WHERE Inventory_ID = 'I03';

START TRANSACTION;                       -- SAVEPOINT
UPDATE Vehicle_Inventory SET Status = 'Reserved' WHERE Inventory_ID = 'I01';
SAVEPOINT sp1;
UPDATE Vehicle_Inventory SET Status = 'Reserved' WHERE Inventory_ID = 'I03';
ROLLBACK TO sp1;
COMMIT;
