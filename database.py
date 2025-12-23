import cx_Oracle

class MedicalDatabase:
    def __init__(self):
        self.connection = None
        self.cursor = None

    def connect(self, user="stud04", password="stud04", dsn="82.179.14.185:1521/nmics"):
        try:
            self.connection = cx_Oracle.connect(
                user=user,
                password=password,
                dsn=dsn
            )
            self.cursor = self.connection.cursor()
            return True
        except cx_Oracle.DatabaseError as e:
            print(f"Ошибка подключения: {e}")
            return False

    def disconnect(self):
        if self.cursor:
            self.cursor.close()
        if self.connection:
            self.connection.close()

    def execute_query(self, query, params=None):
        try:
            if params:
                self.cursor.execute(query, params)
            else:
                self.cursor.execute(query)

            if query.strip().upper().startswith('SELECT'):
                column_names = [i[0] for i in self.cursor.description]
                rows = self.cursor.fetchall()
                return column_names, rows
            else:
                self.connection.commit()
                return None, None

        except cx_Oracle.DatabaseError as e:
            self.connection.rollback()
            raise e

    def call_procedure(self, proc_name, params=None):
        try:
            if params:
                self.cursor.callproc(proc_name, params)
            else:
                self.cursor.callproc(proc_name)

            results = []
            for result_cursor in self.cursor.getimplicitresults():
                columns = [i[0] for i in result_cursor.description]
                rows = result_cursor.fetchall()
                results.append((columns, rows))

            self.connection.commit()
            return results

        except cx_Oracle.DatabaseError as e:
            self.connection.rollback()
            raise e

    def get_table_data(self, table_name):
        query = f"SELECT * FROM {table_name}"
        return self.execute_query(query)

    def insert_medical_org(self, org_id, name, address, org_type):
        self.call_procedure("medical_pkg.insert_medical_org", [org_id, name, address, org_type])

    def update_medical_org(self, org_id, name=None, address=None, org_type=None):
        params = [org_id]
        for param in [name, address, org_type]:
            params.append(param)
        self.call_procedure("medical_pkg.update_medical_org", params)

    def delete_medical_org(self, org_id):
        self.call_procedure("medical_pkg.delete_medical_org", [org_id])

    def insert_staff(self, staff_id, name, role, specialization=None, phone=None):
        params = [staff_id, name, role]
        for param in [specialization, phone]:
            params.append(param)
        self.call_procedure("medical_pkg.insert_staff", params)

    def update_staff(self, staff_id, name=None, role=None, specialization=None, phone=None):
        params = [staff_id]
        for param in [name, role, specialization, phone]:
            params.append(param)
        self.call_procedure("medical_pkg.update_staff", params)

    def delete_staff(self, staff_id):
        self.call_procedure("medical_pkg.delete_staff", [staff_id])

    def insert_patient(self, patient_id, name, birth_date, insurance, clinic_id):
        params = [patient_id, name, birth_date, insurance, clinic_id]
        self.call_procedure("medical_pkg.insert_patient", params)

    def update_patient(self, patient_id, name=None, birth_date=None, insurance=None, clinic_id=None):
        params = [patient_id]
        for param in [name, birth_date, insurance, clinic_id]:
            params.append(param)
        self.call_procedure("medical_pkg.update_patient", params)

    def delete_patient(self, patient_id):
        self.call_procedure("medical_pkg.delete_patient", [patient_id])

    def get_audit_log(self, start_date=None, end_date=None, operation_type=None):
        try:
            cursor_var = self.cursor.var(cx_Oracle.CURSOR)

            self.cursor.callproc("medical_pkg.get_audit_log",
                                 [cursor_var, start_date, end_date, operation_type])

            result_cursor = cursor_var.getvalue()

            if result_cursor:
                columns = [i[0] for i in result_cursor.description]
                rows = result_cursor.fetchall()
                return columns, rows
            else:
                return [], []

        except cx_Oracle.DatabaseError as e:
            raise Exception(f"Ошибка при получении лога: {str(e)}")

    def undo_operation(self, log_id):
        self.call_procedure("medical_pkg.undo_operation", [log_id])

    def get_summary_report(self, flag1=False, flag2=False, flag3=False):
        cursor_var = self.cursor.var(cx_Oracle.CURSOR)

        flag1_str = 'TRUE' if flag1 else 'FALSE'
        flag2_str = 'TRUE' if flag2 else 'FALSE'
        flag3_str = 'TRUE' if flag3 else 'FALSE'

        try:
            self.cursor.callproc("medical_pkg.get_summary_report",
                                 [cursor_var, flag1_str, flag2_str, flag3_str])

            result_cursor = cursor_var.getvalue()
            columns = [i[0] for i in result_cursor.description]
            rows = result_cursor.fetchall()

            return columns, rows

        except cx_Oracle.DatabaseError as e:
            raise e