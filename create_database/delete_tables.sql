--================================
--|  Скрипт для удаления таблиц  |
--================================

BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE medical_org CASCADE CONSTRAINTS';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE staff CASCADE CONSTRAINTS';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE patient CASCADE CONSTRAINTS';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE treatment CASCADE CONSTRAINTS';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END;
    
    BEGIN
        EXECUTE IMMEDIATE 'DROP TABLE doctor_assignment CASCADE CONSTRAINTS';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END;
END;
/

SELECT 'Таблицы успешно удалены' AS Massege FROM DUAL;