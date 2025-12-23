--===================================
--|  Триггеры для логирования       |
--===================================

BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER medical_org_audit_trg';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER staff_audit_trg';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER patient_audit_trg';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Триггер для Мед. организации
CREATE OR REPLACE TRIGGER medical_org_audit_trg
    AFTER INSERT OR UPDATE OR DELETE ON medical_org
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_data CLOB;
    v_new_data CLOB;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_data := 'org_id=' || :NEW.org_id || 
                     ',name=' || :NEW.name || 
                     ',address=' || :NEW.address || 
                     ',type=' || :NEW.type;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_data := 'org_id=' || :OLD.org_id || 
                     ',name=' || :OLD.name || 
                     ',address=' || :OLD.address || 
                     ',type=' || :OLD.type;
        v_new_data := 'org_id=' || :NEW.org_id || 
                     ',name=' || :NEW.name || 
                     ',address=' || :NEW.address || 
                     ',type=' || :NEW.type;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_data := 'org_id=' || :OLD.org_id || 
                     ',name=' || :OLD.name || 
                     ',address=' || :OLD.address || 
                     ',type=' || :OLD.type;
    END IF;
    
    INSERT INTO audit_log (log_id, table_name, operation_type, old_data, new_data)
    VALUES (audit_log_seq.NEXTVAL, 'MEDICAL_ORG', v_operation, v_old_data, v_new_data);
END;
/

-- Триггер для Сотрудника
CREATE OR REPLACE TRIGGER staff_audit_trg
    AFTER INSERT OR UPDATE OR DELETE ON staff
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_data CLOB;
    v_new_data CLOB;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_data := 'staff_id=' || :NEW.staff_id || 
                     ',name=' || :NEW.name || 
                     ',role=' || :NEW.role || 
                     ',specialization=' || :NEW.specialization || 
                     ',phone=' || :NEW.phone;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_data := 'staff_id=' || :OLD.staff_id || 
                     ',name=' || :OLD.name || 
                     ',role=' || :OLD.role || 
                     ',specialization=' || :OLD.specialization || 
                     ',phone=' || :OLD.phone;
        v_new_data := 'staff_id=' || :NEW.staff_id || 
                     ',name=' || :NEW.name || 
                     ',role=' || :NEW.role || 
                     ',specialization=' || :NEW.specialization || 
                     ',phone=' || :NEW.phone;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_data := 'staff_id=' || :OLD.staff_id || 
                     ',name=' || :OLD.name || 
                     ',role=' || :OLD.role || 
                     ',specialization=' || :OLD.specialization || 
                     ',phone=' || :OLD.phone;
    END IF;
    
    INSERT INTO audit_log (log_id, table_name, operation_type, old_data, new_data)
    VALUES (audit_log_seq.NEXTVAL, 'STAFF', v_operation, v_old_data, v_new_data);
END;
/

-- Триггер для Пациента
CREATE OR REPLACE TRIGGER patient_audit_trg
    AFTER INSERT OR UPDATE OR DELETE ON patient
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_data CLOB;
    v_new_data CLOB;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_data := 'patient_id=' || :NEW.patient_id || 
                     ',name=' || :NEW.name || 
                     ',birth_date=' || TO_CHAR(:NEW.birth_date, 'YYYY-MM-DD') || 
                     ',insurance=' || :NEW.insurance || 
                     ',clinic_id=' || TO_CHAR(NVL(:NEW.clinic_id, 0));
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_data := 'patient_id=' || :OLD.patient_id || 
                     ',name=' || :OLD.name || 
                     ',birth_date=' || TO_CHAR(:OLD.birth_date, 'YYYY-MM-DD') || 
                     ',insurance=' || :OLD.insurance || 
                     ',clinic_id=' || TO_CHAR(NVL(:OLD.clinic_id, 0));
        v_new_data := 'patient_id=' || :NEW.patient_id || 
                     ',name=' || :NEW.name || 
                     ',birth_date=' || TO_CHAR(:NEW.birth_date, 'YYYY-MM-DD') || 
                     ',insurance=' || :NEW.insurance || 
                     ',clinic_id=' || TO_CHAR(NVL(:NEW.clinic_id, 0));
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_data := 'patient_id=' || :OLD.patient_id || 
                     ',name=' || :OLD.name || 
                     ',birth_date=' || TO_CHAR(:OLD.birth_date, 'YYYY-MM-DD') || 
                     ',insurance=' || :OLD.insurance || 
                     ',clinic_id=' || TO_CHAR(NVL(:OLD.clinic_id, 0));
    END IF;
    
    INSERT INTO audit_log (log_id, table_name, operation_type, old_data, new_data)
    VALUES (audit_log_seq.NEXTVAL, 'PATIENT', v_operation, v_old_data, v_new_data);
END;
/