-- View 1: Current Delivery Schedule
CREATE OR REPLACE VIEW vw_current_delivery_schedule AS
SELECT 
	d.DeliveryID,
    o.OrderID,
    c.CustomerName,
    c.PhoneNumber,
    o.PickupAddress,
    o.DropAddress,
    v.LicensePlate,
    v.VehicleType,
    d.DriverName,
    d.DeliveryDate,
    d.StartTime,
    d.Status AS DeliveryStatus,
    o.Weight_kg
    
FROM Deliveries d
JOIN Orders   o ON d.OrderID   = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN Vehicles  v ON d.VehicleID  = v.VehicleID
WHERE d.Status IN ('Scheduled', 'In Progress')
ORDER BY d.DeliveryDate, d.StartTime;

-- View 2: Cost Per Order
CREATE OR REPLACE VIEW vw_cost_per_order AS
SELECT
    o.OrderID,
    c.CustomerName,
    o.OrderDate,
    o.Status,
    d.DeliveryID,
    d.DriverName,
    COALESCE(SUM(e.Amount), 0) AS TotalCost,
    GROUP_CONCAT(DISTINCT e.ExpenseType ORDER BY e.ExpenseType SEPARATOR ', ') AS ExpenseBreakdown
FROM Orders    o
JOIN Customers  c ON o.CustomerID  = c.CustomerID
LEFT JOIN Deliveries d ON o.OrderID  = d.OrderID
LEFT JOIN Expenses   e ON d.DeliveryID = e.DeliveryID
GROUP BY o.OrderID, c.CustomerName, o.OrderDate, o.Status, d.DeliveryID, d.DriverName;

-- View 3: Outstanding Orders (not yet delivered)
CREATE OR REPLACE VIEW vw_outstanding_orders AS
SELECT
    o.OrderID,
    c.CustomerName,
    c.PhoneNumber,
    o.OrderDate,
    o.Status,
    o.PickupAddress,
    o.DropAddress,
    o.Weight_kg,
    DATEDIFF(CURDATE(), DATE(o.OrderDate)) AS DaysPending
FROM Orders   o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.Status NOT IN ('Delivered', 'Cancelled')
ORDER BY o.OrderDate;

-- View 4: Vehicle Availability Summary
CREATE OR REPLACE VIEW vw_vehicle_summary AS
SELECT
    v.VehicleID,
    v.VehicleType,
    v.LicensePlate,
    v.Availability,
    v.Capacity_kg,
    COUNT(d.DeliveryID)                     AS TotalDeliveries,
    SUM(CASE WHEN d.Status='Completed' THEN 1 ELSE 0 END) AS CompletedDeliveries,
    COALESCE(SUM(e.Amount), 0)              AS TotalExpenses
FROM Vehicles  v
LEFT JOIN Deliveries d ON v.VehicleID = d.VehicleID
LEFT JOIN Expenses   e ON d.DeliveryID = e.DeliveryID
GROUP BY v.VehicleID, v.VehicleType, v.LicensePlate, v.Availability, v.Capacity_kg;

