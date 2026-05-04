-- ============================================================
-- DELIVERY SERVICE MANAGEMENT SYSTEM
-- Database Schema - MySQL
-- ============================================================
DROP DATABASE delivery_system;
CREATE DATABASE IF NOT EXISTS delivery_system
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE delivery_system;

-- ============================================================
-- TABLE: Customers
-- ============================================================
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID    INT            AUTO_INCREMENT PRIMARY KEY,
    CustomerName  VARCHAR(100)   NOT NULL,
    PhoneNumber   VARCHAR(20)    NOT NULL UNIQUE,
    Address       VARCHAR(255)   NOT NULL,
    Email         VARCHAR(100),
    CreatedAt     DATETIME       DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt     DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_phone (PhoneNumber),
    INDEX idx_name  (CustomerName)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: Vehicles
-- ============================================================
CREATE TABLE IF NOT EXISTS Vehicles (
    VehicleID      INT           AUTO_INCREMENT PRIMARY KEY,
    VehicleType    ENUM('Motorbike','Van','Truck','Bicycle') NOT NULL,
    LicensePlate   VARCHAR(20)   NOT NULL UNIQUE,
    Availability   ENUM('Available','In Use','Maintenance') DEFAULT 'Available',
    Capacity_kg    DECIMAL(8,2)  DEFAULT 0,
    CreatedAt      DATETIME      DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_availability (Availability),
    INDEX idx_type         (VehicleType)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: Orders
-- ============================================================
CREATE TABLE IF NOT EXISTS Orders (
    OrderID        INT           AUTO_INCREMENT PRIMARY KEY,
    CustomerID     INT           NOT NULL,
    OrderDate      DATETIME      DEFAULT CURRENT_TIMESTAMP,
    Status         ENUM('Pending','Assigned','In Transit','Delivered','Cancelled') DEFAULT 'Pending',
    PickupAddress  VARCHAR(255)  NOT NULL,
    DropAddress    VARCHAR(255)  NOT NULL,
    Weight_kg      DECIMAL(8,2)  DEFAULT 1.0,
    Notes          TEXT,
    UpdatedAt      DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE RESTRICT,
    INDEX idx_status      (Status),
    INDEX idx_customer    (CustomerID),
    INDEX idx_order_date  (OrderDate)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: Deliveries
-- ============================================================
CREATE TABLE IF NOT EXISTS Deliveries (
    DeliveryID     INT           AUTO_INCREMENT PRIMARY KEY,
    OrderID        INT           NOT NULL UNIQUE,
    VehicleID      INT           NOT NULL,
    DeliveryDate   DATE          NOT NULL,
    StartTime      DATETIME,
    EndTime        DATETIME,
    Status         ENUM('Scheduled','In Progress','Completed','Failed') DEFAULT 'Scheduled',
    DriverName     VARCHAR(100),
    Notes          TEXT,
    CreatedAt      DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID)   REFERENCES Orders(OrderID)   ON DELETE CASCADE,
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID) ON DELETE RESTRICT,
    INDEX idx_vehicle      (VehicleID),
    INDEX idx_delivery_date (DeliveryDate),
    INDEX idx_status       (Status)
) ENGINE=InnoDB;

-- ============================================================
-- TABLE: Expenses
-- ============================================================
CREATE TABLE IF NOT EXISTS Expenses (
    ExpenseID      INT              AUTO_INCREMENT PRIMARY KEY,
    DeliveryID     INT              NOT NULL,
    ExpenseType    ENUM('Fuel','Toll','Handling','Parking','Maintenance','Other') NOT NULL,
    Amount         DECIMAL(12,2)    NOT NULL CHECK (Amount >= 0),
    Description    VARCHAR(255),
    RecordedAt     DATETIME         DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (DeliveryID) REFERENCES Deliveries(DeliveryID) ON DELETE CASCADE,
    INDEX idx_delivery  (DeliveryID),
    INDEX idx_type      (ExpenseType)
) ENGINE=InnoDB;