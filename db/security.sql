-- ============================================================
-- DATABASE SECURITY: Roles & Access Control
-- ============================================================
DROP USER 'dispatcher'@'localhost';
DROP USER 'accountant'@'localhost'; 
-- Create users (run as root/admin)
-- Delivery Manager: full read, limited write
CREATE USER IF NOT EXISTS 'delivery_manager'@'localhost' IDENTIFIED BY 'Manager@2025!';
GRANT SELECT, INSERT, UPDATE ON delivery_system.* TO 'delivery_manager'@'localhost';
GRANT EXECUTE ON delivery_system.* TO 'delivery_manager'@'localhost';
 
-- Dispatcher: assign deliveries, update status
CREATE USER IF NOT EXISTS 'dispatcher'@'localhost' IDENTIFIED BY 'Dispatch@2025!';
GRANT SELECT ON delivery_system.* TO 'dispatcher'@'localhost';
GRANT INSERT, UPDATE ON delivery_system.Deliveries TO 'dispatcher'@'localhost';
GRANT UPDATE ON delivery_system.Orders     TO 'dispatcher'@'localhost';
GRANT UPDATE ON delivery_system.Vehicles   TO 'dispatcher'@'localhost';
GRANT EXECUTE ON delivery_system.* TO 'dispatcher'@'localhost';
 
-- Accountant: read all, manage expenses
CREATE USER IF NOT EXISTS 'accountant'@'localhost' IDENTIFIED BY 'Account@2025!';
GRANT SELECT ON delivery_system.* TO 'accountant'@'localhost';
GRANT INSERT, UPDATE, DELETE ON delivery_system.Expenses TO 'accountant'@'localhost';
 
FLUSH PRIVILEGES;