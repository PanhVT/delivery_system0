"""
operations.py - All CRUD and business-logic functions for the delivery system.
"""

from db_connection import get_cursor
from mysql.connector import Error


# ══════════════════════════════════════════════════════════════════════════════
# CUSTOMER MANAGEMENT
# ══════════════════════════════════════════════════════════════════════════════

def add_customer(name: str, phone: str, address: str, email: str = None) -> dict:
    sql = """INSERT INTO Customers (CustomerName, PhoneNumber, Address, Email)
             VALUES (%s, %s, %s, %s)"""
    with get_cursor() as (conn, cur):
        cur.execute(sql, (name, phone, address, email))
        return {"CustomerID": cur.lastrowid, "CustomerName": name, "status": "created"}


def update_customer(customer_id: int, **kwargs) -> dict:
    allowed = {"CustomerName", "PhoneNumber", "Address", "Email"}
    fields  = {k: v for k, v in kwargs.items() if k in allowed}
    if not fields:
        return {"status": "no valid fields to update"}
    set_clause = ", ".join(f"{k}=%s" for k in fields)
    sql = f"UPDATE Customers SET {set_clause} WHERE CustomerID=%s"
    with get_cursor() as (conn, cur):
        cur.execute(sql, (*fields.values(), customer_id))
        return {"CustomerID": customer_id, "updated": list(fields.keys()), "status": "ok"}


def get_all_customers() -> list:
    with get_cursor() as (conn, cur):
        cur.execute("SELECT * FROM Customers ORDER BY CustomerID")
        return cur.fetchall()


def get_customer(customer_id: int) -> dict | None:
    with get_cursor() as (conn, cur):
        cur.execute("SELECT * FROM Customers WHERE CustomerID=%s", (customer_id,))
        return cur.fetchone()


def search_customers(keyword: str) -> list:
    like = f"%{keyword}%"
    sql  = """SELECT * FROM Customers
              WHERE CustomerName LIKE %s OR PhoneNumber LIKE %s OR Address LIKE %s"""
    with get_cursor() as (conn, cur):
        cur.execute(sql, (like, like, like))
        return cur.fetchall()


# ══════════════════════════════════════════════════════════════════════════════
# VEHICLE MANAGEMENT
# ══════════════════════════════════════════════════════════════════════════════

def add_vehicle(vtype: str, plate: str, capacity: float = 0.0) -> dict:
    sql = "INSERT INTO Vehicles (VehicleType, LicensePlate, Capacity_kg) VALUES (%s, %s, %s)"
    with get_cursor() as (conn, cur):
        cur.execute(sql, (vtype, plate, capacity))
        return {"VehicleID": cur.lastrowid, "status": "created"}


def get_all_vehicles() -> list:
    with get_cursor() as (conn, cur):
        cur.execute("SELECT * FROM Vehicles ORDER BY VehicleID")
        return cur.fetchall()


def get_available_vehicles() -> list:
    with get_cursor() as (conn, cur):
        cur.execute("SELECT * FROM Vehicles WHERE Availability='Available'")
        return cur.fetchall()


def update_vehicle_status(vehicle_id: int, status: str) -> dict:
    allowed = {"Available", "In Use", "Maintenance"}
    if status not in allowed:
        return {"status": "invalid", "allowed": list(allowed)}
    with get_cursor() as (conn, cur):
        cur.execute("UPDATE Vehicles SET Availability=%s WHERE VehicleID=%s",
                    (status, vehicle_id))
        return {"VehicleID": vehicle_id, "Availability": status, "status": "updated"}


# ══════════════════════════════════════════════════════════════════════════════
# ORDER MANAGEMENT
# ══════════════════════════════════════════════════════════════════════════════

def create_order(customer_id: int, pickup: str, drop: str,
                 weight: float = 1.0, notes: str = None) -> dict:
    sql = """INSERT INTO Orders (CustomerID, PickupAddress, DropAddress, Weight_kg, Notes)
             VALUES (%s, %s, %s, %s, %s)"""
    with get_cursor() as (conn, cur):
        cur.execute(sql, (customer_id, pickup, drop, weight, notes))
        return {"OrderID": cur.lastrowid, "status": "created"}


def update_order_status(order_id: int, status: str) -> dict:
    allowed = {"Pending", "Assigned", "In Transit", "Delivered", "Cancelled"}
    if status not in allowed:
        return {"status": "invalid"}
    with get_cursor() as (conn, cur):
        cur.execute("UPDATE Orders SET Status=%s WHERE OrderID=%s", (status, order_id))
        return {"OrderID": order_id, "Status": status, "status": "updated"}


def get_all_orders(status_filter: str = None) -> list:
    with get_cursor() as (conn, cur):
        if status_filter:
            cur.execute(
                """SELECT o.*, c.CustomerName FROM Orders o
                   JOIN Customers c ON o.CustomerID=c.CustomerID
                   WHERE o.Status=%s ORDER BY o.OrderDate DESC""",
                (status_filter,)
            )
        else:
            cur.execute(
                """SELECT o.*, c.CustomerName FROM Orders o
                   JOIN Customers c ON o.CustomerID=c.CustomerID
                   ORDER BY o.OrderDate DESC"""
            )
        return cur.fetchall()


def get_order(order_id: int) -> dict | None:
    with get_cursor() as (conn, cur):
        cur.execute(
            """SELECT o.*, c.CustomerName, c.PhoneNumber
               FROM Orders o JOIN Customers c ON o.CustomerID=c.CustomerID
               WHERE o.OrderID=%s""",
            (order_id,)
        )
        return cur.fetchone()


# ══════════════════════════════════════════════════════════════════════════════
# DELIVERY MANAGEMENT (uses stored procedure)
# ══════════════════════════════════════════════════════════════════════════════

def assign_delivery(order_id: int, vehicle_id: int,
                    delivery_date: str, driver_name: str) -> str:
    with get_cursor() as (conn, cur):
        cur.callproc("sp_assign_delivery",
                     [order_id, vehicle_id, delivery_date, driver_name, ""])
        for res in cur.stored_results():
            row = res.fetchone()
            if row:
                return list(row.values())[0]
        return "UNKNOWN"


def complete_delivery(delivery_id: int) -> str:
    with get_cursor() as (conn, cur):
        cur.callproc("sp_complete_delivery", [delivery_id, ""])
        for res in cur.stored_results():
            row = res.fetchone()
            if row:
                return list(row.values())[0]
        return "UNKNOWN"


def start_delivery(delivery_id: int) -> dict:
    with get_cursor() as (conn, cur):
        cur.execute(
            "UPDATE Deliveries SET Status='In Progress', StartTime=NOW() WHERE DeliveryID=%s",
            (delivery_id,)
        )
        return {"DeliveryID": delivery_id, "status": "In Progress"}


def get_all_deliveries() -> list:
    with get_cursor() as (conn, cur):
        cur.execute(
            """SELECT d.*, o.PickupAddress, o.DropAddress, c.CustomerName,
                      v.LicensePlate, v.VehicleType
               FROM Deliveries d
               JOIN Orders    o ON d.OrderID    = o.OrderID
               JOIN Customers c ON o.CustomerID = c.CustomerID
               JOIN Vehicles  v ON d.VehicleID  = v.VehicleID
               ORDER BY d.DeliveryDate DESC"""
        )
        return cur.fetchall()


def get_current_schedule() -> list:
    with get_cursor() as (conn, cur):
        cur.execute("SELECT * FROM vw_current_delivery_schedule")
        return cur.fetchall()


# ══════════════════════════════════════════════════════════════════════════════
# EXPENSE MANAGEMENT
# ══════════════════════════════════════════════════════════════════════════════

def add_expense(delivery_id: int, expense_type: str,
                amount: float, description: str = None) -> dict:
    sql = """INSERT INTO Expenses (DeliveryID, ExpenseType, Amount, Description)
             VALUES (%s, %s, %s, %s)"""
    with get_cursor() as (conn, cur):
        cur.execute(sql, (delivery_id, expense_type, amount, description))
        return {"ExpenseID": cur.lastrowid, "status": "created"}


def get_delivery_expenses(delivery_id: int) -> list:
    with get_cursor() as (conn, cur):
        cur.execute(
            "SELECT * FROM Expenses WHERE DeliveryID=%s ORDER BY RecordedAt",
            (delivery_id,)
        )
        return cur.fetchall()


def get_order_total_cost(order_id: int) -> float:
    with get_cursor() as (conn, cur):
        cur.execute("SELECT fn_order_total_cost(%s) AS total", (order_id,))
        row = cur.fetchone()
        return float(row["total"]) if row else 0.0


# ══════════════════════════════════════════════════════════════════════════════
# REPORTS
# ══════════════════════════════════════════════════════════════════════════════

def report_monthly(year: int, month: int) -> dict | None:
    with get_cursor() as (conn, cur):
        cur.callproc("sp_monthly_report", [year, month])
        for res in cur.stored_results():
            return res.fetchone()
    return None


def report_cost_per_order() -> list:
    with get_cursor() as (conn, cur):
        cur.execute("SELECT * FROM vw_cost_per_order ORDER BY OrderDate DESC")
        return cur.fetchall()


def report_outstanding_orders() -> list:
    with get_cursor() as (conn, cur):
        cur.execute("SELECT * FROM vw_outstanding_orders")
        return cur.fetchall()


def report_vehicle_summary() -> list:
    with get_cursor() as (conn, cur):
        cur.execute("SELECT * FROM vw_vehicle_summary ORDER BY TotalDeliveries DESC")
        return cur.fetchall()


def report_expense_breakdown() -> list:
    with get_cursor() as (conn, cur):
        cur.execute(
            """SELECT ExpenseType,
                      COUNT(*)    AS Count,
                      SUM(Amount) AS Total,
                      AVG(Amount) AS Average,
                      MAX(Amount) AS Maximum
               FROM Expenses
               GROUP BY ExpenseType
               ORDER BY Total DESC"""
        )
        return cur.fetchall()
    

if __name__ == "__main__":
    print("===== TEST START =====")

    # 1. Add Customer
    print("\n--- Add Customer ---")
    customer = add_customer("Test User", "0123456786", "Hanoi", "test@gmail.com")
    print(customer)

    customer_id = customer["CustomerID"]

    # 2. Get All Customers
    print("\n--- All Customers ---")
    customers = get_all_customers()
    for c in customers:
        print(c)

    # 3. Create Order
    print("\n--- Create Order ---")
    order = create_order(
        customer_id,
        "Hanoi",
        "Ho Chi Minh",
        2.5,
        "Fragile"
    )
    print(order)

    order_id = order["OrderID"]

    # 4. Assign Delivery
    print("\n--- Assign Delivery ---")

    #  cần có vehicle sẵn
    vehicles = get_all_vehicles()
    if not vehicles:
        print(" No vehicles found. Add vehicle first!")
    else:
        vehicle_id = vehicles[0]["VehicleID"]

        result = assign_delivery(
            order_id,
            vehicle_id,
            "2026-05-03",
            "Driver A"
        )
        print(result)

    # 5. Report
    print("\n--- Report Cost Per Order ---")
    report = report_cost_per_order()
    for r in report:
        print(r)

    print("\n===== TEST END =====")