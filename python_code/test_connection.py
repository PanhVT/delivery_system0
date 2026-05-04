from db_connection import test_connection

if test_connection():
    print("Kết nối thành công!")
else:
    print("Kết nối thất bại!")