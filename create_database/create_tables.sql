--================================
--|  Скрипт для создания таблиц  |
--================================

-- 1. Организации
CREATE TABLE medical_org (
    org_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    address VARCHAR2(200) NOT NULL,
    type VARCHAR2(10) NOT NULL CHECK (type IN ('hospital', 'clinic'))
);

-- 2. Персонал
CREATE TABLE staff (
    staff_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    role VARCHAR2(10) NOT NULL CHECK (role IN ('doctor', 'nurse')),
    specialization VARCHAR2(50),
    phone VARCHAR2(20)
);

-- 3. Пациенты
CREATE TABLE patient (
    patient_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    birth_date DATE NOT NULL,
    insurance VARCHAR2(50) NOT NULL UNIQUE,
    clinic_id NUMBER,
    CONSTRAINT fk_clinic FOREIGN KEY (clinic_id) 
        REFERENCES medical_org(org_id) ON DELETE SET NULL
);

-- 4. Лечение
CREATE TABLE treatment (
    treatment_id NUMBER PRIMARY KEY,
    patient_id NUMBER NOT NULL,
    org_id NUMBER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    diagnosis VARCHAR2(500),
    CONSTRAINT fk_treat_patient FOREIGN KEY (patient_id) 
        REFERENCES patient(patient_id) ON DELETE CASCADE,
    CONSTRAINT fk_treat_org FOREIGN KEY (org_id) 
        REFERENCES medical_org(org_id) ON DELETE CASCADE
);

-- 5. Назначения врачей
CREATE TABLE doctor_assignment (
    assign_id NUMBER PRIMARY KEY,
    treatment_id NUMBER NOT NULL,
    doctor_id NUMBER NOT NULL,
    role VARCHAR2(10) NOT NULL CHECK (role IN ('primary', 'consultant')),
    CONSTRAINT fk_assign_treatment FOREIGN KEY (treatment_id) 
        REFERENCES treatment(treatment_id) ON DELETE CASCADE,
    CONSTRAINT fk_assign_doctor FOREIGN KEY (doctor_id) 
        REFERENCES staff(staff_id) ON DELETE CASCADE
);

SELECT 'Таблицы созданы успешно' AS Message FROM DUAL;