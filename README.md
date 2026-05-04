# Delivery Service Management System

## Introduction

This project is a **database-driven delivery management system** designed to manage customers, orders, deliveries, vehicles, and expenses.
It enhances operational efficiency through automation using **views, stored procedures, triggers, and role-based access control**.

---

## ⚙️ Technologies Used

* **Database:** MySQL
* **Programming Language:** Python
* **Libraries:** mysql-connector-python, Tkinter
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

##  Database Security (Roles & Access Control)

The system implements **role-based access control (RBAC)** with three main roles:

###  Delivery Manager

* Full read access
* Can insert and update data
* Can execute stored procedures

```sql id="m9l8yt"
GRANT SELECT, INSERT, UPDATE ON delivery_system.* TO 'delivery_manager';
GRANT EXECUTE ON delivery_system.* TO 'delivery_manager';
```

---

###  Dispatcher

* Assign deliveries
* Update order and vehicle status

```sql id="7r5kdn"
GRANT SELECT ON delivery_system.* TO 'dispatcher';
GRANT INSERT, UPDATE ON delivery_system.Deliveries TO 'dispatcher';
GRANT UPDATE ON delivery_system.Orders TO 'dispatcher';
GRANT UPDATE ON delivery_system.Vehicles TO 'dispatcher';
GRANT EXECUTE ON delivery_system.* TO 'dispatcher';
```

---

###  Accountant

* Manage expenses
* Read all data

```sql id="u9xqk2"
GRANT SELECT ON delivery_system.* TO 'accountant';
GRANT INSERT, UPDATE, DELETE ON delivery_system.Expenses TO 'accountant';
```

---

##  Project Structure

```id="z2tw0e"
delivery-system/
│
├── db/
│   ├── schema.sql
│   ├── sample_data.sql
│   ├── procedures.sql
│   ├── index.sql
│   ├── users_defined_functions.sql
│   ├── triggers.sql
│   ├── views.sql
│   └── security.sql
│
├── python/
│   ├── operations.py
│   ├── GUI.py
│   ├── test_connection.py
│   └── db_connection.py
│
├── erd/
│   ├── er_digram.png
│   └── relational_schema.mwb
│
├── README.md
```

---

## How to Run

### 1. Setup Database

Run SQL files in order:

1. `schema.sql`
2. `sample_data.sql`
3. `views.sql`
4. `index.sql`
5. `procedures.sql`
6. `users_defined_functions.sql`
7. `triggers.sql`
8. `security.sql`

---

### 2. Configure Database Connection

Edit `db_connection.py`:

```python id="h5r1ts"
host="localhost"
user="root"
password="your_password"
database="delivery_system"
```

---

### 3. Run Application

```bash id="1kz8t0"
python GUI.py
```

---

## 📊 Sample Workflow

1. Add customer
2. Create order
3. Assign delivery
4. Track delivery
5. Add expenses
6. Generate reports

---

## Limitations

* No real-time GPS tracking
* Limited error handling for complex real-world scenarios
* Some aggregation queries may become inefficient with large data volumes

---

## Future Improvements

* GPS tracking integration
* Mobile application
* Optimize query performance using caching or advanced indexing techniques
* Email/SMS notifications

---

## Author

* Name: Vũ Thị Phương Anh
* University: National Economics University

---

## References

* MySQL Documentation
* Python Documentation
* Course materials
