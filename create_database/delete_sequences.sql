--=============================================
--|  Скрипт для удаления последовательностей  |
--=============================================

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_medical_org_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_staff_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_patient_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_treatment_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_doctor_assignment_id';
EXCEPTION WHEN OTHERS THEN NULL; END;
/

SELECT 'Последовательности успешно удалены' AS Massege FROM DUAL;