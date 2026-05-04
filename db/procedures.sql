DELIMITER //
-- Assign a vehicle to an order
CREATE PROCEDURE  sp_assign_delivery(
	IN p_OrderID INT,
    IN p_VehicleID INT,
    IN p_DeliveryDate DATE,
    IN p_DriverName  VARCHAR(100),
    OUT p_Result     VARCHAR(200)  )
    
BEGIN 
	DECLARE v_order_status   VARCHAR(20);
    DECLARE v_vehicle_avail  VARCHAR(20);
    -- Check order exists and is Pending
    SELECT Status into v_order_status from Orders WHERE OrderID = p_OrderID;
    IF v_order_status IS NULL THEN
        SET p_Result = 'ERROR: Order not found';
    ELSEIF v_order_status != 'Pending' THEN
        SET p_Result = CONCAT('ERROR: Order status is ', v_order_status, ', must be Pending');
    ELSE
    -- Check vehicle availability
        SELECT Availability INTO v_vehicle_avail
        FROM Vehicles WHERE VehicleID = p_VehicleID;
 
        IF v_vehicle_avail IS NULL THEN
            SET p_Result = 'ERROR: Vehicle not found';
        ELSEIF v_vehicle_avail != 'Available' THEN
            SET p_Result = CONCAT('ERROR: Vehicle is ', v_vehicle_avail);
        ELSE
            -- Create delivery
            INSERT INTO Deliveries (OrderID, VehicleID, DeliveryDate, DriverName, Status)
            VALUES (p_OrderID, p_VehicleID, p_DeliveryDate, p_DriverName, 'Scheduled');
 
            -- Update order status
            UPDATE Orders SET Status = 'Assigned' WHERE OrderID = p_OrderID;
 
            -- Mark vehicle as In Use
            UPDATE Vehicles SET Availability = 'In Use' WHERE VehicleID = p_VehicleID;
 
            SET p_Result = CONCAT('SUCCESS: Delivery ID ', LAST_INSERT_ID(), ' created');
        END IF;
    END IF;
    SELECT p_Result AS message;
END //
 
-- SP2: Calculate total expenses for a delivery
CREATE PROCEDURE sp_get_delivery_expenses(
    IN p_DeliveryID INT
)
BEGIN
    -- Check delivery tồn tại
    IF NOT EXISTS (
        SELECT 1 FROM Deliveries WHERE DeliveryID = p_DeliveryID
    ) THEN
        SELECT 'ERROR: Delivery not found' AS ExpenseType, 0 AS SubTotal, 0 AS ItemCount;
    
    ELSE
        -- Trả kết quả chi tiết + tổng
        SELECT *
        FROM (
            -- Chi tiết theo từng loại chi phí
            SELECT
                e.ExpenseType,
                COALESCE(SUM(e.Amount), 0) AS SubTotal,
                COUNT(*) AS ItemCount,
                0 AS sort_order
            FROM Expenses e
            WHERE e.DeliveryID = p_DeliveryID
            GROUP BY e.ExpenseType

            UNION ALL

            -- Tổng tất cả
            SELECT
                'TOTAL' AS ExpenseType,
                COALESCE(SUM(e.Amount), 0) AS SubTotal,
                COUNT(*) AS ItemCount,
                1 AS sort_order
            FROM Expenses e
            WHERE e.DeliveryID = p_DeliveryID
        ) AS result
        ORDER BY sort_order, ExpenseType;

    END IF;
END //

-- SP3: Complete a delivery
CREATE PROCEDURE IF NOT EXISTS sp_complete_delivery(
    IN  p_DeliveryID INT,
    OUT p_Result     VARCHAR(200)
)
BEGIN
    DECLARE v_status    VARCHAR(20);
    DECLARE v_orderID   INT;
    DECLARE v_vehicleID INT;
 
    SELECT Status, OrderID, VehicleID
    INTO v_status, v_orderID, v_vehicleID
    FROM Deliveries WHERE DeliveryID = p_DeliveryID;
 
    IF v_status IS NULL THEN
        SET p_Result = 'ERROR: Delivery not found';
    ELSEIF v_status = 'Completed' THEN
        SET p_Result = 'INFO: Already completed';
    ELSE
        UPDATE Deliveries
        SET Status = 'Completed', EndTime = NOW()
        WHERE DeliveryID = p_DeliveryID;
 
        UPDATE Orders
        SET Status = 'Delivered'
        WHERE OrderID = v_orderID;
 
        UPDATE Vehicles
        SET Availability = 'Available'
        WHERE VehicleID = v_vehicleID;
 
        SET p_Result = 'SUCCESS: Delivery completed';
    END IF;
END //

-- SP4: Monthly performance report
CREATE PROCEDURE  sp_monthly_report(
    IN p_year  INT,
    IN p_month INT
)
BEGIN
    /* =========================
       1. Orders summary (NO JOIN)
       ========================= */
    SELECT
        o.TotalOrders,
        o.Delivered,
        o.Cancelled,
        o.InTransit,
        o.Pending,
        COALESCE(e.TotalExpenses, 0)        AS TotalExpenses,
        COALESCE(e.AvgExpense, 0)           AS AvgExpensePerRecord
    FROM
    (
        SELECT
            COUNT(*) AS TotalOrders,

            SUM(CASE WHEN Status = 'Delivered' THEN 1 ELSE 0 END) AS Delivered,
            SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
            SUM(CASE WHEN Status = 'In Transit' THEN 1 ELSE 0 END) AS InTransit,
            SUM(CASE WHEN Status = 'Pending' THEN 1 ELSE 0 END) AS Pending

        FROM Orders
        WHERE OrderDate >= STR_TO_DATE(CONCAT(p_year,'-',p_month,'-01'), '%Y-%m-%d')
          AND OrderDate <  DATE_ADD(
                                STR_TO_DATE(CONCAT(p_year,'-',p_month,'-01'), '%Y-%m-%d'),
                                INTERVAL 1 MONTH
                            )
    ) o

    /* =========================
       2. Expense summary (separate aggregation → tránh double count)
       ========================= */
    LEFT JOIN
    (
        SELECT
            SUM(e.Amount) AS TotalExpenses,
            AVG(e.Amount) AS AvgExpense
        FROM Expenses e
        JOIN Deliveries d ON e.DeliveryID = d.DeliveryID
        JOIN Orders o2 ON d.OrderID = o2.OrderID
        WHERE o2.OrderDate >= STR_TO_DATE(CONCAT(p_year,'-',p_month,'-01'), '%Y-%m-%d')
          AND o2.OrderDate <  DATE_ADD(
                                STR_TO_DATE(CONCAT(p_year,'-',p_month,'-01'), '%Y-%m-%d'),
                                INTERVAL 1 MONTH
                            )
    ) e ON 1=1;

END //

DELIMITER ;