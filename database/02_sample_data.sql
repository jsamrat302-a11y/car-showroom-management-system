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
