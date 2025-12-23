import sys
from PyQt5 import QtWidgets, uic
from PyQt5.QtWidgets import QMessageBox
from database import MedicalDatabase


class MedicalApp(QtWidgets.QMainWindow):
    def __init__(self):
        super(MedicalApp, self).__init__()
        uic.loadUi('desk.ui', self)

        self.db = MedicalDatabase()
        if not self.db.connect():
            QMessageBox.critical(self, "Ошибка", "Не удалось подключиться к базе данных!")
            sys.exit(1)

        self.connect_signals()
        self.load_table_data()

    """Методы для подключения и загрузки первоначальных данных"""
    def connect_signals(self):
        self.loadTableButton.clicked.connect(self.load_table_data)

        self.insertOrgButton.clicked.connect(self.insert_medical_org)
        self.updateOrgButton.clicked.connect(self.update_medical_org)
        self.deleteOrgButton.clicked.connect(self.delete_medical_org)
        self.clearOrgButton.clicked.connect(self.clear_medical_org_form)

        self.insertStaffButton.clicked.connect(self.insert_staff)
        self.updateStaffButton.clicked.connect(self.update_staff)
        self.deleteStaffButton.clicked.connect(self.delete_staff)
        self.clearStaffButton.clicked.connect(self.clear_staff_form)

        self.insertPatientButton.clicked.connect(self.insert_patient)
        self.updatePatientButton.clicked.connect(self.update_patient)
        self.deletePatientButton.clicked.connect(self.delete_patient)
        self.clearPatientButton.clicked.connect(self.clear_patient_form)

        self.loadAuditButton.clicked.connect(self.load_audit_log)
        self.undoButton.clicked.connect(self.undo_operation)
        self.generateReportButton.clicked.connect(self.generate_report)

    def load_table_data(self):
        table_name = self.tableComboBox.currentText()
        try:
            columns, rows = self.db.get_table_data(table_name)

            from PyQt5.QtGui import QStandardItemModel, QStandardItem

            model = QStandardItemModel()
            model.setHorizontalHeaderLabels(columns)

            for row in rows:
                items = [QStandardItem(str(item) if item is not None else "") for item in row]
                model.appendRow(items)

            self.tableView.setModel(model)
            self.tableView.resizeColumnsToContents()

            self.statusbar.showMessage(f"Загружено {len(rows)} записей из таблицы {table_name}")

        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось загрузить данные: {str(e)}")

    """Методы для медицинских организаций"""
    def insert_medical_org(self):
        try:
            org_id = int(self.orgIdEdit.text())

            query = "SELECT COUNT(*) FROM medical_org WHERE org_id = :1"
            self.db.cursor.execute(query, [org_id])
            count = self.db.cursor.fetchone()[0]

            if count != 0:
                QMessageBox.warning(self, "Предупреждение",
                                    f"Организация с ID {org_id} уже существует!")
                return

            name = self.orgNameEdit.text()
            address = self.orgAddressEdit.text()
            org_type = self.orgTypeCombo.currentText()

            self.db.insert_medical_org(org_id, name, address, org_type)
            QMessageBox.information(self, "Успех", "Организация добавлена успешно!")
            self.clear_medical_org_form()

        except ValueError:
            QMessageBox.warning(self, "Ошибка", "ID должен быть числом!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось добавить организацию: {str(e)}")

    def update_medical_org(self):
        try:
            org_id = int(self.orgIdEdit.text())

            query = "SELECT COUNT(*) FROM medical_org WHERE org_id = :1"
            self.db.cursor.execute(query, [org_id])
            count = self.db.cursor.fetchone()[0]

            if count == 0:
                QMessageBox.warning(self, "Предупреждение",
                                    f"Организация с ID {org_id} не существует!")
                return

            name = self.orgNameEdit.text() if self.orgNameEdit.text() else None
            address = self.orgAddressEdit.text() if self.orgAddressEdit.text() else None
            org_type = self.orgTypeCombo.currentText()

            self.db.update_medical_org(org_id, name, address, org_type)
            QMessageBox.information(self, "Успех", "Данные организации обновлены успешно!")

        except ValueError:
            QMessageBox.warning(self, "Ошибка", "ID должен быть числом!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось обновить организацию: {str(e)}")

    def delete_medical_org(self):
        try:
            org_id = int(self.orgIdEdit.text())

            query = "SELECT COUNT(*) FROM medical_org WHERE org_id = :1"
            self.db.cursor.execute(query, [org_id])
            count = self.db.cursor.fetchone()[0]

            if count == 0:
                QMessageBox.warning(self, "Предупреждение",
                                    f"Организация с ID {org_id} не существует!")
                return

            reply = QMessageBox.question(self, 'Подтверждение',
                                         f'Вы уверены, что хотите удалить организацию с ID {org_id}?',
                                         QMessageBox.Yes | QMessageBox.No)

            if reply == QMessageBox.Yes:
                self.db.delete_medical_org(org_id)
                QMessageBox.information(self, "Успех", "Организация удалена успешно!")
                self.clear_medical_org_form()

        except ValueError:
            QMessageBox.warning(self, "Ошибка", "ID должен быть числом!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось удалить организацию: {str(e)}")

    def clear_medical_org_form(self):
        self.orgIdEdit.clear()
        self.orgNameEdit.clear()
        self.orgAddressEdit.clear()
        self.orgTypeCombo.setCurrentIndex(0)

    """Методы для персонала"""
    def insert_staff(self):
        try:
            staff_id = int(self.staffIdEdit.text())

            query = "SELECT COUNT(*) FROM staff WHERE staff_id = :1"
            self.db.cursor.execute(query, [staff_id])
            count = self.db.cursor.fetchone()[0]

            if count != 0:
                QMessageBox.warning(self, "Предупреждение",
                                    f"Сотрудник с ID {staff_id} уже существует!")
                return

            name = self.staffNameEdit.text()
            role = self.staffRoleCombo.currentText()
            specialization = self.staffSpecEdit.text() if self.staffSpecEdit.text() else None
            phone = self.staffPhoneEdit.text() if self.staffPhoneEdit.text() else None

            self.db.insert_staff(staff_id, name, role, specialization, phone)
            QMessageBox.information(self, "Успех", "Сотрудник добавлен успешно!")
            self.clear_staff_form()

        except ValueError:
            QMessageBox.warning(self, "Ошибка", "ID должен быть числом!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось добавить сотрудника: {str(e)}")

    def update_staff(self):
        try:
            staff_id = int(self.staffIdEdit.text())

            query = "SELECT COUNT(*) FROM staff WHERE staff_id = :1"
            self.db.cursor.execute(query, [staff_id])
            count = self.db.cursor.fetchone()[0]

            if count == 0:
                QMessageBox.warning(self, "Предупреждение",
                                    f"Сотрудник с ID {staff_id} не существует!")
                return

            name = self.staffNameEdit.text() if self.staffNameEdit.text() else None
            role = self.staffRoleCombo.currentText() if self.staffRoleCombo.currentText() != "doctor" else None
            specialization = self.staffSpecEdit.text() if self.staffSpecEdit.text() else None
            phone = self.staffPhoneEdit.text() if self.staffPhoneEdit.text() else None

            self.db.update_staff(staff_id, name, role, specialization, phone)
            QMessageBox.information(self, "Успех", "Данные сотрудника обновлены успешно!")

        except ValueError:
            QMessageBox.warning(self, "Ошибка", "ID должен быть числом!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось обновить сотрудника: {str(e)}")

    def delete_staff(self):
        try:
            staff_id = int(self.staffIdEdit.text())

            query = "SELECT COUNT(*) FROM staff WHERE staff_id = :1"
            self.db.cursor.execute(query, [staff_id])
            count = self.db.cursor.fetchone()[0]

            if count == 0:
                QMessageBox.warning(self, "Предупреждение",
                                    f"Сотрудник с ID {staff_id} не существует!")
                return

            reply = QMessageBox.question(self, 'Подтверждение',
                                         f'Вы уверены, что хотите удалить сотрудника с ID {staff_id}?',
                                         QMessageBox.Yes | QMessageBox.No)

            if reply == QMessageBox.Yes:
                self.db.delete_staff(staff_id)
                QMessageBox.information(self, "Успех", "Сотрудник удален успешно!")
                self.clear_staff_form()
                self.load_table_data()  # Обновляем таблицу просмотра

        except ValueError:
            QMessageBox.warning(self, "Ошибка", "ID должен быть числом!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось удалить сотрудника: {str(e)}")

    def clear_staff_form(self):
        self.staffIdEdit.clear()
        self.staffNameEdit.clear()
        self.staffRoleCombo.setCurrentIndex(0)
        self.staffSpecEdit.clear()
        self.staffPhoneEdit.clear()

    """Методы для пациентов"""
    def insert_patient(self):
        try:
            patient_id = int(self.patientIdEdit.text())

            query = "SELECT COUNT(*) FROM patient WHERE patient_id = :1"
            self.db.cursor.execute(query, [patient_id])
            count = self.db.cursor.fetchone()[0]

            if count != 0:
                QMessageBox.warning(self, "Предупреждение",
                                    f"Пациент с ID {patient_id} уже существует!")
                return

            name = self.patientNameEdit.text()
            birth_date = self.patientBirthEdit.text()
            insurance = self.patientInsuranceEdit.text()
            clinic_id = int(self.patientClinicEdit.text()) if self.patientClinicEdit.text() else None

            self.db.insert_patient(patient_id, name, birth_date, insurance, clinic_id)
            QMessageBox.information(self, "Успех", "Пациент добавлен успешно!")
            self.clear_patient_form()

        except ValueError as e:
            QMessageBox.warning(self, "Ошибка", "Проверьте правильность введенных данных!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось добавить пациента: {str(e)}")

    def update_patient(self):
        try:
            patient_id = int(self.patientIdEdit.text())

            query = "SELECT COUNT(*) FROM patient WHERE patient_id = :1"
            self.db.cursor.execute(query, [patient_id])
            count = self.db.cursor.fetchone()[0]

            if count == 0:
                QMessageBox.warning(self, "Предупреждение",
                                    f"Пациент с ID {patient_id} не существует!")
                return

            name = self.patientNameEdit.text() if self.patientNameEdit.text() else None
            birth_date = self.patientBirthEdit.text() if self.patientBirthEdit.text() else None
            insurance = self.patientInsuranceEdit.text() if self.patientInsuranceEdit.text() else None
            clinic_id = int(self.patientClinicEdit.text()) if self.patientClinicEdit.text() else None

            self.db.update_patient(patient_id, name, birth_date, insurance, clinic_id)
            QMessageBox.information(self, "Успех", "Данные пациента обновлены успешно!")

        except ValueError:
            QMessageBox.warning(self, "Ошибка", "Проверьте правильность введенных данных!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось обновить пациента: {str(e)}")

    def delete_patient(self):
        try:
            patient_id = int(self.patientIdEdit.text())

            query = "SELECT COUNT(*) FROM patient WHERE patient_id = :1"
            self.db.cursor.execute(query, [patient_id])
            count = self.db.cursor.fetchone()[0]

            if count == 0:
                QMessageBox.warning(self, "Предупреждение",
                                    f"Пациент с ID {patient_id} не существует!")
                return

            reply = QMessageBox.question(self, 'Подтверждение',
                                         f'Вы уверены, что хотите удалить пациента с ID {patient_id}?',
                                         QMessageBox.Yes | QMessageBox.No)

            if reply == QMessageBox.Yes:
                self.db.delete_patient(patient_id)
                QMessageBox.information(self, "Успех", "Пациент удален успешно!")
                self.clear_patient_form()

        except ValueError:
            QMessageBox.warning(self, "Ошибка", "ID должен быть числом!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось удалить пациента: {str(e)}")

    def clear_patient_form(self):
        self.patientIdEdit.clear()
        self.patientNameEdit.clear()
        self.patientBirthEdit.clear()
        self.patientInsuranceEdit.clear()
        self.patientClinicEdit.clear()

    """Методы для логов"""
    def load_audit_log(self):
        try:
            start_date = self.startDateEdit.text() if self.startDateEdit.text() else None
            end_date = self.endDateEdit.text() if self.endDateEdit.text() else None
            operation_type = self.operationTypeCombo.currentText()
            operation_type = None if operation_type == "Все" else operation_type

            result = self.db.get_audit_log(start_date, end_date, operation_type)

            if result:
                columns, rows = result

                from PyQt5.QtGui import QStandardItemModel, QStandardItem

                model = QStandardItemModel()
                model.setHorizontalHeaderLabels(columns)

                for row in rows:
                    items = [QStandardItem(str(item) if item is not None else "") for item in row]
                    model.appendRow(items)

                self.auditTableView.setModel(model)
                self.auditTableView.resizeColumnsToContents()

                self.statusbar.showMessage(f"Загружено {len(rows)} записей из лога")
            else:
                QMessageBox.information(self, "Информация", "Нет данных для отображения")

        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось загрузить лог: {str(e)}")

    def undo_operation(self):
        try:
            log_id = int(self.undoIdEdit.text())

            reply = QMessageBox.question(self, 'Подтверждение',
                                         f'Вы уверены, что хотите отменить операцию с ID {log_id}?',
                                         QMessageBox.Yes | QMessageBox.No)

            if reply == QMessageBox.Yes:
                self.db.undo_operation(log_id)
                QMessageBox.information(self, "Успех", "Операция отменена успешно!")
                self.undoIdEdit.clear()

                self.load_audit_log()
                self.load_table_data()

                current_table = self.tableComboBox.currentText()
                if current_table != 'audit_log':
                    self.load_table_data()

        except ValueError:
            QMessageBox.warning(self, "Ошибка", "ID должен быть числом!")
        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось отменить операцию: {str(e)}")

    """Метод для отчетов"""
    def generate_report(self):
        try:
            flag1 = self.flag1CheckBox.isChecked()
            flag2 = self.flag2CheckBox.isChecked()
            flag3 = self.flag3CheckBox.isChecked()

            result = self.db.get_summary_report(flag1, flag2, flag3)

            if result:
                columns, rows = result

                from PyQt5.QtGui import QStandardItemModel, QStandardItem

                model = QStandardItemModel()
                model.setHorizontalHeaderLabels(columns)

                for row in rows:
                    items = [QStandardItem(str(item) if item is not None else "") for item in row]
                    model.appendRow(items)

                self.reportTableView.setModel(model)
                self.reportTableView.resizeColumnsToContents()

                self.statusbar.showMessage(f"Сгенерирован отчет на {len(rows)} строк")
            else:
                QMessageBox.information(self, "Информация", "Нет данных для отображения")

        except Exception as e:
            QMessageBox.warning(self, "Ошибка", f"Не удалось сгенерировать отчет: {str(e)}")

    def closeEvent(self, event):
        self.db.disconnect()
        event.accept()


if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    window = MedicalApp()
    window.show()
    sys.exit(app.exec_())