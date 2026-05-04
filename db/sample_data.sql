-- ============================================================
-- SAMPLE DATA - Delivery Service Management System
-- ============================================================

USE delivery_system;

-- ============================================================
-- Customers (10 rows)
-- ============================================================
INSERT INTO Customers (CustomerName, PhoneNumber, Address, Email) VALUES
('Nguyen Van An',    '0901234561', '12 Le Loi, Q1, HCMC',           'an.nguyen@email.com'),
('Tran Thi Bich',   '0901234562', '45 Tran Hung Dao, Q5, HCMC',    'bich.tran@email.com'),
('Le Minh Cuong',   '0901234563', '78 Nguyen Hue, Q1, HCMC',       'cuong.le@email.com'),
('Pham Thi Dung',   '0901234564', '23 Ba Trieu, Hai Ba Trung, HN',  'dung.pham@email.com'),
('Hoang Van Em',    '0901234565', '56 Ly Thuong Kiet, Hoan Kiem, HN','em.hoang@email.com'),
('Vo Thi Phuong',   '0901234566', '90 Dien Bien Phu, Q3, HCMC',    'phuong.vo@email.com'),
('Dang Quoc Hung',  '0901234567', '11 Pasteur, Q1, HCMC',           'hung.dang@email.com'),
('Nguyen Thi Lan',  '0901234568', '34 Hai Ba Trung, Q3, HCMC',     'lan.nguyen2@email.com'),
('Bui Van Manh',    '0901234569', '67 Cach Mang Thang 8, Q10, HCMC','manh.bui@email.com'),
('Do Thi Nga',      '0901234570', '88 Nam Ky Khoi Nghia, Q3, HCMC','nga.do@email.com');

-- ============================================================
-- Vehicles (10 rows)
-- ============================================================
INSERT INTO Vehicles (VehicleType, LicensePlate, Availability, Capacity_kg) VALUES
('Motorbike', '59-B1 23456', 'Available',    30.0),
('Motorbike', '59-B2 34567', 'Available',    30.0),
('Van',       '51-C1 45678', 'Available',   500.0),
('Van',       '51-C2 56789', 'In Use',      500.0),
('Truck',     '51-D1 67890', 'Available',  2000.0),
('Truck',     '51-D2 78901', 'Maintenance',2000.0),
('Motorbike', '59-B3 89012', 'In Use',       30.0),
('Van',       '51-C3 90123', 'Available',   500.0),
('Bicycle',   '59-E1 01234', 'Available',    15.0),
('Motorbike', '59-B4 12345', 'Available',    30.0);

-- ============================================================
-- Orders (10 rows)
-- ============================================================
INSERT INTO Orders (CustomerID, OrderDate, Status, PickupAddress, DropAddress, Weight_kg, Notes) VALUES
(1,  '2025-05-01 08:00:00', 'Delivered',   '12 Le Loi, Q1',          '100 Nguyen Trai, Q5',      2.5,  'Fragile items'),
(2,  '2025-05-02 09:00:00', 'Delivered',   '45 Tran Hung Dao, Q5',   '22 Hoang Dieu, Q4',        1.0,  NULL),
(3,  '2025-05-03 10:00:00', 'In Transit',  '78 Nguyen Hue, Q1',      '55 Ly Tu Trong, Q1',       5.0,  'Handle with care'),
(4,  '2025-05-04 11:00:00', 'Assigned',    '23 Ba Trieu, HN',        '10 Lang Ha, Dong Da, HN',  3.0,  NULL),
(5,  '2025-05-05 12:00:00', 'Pending',     '56 Ly Thuong Kiet, HN',  '30 Tran Phu, Ha Dong, HN', 1.5,  'Urgent delivery'),
(6,  '2025-05-06 08:30:00', 'Delivered',   '90 Dien Bien Phu, Q3',   '5 Vo Van Tan, Q3',         0.5,  NULL),
(7,  '2025-05-07 09:30:00', 'In Transit',  '11 Pasteur, Q1',         '88 Le Van Sy, Q3',         7.0,  'Heavy package'),
(8,  '2025-05-08 10:30:00', 'Cancelled',   '34 Hai Ba Trung, Q3',    '12 Nam Quoc Cang, Q1',     2.0,  'Customer request'),
(9,  '2025-05-09 11:30:00', 'Pending',     '67 CMT8, Q10',           '40 Su Van Hanh, Q10',      4.0,  NULL),
(10, '2025-05-10 12:30:00', 'Assigned',    '88 Nam Ky Khoi Nghia, Q3','15 Nguyen Dinh Chieu, Q3', 1.0,  NULL);

-- ============================================================
-- Deliveries (7 rows - only for non-Pending/Cancelled orders)
-- ============================================================
INSERT INTO Deliveries (OrderID, VehicleID, DeliveryDate, StartTime, EndTime, Status, DriverName) VALUES
(1,  1, '2025-05-01', '2025-05-01 08:30:00', '2025-05-01 10:00:00', 'Completed',   'Nguyen Van Tuan'),
(2,  2, '2025-05-02', '2025-05-02 09:30:00', '2025-05-02 10:45:00', 'Completed',   'Tran Van Duc'),
(3,  4, '2025-05-03', '2025-05-03 10:30:00', NULL,                   'In Progress', 'Le Minh Khai'),
(4,  3, '2025-05-04', '2025-05-04 11:30:00', NULL,                   'Scheduled',   'Pham Quoc Bao'),
(6,  9, '2025-05-06', '2025-05-06 09:00:00', '2025-05-06 09:45:00', 'Completed',   'Vo Thi Thu'),
(7,  7, '2025-05-07', '2025-05-07 10:00:00', NULL,                   'In Progress', 'Dang Van Nam'),
(10, 1, '2025-05-10', NULL,                   NULL,                   'Scheduled',   'Nguyen Van Tuan');

-- ============================================================
-- Expenses (10 rows)
-- ============================================================
INSERT INTO Expenses (DeliveryID, ExpenseType, Amount, Description) VALUES
(1, 'Fuel',       25000,  'Gasoline 1L'),
(1, 'Toll',       5000,   'Bridge toll'),
(2, 'Fuel',       20000,  'Gasoline 0.8L'),
(3, 'Fuel',       40000,  'Gasoline 1.6L'),
(3, 'Toll',       10000,  'Highway toll'),
(3, 'Parking',    15000,  'Parking fee'),
(4, 'Fuel',       80000,  'Diesel 4L for Van'),
(5, 'Fuel',       10000,  'Short distance'),
(6, 'Fuel',       60000,  'Gasoline 2.4L'),
(6, 'Handling',   30000,  'Heavy item surcharge');