-- ============================================================
-- INDEXES (additional performance indexes)
-- ============================================================
CREATE INDEX  idx_orders_date_status  ON Orders(OrderDate, Status);
CREATE INDEX  idx_expenses_type_amount ON Expenses(ExpenseType, Amount);
CREATE INDEX  idx_deliveries_date_status ON Deliveries(DeliveryDate, Status);