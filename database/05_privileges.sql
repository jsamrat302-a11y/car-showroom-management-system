-- LAB 11: PRIVILEGES AND ACCESS CONTROL  (run as a MySQL admin such as root)
-- Change the passwords before using this anywhere real.
CREATE USER IF NOT EXISTS 'showroom_app'@'localhost'   IDENTIFIED BY 'ShowroomApp_123';
CREATE USER IF NOT EXISTS 'showroom_staff'@'localhost' IDENTIFIED BY 'Showroom_123';

-- The web app user: full data access plus the right to run stored procedures
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON CarShowroomDB.* TO 'showroom_app'@'localhost';

-- A read-only staff user (lab demonstration of GRANT / REVOKE)
GRANT SELECT ON CarShowroomDB.Vehicle_Inventory TO 'showroom_staff'@'localhost';
GRANT SELECT, INSERT, UPDATE ON CarShowroomDB.Sales_Order TO 'showroom_staff'@'localhost';
SHOW GRANTS FOR 'showroom_staff'@'localhost';

REVOKE UPDATE ON CarShowroomDB.Sales_Order FROM 'showroom_staff'@'localhost';
-- REVOKE SELECT ON CarShowroomDB.Vehicle_Inventory FROM 'showroom_staff'@'localhost';
-- DROP USER 'showroom_staff'@'localhost';
