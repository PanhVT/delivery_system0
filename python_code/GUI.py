import streamlit as st
import pandas as pd
import operations as ops

st.set_page_config(page_title="Delivery System", layout="wide")

st.title("🚚 Delivery Management System")

# =============================
# SIDEBAR MENU
# =============================
menu = st.sidebar.radio(
    "Menu",
    ["Dashboard", "Customers", "Orders", "Vehicles", "Deliveries", "Expenses", "Reports"]
)

# =============================
# DASHBOARD
# =============================
# =============================
# DASHBOARD
# =============================
if menu == "Dashboard":

    # ===== STYLE =====
    st.markdown("""
    <style>
    .big-title {
        font-size:40px !important;
        font-weight:700;
    }
    .card {
        background-color: #f8f9fa;
        padding:20px;
        border-radius:15px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        text-align:center;
    }
    </style>
    """, unsafe_allow_html=True)

    # ===== HEADER =====
    st.markdown('<p class="big-title">🚚 Delivery Dashboard</p>', unsafe_allow_html=True)

    # ===== LOAD DATA =====
    orders = ops.get_all_orders()
    vehicles = ops.get_all_vehicles()
    deliveries = ops.get_all_deliveries()

    df_orders = pd.DataFrame(orders)
    df_deliveries = pd.DataFrame(deliveries)

    # ===== KPI CARDS =====
    col1, col2, col3 = st.columns(3)

    with col1:
        st.markdown(f"""
        <div class="card">
            <h3>📦 Orders</h3>
            <h1>{len(orders)}</h1>
        </div>
        """, unsafe_allow_html=True)

    with col2:
        st.markdown(f"""
        <div class="card">
            <h3>🚚 Vehicles</h3>
            <h1>{len(vehicles)}</h1>
        </div>
        """, unsafe_allow_html=True)

    with col3:
        st.markdown(f"""
        <div class="card">
            <h3>📍 Deliveries</h3>
            <h1>{len(deliveries)}</h1>
        </div>
        """, unsafe_allow_html=True)

    st.divider()

    # ===== CHART =====
    st.subheader("📊 Order Status Distribution")

    if not df_orders.empty:
        status_count = df_orders["Status"].value_counts()
        st.bar_chart(status_count)
    else:
        st.info("No data available")

    st.divider()

    # ===== PROGRESS =====
    st.subheader("🚀 Delivery Progress")

    if not df_orders.empty:
        delivered = (df_orders["Status"] == "Delivered").sum()
        total = len(df_orders)

        progress = delivered / total if total > 0 else 0
        st.progress(progress)

        st.write(f"Delivered: {delivered} / {total}")

    st.divider()

    # ===== RECENT DELIVERIES =====
    st.subheader("🚚 Recent Deliveries")

    if not df_deliveries.empty:
        st.dataframe(df_deliveries.head(5), use_container_width=True)
    else:
        st.info("No deliveries yet")


# =============================
# CUSTOMERS
# =============================
elif menu == "Customers":
    st.header("👤 Customer Management")

    tab1, tab2, tab3 = st.tabs([
        "➕ Add Customer",
        "📋 Customer List",
        "🔧 Update / View Customer"
    ])

    # =============================
    # TAB 1: ADD CUSTOMER
    # =============================
    with tab1:
        st.subheader("➕ Add Customer")

        name = st.text_input("Name")
        phone = st.text_input("Phone")
        address = st.text_input("Address")
        email = st.text_input("Email")

        if st.button("Add Customer"):
            try:
                res = ops.add_customer(name, phone, address, email)
                st.success(res)
            except Exception as e:
                st.error(e)

    # =============================
    # TAB 2: LIST + SEARCH
    # =============================
    with tab2:
        st.subheader("📋 Customer List")

        keyword = st.text_input("🔍 Search by name / phone / address")

        data = ops.search_customers(keyword) if keyword else ops.get_all_customers()
        df = pd.DataFrame(data)

        if not df.empty:
            st.dataframe(df, use_container_width=True)
        else:
            st.info("No customers found")

    # =============================
    # TAB 3: UPDATE + VIEW
    # =============================
    with tab3:
        st.subheader("🔧 Update Customer")

        cid = st.text_input("Customer ID")

        name_u = st.text_input("New Name")
        phone_u = st.text_input("New Phone")
        address_u = st.text_input("New Address")
        email_u = st.text_input("New Email")

        if st.button("Update Customer"):
            if cid.isdigit():
                try:
                    res = ops.update_customer(
                        int(cid),
                        CustomerName=name_u if name_u else None,
                        PhoneNumber=phone_u if phone_u else None,
                        Address=address_u if address_u else None,
                        Email=email_u if email_u else None
                    )
                    st.success(res)
                except Exception as e:
                    st.error(e)
            else:
                st.error("Customer ID phải là số")

        st.divider()

        # ===== VIEW CUSTOMER =====
        st.subheader("🔍 View Customer Detail")

        cid_view = st.text_input("Enter Customer ID to view")

        if cid_view:
            if cid_view.isdigit():
                data = ops.get_customer(int(cid_view))

                if data:
                    st.json(data)
                else:
                    st.warning("Customer not found")
            else:
                st.error("Customer ID phải là số")

# =============================
# ORDERS
# =============================
elif menu == "Orders":
    st.header("📦 Order Management")

    tab1, tab2, tab3 = st.tabs([
        "➕ Create Order",
        "📋 Order List",
        "🔧 Update / View Order"
    ])

    # =============================
    # TAB 1: CREATE ORDER
    # =============================
    with tab1:
        st.subheader("➕ Create Order")

        cid = st.number_input("Customer ID", min_value=1, step=1, format="%d")
        pickup = st.text_input("Pickup Address")
        drop = st.text_input("Drop Address")
        weight = st.number_input("Weight", value=1.0)
        notes = st.text_input("Notes")

        if st.button("Create Order"):
            try:
                res = ops.create_order(int(cid), pickup, drop, weight, notes)
                st.success(res)
            except Exception as e:
                st.error(e)

    # =============================
    # TAB 2: ORDER LIST
    # =============================
    with tab2:
        st.subheader("📋 Orders")

        status_filter = st.selectbox(
            "Filter by Status",
            ["All", "Pending", "Assigned", "In Transit", "Delivered", "Cancelled"]
        )

        data = ops.get_all_orders(None if status_filter == "All" else status_filter)
        df = pd.DataFrame(data)

        if not df.empty:
            st.dataframe(df, use_container_width=True)
        else:
            st.info("No orders found")

    # =============================
    # TAB 3: UPDATE + VIEW
    # =============================
    with tab3:
        st.subheader("🔧 Update Order Status")

        oid = st.text_input("Order ID")

        new_status = st.selectbox(
            "New Status",
            ["Pending", "Assigned", "In Transit", "Delivered", "Cancelled"]
        )

        if st.button("Update Status"):
            if oid.isdigit():
                try:
                    res = ops.update_order_status(int(oid), new_status)
                    st.success(res)
                except Exception as e:
                    st.error(e)
            else:
                st.error("Order ID phải là số")

        st.divider()

        # ===== VIEW ORDER DETAIL =====
        st.subheader("🔍 View Order Detail")

        oid_view = st.text_input("Enter Order ID to view")

        if oid_view:
            if oid_view.isdigit():
                data = ops.get_order(int(oid_view))

                if data:
                    st.json(data)   # hiển thị dạng JSON đẹp
                else:
                    st.warning("Order not found")
            else:
                st.error("Order ID phải là số")


# =============================
# VEHICLES
# =============================
elif menu == "Vehicles":
    st.header("🚗 Vehicle Management")

    tab1, tab2, tab3 = st.tabs(["📋 All Vehicles", "✅ Available", "🔧 Update Status"])

    # =============================
    # TAB 1: ADD + ALL VEHICLES
    # =============================
    with tab1:

        with st.expander("➕ Add Vehicle"):
            vtype = st.text_input("Type")
            plate = st.text_input("Plate")
            capacity = st.number_input("Capacity", value=0.0)

            if st.button("Add Vehicle"):
                try:
                    res = ops.add_vehicle(vtype, plate, capacity)
                    st.success(res)
                except Exception as e:
                    st.error(e)

        st.subheader("📋 All Vehicles")

        data = ops.get_all_vehicles()
        df = pd.DataFrame(data)

        if not df.empty:
            st.dataframe(df, use_container_width=True)
        else:
            st.info("No vehicles found")

    # =============================
    # TAB 2: AVAILABLE VEHICLES
    # =============================
    with tab2:
        st.subheader("✅ Available Vehicles")

        data = ops.get_available_vehicles()
        df = pd.DataFrame(data)

        if not df.empty:
            st.success(f"{len(df)} vehicles available")
            st.dataframe(df, use_container_width=True)
        else:
            st.warning("No available vehicles")

    # =============================
    # TAB 3: UPDATE STATUS
    # =============================
    with tab3:
        st.subheader("🔧 Update Vehicle Status")

        vid = st.text_input("Vehicle ID")
        status = st.selectbox("Status", ["Available", "In Use", "Maintenance"])

        if st.button("Update Status"):
            if vid and vid.isdigit():
                try:
                    res = ops.update_vehicle_status(int(vid), status)
                    st.success(res)
                except Exception as e:
                    st.error(e)
            else:
                st.error("Vehicle ID phải là số nguyên")


# =============================
# DELIVERIES
# =============================
elif menu == "Deliveries":
    st.header("📦 Delivery Management")

    tab1, tab2, tab3, tab4 = st.tabs([
        "📋 All Deliveries",
        "➕ Assign Delivery",
        "🚀 Start / Complete",
        "📅 Current Schedule"
    ])

    # =============================
    # TAB 1: ALL DELIVERIES
    # =============================
    with tab1:
        st.subheader("📋 All Deliveries")

        data = ops.get_all_deliveries()
        df = pd.DataFrame(data)

        if not df.empty:
            st.dataframe(df, use_container_width=True)
        else:
            st.info("No deliveries found")

    # =============================
    # TAB 2: ASSIGN DELIVERY
    # =============================
    with tab2:
        st.subheader("➕ Assign Delivery")

        oid = st.text_input("Order ID")
        vid = st.text_input("Vehicle ID")
        date = st.date_input("Delivery Date")
        driver = st.text_input("Driver Name")

        if st.button("Assign"):
            if oid.isdigit() and vid.isdigit():
                try:
                    res = ops.assign_delivery(
                        int(oid),
                        int(vid),
                        str(date),
                        driver
                    )
                    st.success(res)
                except Exception as e:
                    st.error(e)
            else:
                st.error("OrderID & VehicleID phải là số")

    # =============================
    # TAB 3: START / COMPLETE
    # =============================
    with tab3:
        st.subheader("🚀 Manage Delivery")

        did = st.text_input("Delivery ID")

        col1, col2 = st.columns(2)

        with col1:
            if st.button("Start Delivery"):
                if did.isdigit():
                    try:
                        res = ops.start_delivery(int(did))
                        st.success(res)
                    except Exception as e:
                        st.error(e)
                else:
                    st.error("Delivery ID phải là số")

        with col2:
            if st.button("Complete Delivery"):
                if did.isdigit():
                    try:
                        res = ops.complete_delivery(int(did))
                        st.success(res)
                    except Exception as e:
                        st.error(e)
                else:
                    st.error("Delivery ID phải là số")

    # =============================
    # TAB 4: CURRENT SCHEDULE
    # =============================
    with tab4:
        st.subheader("📅 Current Delivery Schedule")

        data = ops.get_current_schedule()
        df = pd.DataFrame(data)

        if not df.empty:
            st.dataframe(df, use_container_width=True)
        else:
            st.info("No active deliveries")

# =============================
# EXPENSES
# =============================
elif menu == "Expenses":
    st.header("💰 Expense Management")

    tab1, tab2, tab3 = st.tabs([
        "➕ Add Expense",
        "📋 View by Delivery",
        "📊 Order Total Cost"
    ])

    # =============================
    # TAB 1: ADD EXPENSE
    # =============================
    with tab1:
        st.subheader("➕ Add Expense")

        did = st.text_input("Delivery ID")
        etype = st.selectbox("Expense Type", ["Fuel", "Toll", "Maintenance", "Other"])
        amount = st.number_input("Amount", min_value=0.0)
        desc = st.text_input("Description")

        if st.button("Add Expense"):
            if did.isdigit():
                try:
                    res = ops.add_expense(int(did), etype, amount, desc)
                    st.success(res)
                except Exception as e:
                    st.error(e)
            else:
                st.error("Delivery ID phải là số")

    # =============================
    # TAB 2: VIEW EXPENSES BY DELIVERY
    # =============================
    with tab2:
        st.subheader("📋 Expenses by Delivery")

        did_view = st.text_input("Enter Delivery ID to view")

        if did_view:
            if did_view.isdigit():
                data = ops.get_delivery_expenses(int(did_view))
                df = pd.DataFrame(data)

                if not df.empty:
                    st.dataframe(df, use_container_width=True)

                    # 👉 tổng tiền luôn
                    total = df["Amount"].sum()
                    st.success(f"Total Expense: {total}")
                else:
                    st.info("No expenses found")
            else:
                st.error("Delivery ID phải là số")

    # =============================
    # TAB 3: TOTAL COST PER ORDER
    # =============================
    with tab3:
        st.subheader("📊 Total Cost per Order")

        oid = st.text_input("Order ID")

        if st.button("Calculate"):
            if oid.isdigit():
                try:
                    total = ops.get_order_total_cost(int(oid))
                    st.success(f"Total Cost: {total}")
                except Exception as e:
                    st.error(e)
            else:
                st.error("Order ID phải là số")

# =============================
# REPORTS
# =============================
elif menu == "Reports":
    st.header("📊 Reports & Analytics")

    tab1, tab2, tab3, tab4, tab5 = st.tabs([
        "📅 Monthly Report",
        "💰 Cost per Order",
        "⚠️ Outstanding Orders",
        "🚚 Vehicle Summary",
        "📈 Expense Breakdown"
    ])

    # =============================
    # TAB 1: MONTHLY REPORT
    # =============================
    with tab1:
        st.subheader("📅 Monthly Report")

        col1, col2 = st.columns(2)
        year = col1.number_input("Year", min_value=2020, max_value=2100, value=2026)
        month = col2.number_input("Month", min_value=1, max_value=12, value=5)

        if st.button("Generate Report"):
            try:
                data = ops.report_monthly(int(year), int(month))

                if data:
                    st.success("Report generated")

                    colA, colB, colC = st.columns(3)
                    colA.metric("Total Orders", data["TotalOrders"])
                    colB.metric("Delivered", data["Delivered"])
                    colC.metric("Cancelled", data["Cancelled"])

                    colD, colE = st.columns(2)
                    colD.metric("In Transit", data["InTransit"])
                    colE.metric("Pending", data["Pending"])

                    st.metric("Total Expenses", f"{data['TotalExpenses']:,.0f}")
                else:
                    st.info("No data")
            except Exception as e:
                st.error(e)

    # =============================
    # TAB 2: COST PER ORDER
    # =============================
    with tab2:
        st.subheader("💰 Cost per Order")

        data = ops.report_cost_per_order()
        df = pd.DataFrame(data)

        if not df.empty:
            st.dataframe(df, use_container_width=True)

            # chart
            st.bar_chart(df.set_index("OrderID")["TotalCost"])
        else:
            st.info("No data")

    # =============================
    # TAB 3: OUTSTANDING ORDERS
    # =============================
    with tab3:
        st.subheader("⚠️ Outstanding Orders")

        data = ops.report_outstanding_orders()
        df = pd.DataFrame(data)

        if not df.empty:
            st.dataframe(df, use_container_width=True)

            st.warning(f"{len(df)} orders not completed")
        else:
            st.success("All orders completed")

    # =============================
    # TAB 4: VEHICLE SUMMARY
    # =============================
    with tab4:
        st.subheader("🚚 Vehicle Summary")

        data = ops.report_vehicle_summary()
        df = pd.DataFrame(data)

        if not df.empty:
            st.dataframe(df, use_container_width=True)

            # chart deliveries
            st.bar_chart(df.set_index("VehicleID")["TotalDeliveries"])
        else:
            st.info("No data")

    # =============================
    # TAB 5: EXPENSE BREAKDOWN
    # =============================
    with tab5:
        st.subheader("📈 Expense Breakdown")

        data = ops.report_expense_breakdown()
        df = pd.DataFrame(data)

        if not df.empty:
            st.dataframe(df, use_container_width=True)

            # chart theo loại chi phí
            st.bar_chart(df.set_index("ExpenseType")["Total"])
        else:
            st.info("No data")
  