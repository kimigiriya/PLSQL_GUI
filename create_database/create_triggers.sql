--===================================
--|  Скрипт для создания триггеров  |
--===================================

-- Триггер для medical_organization
CREATE OR REPLACE TRIGGER TRG_medical_org_id
BEFORE INSERT ON medical_org
FOR EACH ROW
BEGIN
  SELECT SEQ_medical_org_id.NEXTVAL INTO :NEW.org_id FROM DUAL;
END;
/

-- Триггер для staff
CREATE OR REPLACE TRIGGER TRG_staff_id
BEFORE INSERT ON staff
FOR EACH ROW
BEGIN
  SELECT SEQ_staff_id.NEXTVAL INTO :NEW.staff_id FROM DUAL;
END;
/

-- Триггер для patient
CREATE OR REPLACE TRIGGER TRG_patient_id
BEFORE INSERT ON patient
FOR EACH ROW
BEGIN
  SELECT SEQ_patient_id.NEXTVAL INTO :NEW.patient_id FROM DUAL;
END;
/

-- Триггер для treatment
CREATE OR REPLACE TRIGGER TRG_treatment_id
BEFORE INSERT ON treatment
FOR EACH ROW
BEGIN
  SELECT SEQ_treatment_id.NEXTVAL INTO :NEW.treatment_id FROM DUAL;
END;
/

-- Триггер для doctor_assignment
CREATE OR REPLACE TRIGGER TRG_doctor_assignment_id
BEFORE INSERT ON doctor_assignment
FOR EACH ROW
BEGIN
  SELECT SEQ_doctor_assignment_id.NEXTVAL INTO :NEW.assign_id FROM DUAL;
END;
/
