# Delivery Service Management System

## Introduction

This project is a **database-driven delivery management system** designed to manage customers, orders, deliveries, vehicles, and expenses.
It enhances operational efficiency through automation using **views, stored procedures, triggers, and role-based access control**.

---

## ⚙️ Technologies Used

* **Database:** MySQL
* **Tools:** MySQL Workbench, GitHub

---

## System Features

### Customer Management

* Add, update, search customers
* Store contact information

### Order Management

* Create delivery orders
* Track status: `Pending → Assigned → In Transit → Delivered`

### Delivery Management

* Assign vehicles using stored procedures
* Track delivery status and schedule

### Vehicle Management

* Manage vehicle info and capacity
* Track availability (Available / In Use / Maintenance)

### Expense Management

* Record delivery expenses
* Prevent invalid data (e.g., negative amounts via triggers)

### Reporting System

* Cost per order
* Outstanding orders
* Vehicle performance
* Monthly reports

---

## Database Design

Main tables:

* Customers
* Orders
* Deliveries
* Vehicles
* Expenses
* AuditLog

Relationships are enforced using **Primary Keys (PK)** and **Foreign Keys (FK)**.

ER Diagram is provided in `/erd`.

---

## Advanced Database Features

### Views

* `vw_current_delivery_schedule` → current deliveries
* `vw_cost_per_order` → total cost per order
* `vw_outstanding_orders` → pending orders
* `vw_vehicle_summary` → vehicle statistics

---

### Stored Procedures

* `sp_assign_delivery` → assign vehicle to order
* `sp_complete_delivery` → complete delivery
* `sp_get_delivery_expenses` → expense breakdown
* `sp_monthly_report` → monthly performance

---

### User Defined Functions

* `fn_avg_delivery_cost`
* `fn_deliveries_per_vehicle`
* `fn_order_total_cost`

---

### Triggers

* Auto update order status when delivery changes
* Prevent invalid data (negative expenses, over capacity)
* Audit logs for INSERT / UPDATE / DELETE
* Block invalid operations (e.g., delete completed delivery)

---

## Database Security (Roles & Access Control)

The system implements **role-based access control (RBAC)** with three main roles:

### Delivery Manager

* Full read access
* Can insert and update data
* Can execute stored procedures

```sql
GRANT SELECT, INSERT, UPDATE ON delivery_system.* TO 'delivery_manager';
GRANT EXECUTE ON delivery_system.* TO 'delivery_manager';
```

---

### Dispatcher

* Assign deliveries
* Update order and vehicle status

```sql
GRANT SELECT ON delivery_system.* TO 'dispatcher';
GRANT INSERT, UPDATE ON delivery_system.Deliveries TO 'dispatcher';
GRANT UPDATE ON delivery_system.Orders TO 'dispatcher';
GRANT UPDATE ON delivery_system.Vehicles TO 'dispatcher';
GRANT EXECUTE ON delivery_system.* TO 'dispatcher';
```

---

### Accountant

* Manage expenses
* Read all data

```sql
GRANT SELECT ON delivery_system.* TO 'accountant';
GRANT INSERT, UPDATE, DELETE ON delivery_system.Expenses TO 'accountant';
```

---

## Project Structure
