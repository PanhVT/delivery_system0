-- ============================================================
-- USER DEFINED FUNCTIONS
-- ============================================================
 
DELIMITER //
 
-- UDF1: Average delivery cost for a vehicle
CREATE FUNCTION  fn_avg_delivery_cost(p_VehicleID INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_avg DECIMAL(12,2);
    SELECT AVG(total) INTO v_avg
    FROM (
        SELECT d.DeliveryID, SUM(e.Amount) AS total
        FROM Deliveries d
        JOIN Expenses e ON d.DeliveryID = e.DeliveryID
        WHERE d.VehicleID = p_VehicleID
        GROUP BY d.DeliveryID
    ) t;
    RETURN COALESCE(v_avg, 0);
END //

-- UDF2: Number of completed deliveries for a vehicle
CREATE FUNCTION  fn_deliveries_per_vehicle(p_VehicleID INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM Deliveries
    WHERE VehicleID = p_VehicleID AND Status = 'Completed';
    RETURN v_count;
END //

-- UDF3: Total expense amount for an order
CREATE FUNCTION  fn_order_total_cost(p_OrderID INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT SUM(e.Amount) INTO v_total
    FROM Expenses e
    JOIN Deliveries d ON e.DeliveryID = d.DeliveryID
    WHERE d.OrderID = p_OrderID;
    RETURN COALESCE(v_total, 0);
END //
 
DELIMITER ;