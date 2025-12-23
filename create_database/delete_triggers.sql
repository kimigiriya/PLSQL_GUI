--===================================
--|  Скрипт для удаления триггеров  |
--===================================

BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER TRG_medical_org_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER TRG_staff_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER TRG_patient_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER TRG_treatment_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER TRG_doctor_assignment_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

SELECT '’риггеры успешно удалены' AS Massege FROM DUAL;