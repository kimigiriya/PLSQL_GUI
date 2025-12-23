--=============================================
--|  Скрипт для создания последовательностей  |
--=============================================

-- Последовательность для medical_org
CREATE SEQUENCE SEQ_medical_org_id START WITH 1 INCREMENT BY 1;

-- Последовательность для staff
CREATE SEQUENCE SEQ_staff_id START WITH 1 INCREMENT BY 1;

-- Последовательность для patient
CREATE SEQUENCE SEQ_patient_id START WITH 1 INCREMENT BY 1;

-- Последовательность для treatment
CREATE SEQUENCE SEQ_treatment_id START WITH 1 INCREMENT BY 1;

-- Последовательность для doctor_assignment
CREATE SEQUENCE SEQ_doctor_assignment_id START WITH 1 INCREMENT BY 1;

SELECT 'Последовательности созданы успешно' AS Message FROM DUAL;