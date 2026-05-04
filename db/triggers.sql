-- ============================================================
-- TRIGGERS
-- ============================================================
 
DELIMITER //
 
-- Trigger 1: When delivery is marked Completed -> update Order to Delivered
CREATE TRIGGER  trg_delivery_completed
AFTER UPDATE ON Deliveries
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Completed' AND OLD.Status != 'Completed' THEN
        UPDATE Orders
        SET Status = 'Delivered', UpdatedAt = NOW()
        WHERE OrderID = NEW.OrderID;
 
        UPDATE Vehicles
        SET Availability = 'Available'
        WHERE VehicleID = NEW.VehicleID;
    END IF;
 
    IF NEW.Status = 'In Progress' AND OLD.Status = 'Scheduled' THEN
        UPDATE Orders
        SET Status = 'In Transit', UpdatedAt = NOW()
        WHERE OrderID = NEW.OrderID;
    END IF;
END //
 -- Trigger 2: Prevent negative expense amounts
CREATE TRIGGER  trg_expense_check
BEFORE INSERT ON Expenses
FOR EACH ROW
BEGIN
    IF NEW.Amount < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Expense amount cannot be negative';
    END IF;
END //
-- Trigger 3: Log when new order is created (optional audit)
-- (Requires AuditLog table - created below first)
CREATE TABLE IF NOT EXISTS AuditLog (
    LogID      INT AUTO_INCREMENT PRIMARY KEY,
    TableName  VARCHAR(50),
    Action     VARCHAR(20),
    RecordID   INT,
    ChangedAt  DATETIME DEFAULT CURRENT_TIMESTAMP,
    ChangedBy  VARCHAR(100) 
) ENGINE=InnoDB;
 
CREATE TRIGGER IF NOT EXISTS trg_order_audit
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy)
    VALUES ('Orders', 'INSERT', NEW.OrderID, USER());
END //

-- Trigger 4: Log when an order is updated
CREATE TRIGGER trg_order_update_log
AFTER UPDATE ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TableName, Action, RecordID)
    VALUES ('Orders', 'UPDATE', NEW.OrderID);
END //

-- Trigger 5: Log when an order is deleted
CREATE TRIGGER trg_order_delete_log
AFTER DELETE ON Orders
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TableName, Action, RecordID)
    VALUES ('Orders', 'DELETE', OLD.OrderID);
END //

-- Trigger 6: Không cho tạo Delivery nếu Order đã Cancelled
CREATE TRIGGER trg_block_delivery_if_order_cancelled
BEFORE INSERT ON Deliveries
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT Status INTO v_status
    FROM Orders
    WHERE OrderID = NEW.OrderID;

    IF v_status = 'Cancelled' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot create delivery: Order is Cancelled';
    END IF;
END //

-- Trigger 7: Không cho vượt capacity xe
CREATE TRIGGER trg_check_vehicle_capacity
BEFORE INSERT ON Deliveries
FOR EACH ROW
BEGIN
    DECLARE v_capacity INT;
    DECLARE v_weight INT;

    SELECT Capacity_kg INTO v_capacity
    FROM Vehicles
    WHERE VehicleID = NEW.VehicleID;

    SELECT Weight_kg INTO v_weight
    FROM Orders
    WHERE OrderID = NEW.OrderID;

    IF v_weight > v_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Vehicle capacity exceeded';
    END IF;
END //

-- Trigger 8: Không cho xoá Delivery nếu đã Completed
CREATE TRIGGER trg_block_delete_completed_delivery
BEFORE DELETE ON Deliveries
FOR EACH ROW
BEGIN
    IF OLD.Status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete completed delivery';
    END IF;
END //
 
DELIMITER ;
