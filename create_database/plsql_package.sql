--===================================
--|  Пакет для управления данными   |
--===================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE audit_log CASCADE CONSTRAINTS';
EXCEPTION 
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE audit_log_seq';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE medical_pkg';
EXCEPTION 
    WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE audit_log (
    log_id NUMBER PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    operation_date TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    old_data CLOB,
    new_data CLOB,
    user_name VARCHAR2(100) DEFAULT USER
);

CREATE SEQUENCE audit_log_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PACKAGE medical_pkg AS
    PROCEDURE insert_medical_org(
        p_org_id NUMBER,
        p_name VARCHAR2,
        p_address VARCHAR2,
        p_type VARCHAR2
    );
    
    PROCEDURE update_medical_org(
        p_org_id NUMBER,
        p_name VARCHAR2 DEFAULT NULL,
        p_address VARCHAR2 DEFAULT NULL,
        p_type VARCHAR2 DEFAULT NULL
    );
    
    PROCEDURE delete_medical_org(p_org_id NUMBER);
    
    PROCEDURE insert_staff(
        p_staff_id NUMBER,
        p_name VARCHAR2,
        p_role VARCHAR2,
        p_specialization VARCHAR2 DEFAULT NULL,
        p_phone VARCHAR2 DEFAULT NULL
    );
    
    PROCEDURE update_staff(
        p_staff_id NUMBER,
        p_name VARCHAR2 DEFAULT NULL,
        p_role VARCHAR2 DEFAULT NULL,
        p_specialization VARCHAR2 DEFAULT NULL,
        p_phone VARCHAR2 DEFAULT NULL
    );
    
    PROCEDURE delete_staff(p_staff_id NUMBER);
    
    PROCEDURE insert_patient(
        p_patient_id NUMBER,
        p_name VARCHAR2,
        p_birth_date VARCHAR2,
        p_insurance VARCHAR2,
        p_clinic_id NUMBER DEFAULT NULL
    );
    
    PROCEDURE update_patient(
        p_patient_id NUMBER,
        p_name VARCHAR2 DEFAULT NULL,
        p_birth_date VARCHAR2 DEFAULT NULL,
        p_insurance VARCHAR2 DEFAULT NULL,
        p_clinic_id NUMBER DEFAULT NULL
    );
    
    PROCEDURE delete_patient(p_patient_id NUMBER);
    
    PROCEDURE get_audit_log(
        p_cursor OUT SYS_REFCURSOR,
        p_start_date VARCHAR2 DEFAULT NULL,
        p_end_date VARCHAR2 DEFAULT NULL,
        p_operation_type VARCHAR2 DEFAULT NULL
    );
    
    PROCEDURE undo_operation(p_log_id NUMBER);
    
    PROCEDURE get_summary_report(
        p_cursor OUT SYS_REFCURSOR,
        p_flag1 VARCHAR2 DEFAULT 'FALSE',
        p_flag2 VARCHAR2 DEFAULT 'FALSE',
        p_flag3 VARCHAR2 DEFAULT 'FALSE'
    );
END medical_pkg;
/

CREATE OR REPLACE PACKAGE BODY medical_pkg AS
    PROCEDURE insert_medical_org(
        p_org_id NUMBER,
        p_name VARCHAR2,
        p_address VARCHAR2,
        p_type VARCHAR2
    ) IS
    BEGIN
        INSERT INTO medical_org (org_id, name, address, type)
        VALUES (p_org_id, p_name, p_address, p_type);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END insert_medical_org;
    
    PROCEDURE update_medical_org(
        p_org_id NUMBER,
        p_name VARCHAR2 DEFAULT NULL,
        p_address VARCHAR2 DEFAULT NULL,
        p_type VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        UPDATE medical_org 
        SET name = COALESCE(p_name, name),
            address = COALESCE(p_address, address),
            type = COALESCE(p_type, type)
        WHERE org_id = p_org_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_medical_org;
    
    PROCEDURE delete_medical_org(p_org_id NUMBER) IS
    BEGIN
        DELETE FROM medical_org WHERE org_id = p_org_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_medical_org;

    PROCEDURE insert_staff(
        p_staff_id NUMBER,
        p_name VARCHAR2,
        p_role VARCHAR2,
        p_specialization VARCHAR2 DEFAULT NULL,
        p_phone VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        INSERT INTO staff (staff_id, name, role, specialization, phone)
        VALUES (p_staff_id, p_name, p_role, p_specialization, p_phone);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END insert_staff;
    
    PROCEDURE update_staff(
        p_staff_id NUMBER,
        p_name VARCHAR2 DEFAULT NULL,
        p_role VARCHAR2 DEFAULT NULL,
        p_specialization VARCHAR2 DEFAULT NULL,
        p_phone VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        UPDATE staff 
        SET name = COALESCE(p_name, name),
            role = COALESCE(p_role, role),
            specialization = COALESCE(p_specialization, specialization),
            phone = COALESCE(p_phone, phone)
        WHERE staff_id = p_staff_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_staff;
         
    PROCEDURE delete_staff(p_staff_id NUMBER) IS
    BEGIN
        DELETE FROM staff WHERE staff_id = p_staff_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_staff;
    
    PROCEDURE insert_patient(
        p_patient_id NUMBER,
        p_name VARCHAR2,
        p_birth_date VARCHAR2,
        p_insurance VARCHAR2,
        p_clinic_id NUMBER DEFAULT NULL
    ) IS
        v_date DATE;
    BEGIN
        IF p_birth_date IS NOT NULL THEN
            v_date := TO_DATE(p_birth_date, 'YYYY-MM-DD');
        END IF;
        
        INSERT INTO patient (patient_id, name, birth_date, insurance, clinic_id)
            VALUES (p_patient_id, p_name, v_date, p_insurance, p_clinic_id);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END insert_patient;
    
    PROCEDURE update_patient(
        p_patient_id NUMBER,
        p_name VARCHAR2 DEFAULT NULL,
        p_birth_date VARCHAR2 DEFAULT NULL,
        p_insurance VARCHAR2 DEFAULT NULL,
        p_clinic_id NUMBER DEFAULT NULL
    ) IS
        v_date DATE;
    BEGIN
        IF p_birth_date IS NOT NULL THEN
            v_date := TO_DATE(p_birth_date, 'YYYY-MM-DD');
        END IF;
        
        UPDATE patient 
        SET name = COALESCE(p_name, name),
            birth_date = CASE 
                         WHEN p_birth_date IS NOT NULL 
                         THEN v_date
                         ELSE birth_date 
                         END,
            insurance = COALESCE(p_insurance, insurance),
            clinic_id = COALESCE(p_clinic_id, clinic_id)
        WHERE patient_id = p_patient_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_patient;
    
    PROCEDURE delete_patient(p_patient_id NUMBER) IS
    BEGIN
        DELETE FROM patient WHERE patient_id = p_patient_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END delete_patient;
    
    PROCEDURE get_audit_log(
        p_cursor OUT SYS_REFCURSOR,
        p_start_date VARCHAR2 DEFAULT NULL,
        p_end_date VARCHAR2 DEFAULT NULL,
        p_operation_type VARCHAR2 DEFAULT NULL
    ) IS
        v_start_date DATE;
        v_end_date DATE;
    BEGIN
        IF p_start_date IS NOT NULL THEN
            v_start_date := TO_DATE(p_start_date, 'YYYY-MM-DD');
        END IF;
        
        IF p_end_date IS NOT NULL THEN
            v_end_date := TO_DATE(p_end_date, 'YYYY-MM-DD');
        END IF;
        
        OPEN p_cursor FOR
            SELECT log_id, table_name, operation_type, 
                   TO_CHAR(operation_date, 'YYYY-MM-DD HH24:MI:SS') as operation_date,
                   user_name
            FROM audit_log
            WHERE (p_start_date IS NULL OR TRUNC(operation_date) >= v_start_date)
                AND (p_end_date IS NULL OR TRUNC(operation_date) <= v_end_date)
                AND (p_operation_type IS NULL OR operation_type = p_operation_type)
            ORDER BY operation_date DESC;
    END get_audit_log;
    
    -- Вспомогательная функция для проверки формата даты
    FUNCTION is_date_format(p_value VARCHAR2) RETURN BOOLEAN IS
        v_date DATE;
    BEGIN
        IF p_value IS NULL OR p_value = 'NULL' THEN
            RETURN FALSE;
        END IF;
        
        BEGIN
            v_date := TO_DATE(p_value, 'YYYY-MM-DD');
            RETURN TRUE;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        BEGIN
            v_date := TO_DATE(p_value, 'YYYY-MM-DD HH24:MI:SS');
            RETURN TRUE;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        
        RETURN FALSE;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_date_format;
    
    -- Вспомогательная функция для нормализации даты
    FUNCTION normalize_date(p_value VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        IF p_value = 'NULL' THEN
            RETURN 'NULL';
        END IF;
        
        BEGIN
            RETURN TO_CHAR(TO_DATE(p_value, 'YYYY-MM-DD'), 'YYYY-MM-DD');
        EXCEPTION
            WHEN OTHERS THEN
                BEGIN
                    RETURN TO_CHAR(TO_DATE(p_value, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD');
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN p_value;
                END;
        END;
    END normalize_date;
    
    PROCEDURE undo_operation(p_log_id NUMBER) IS
        v_old_data CLOB;
        v_new_data CLOB;
        v_table_name VARCHAR2(50);
        v_operation_type VARCHAR2(10);
        
    BEGIN
        SELECT old_data, new_data, table_name, operation_type
        INTO v_old_data, v_new_data, v_table_name, v_operation_type
        FROM audit_log
        WHERE log_id = p_log_id;

        DECLARE
            CURSOR dependent_logs_cur IS
                SELECT log_id
                FROM audit_log 
                WHERE log_id > p_log_id
                  AND table_name = v_table_name
                ORDER BY log_id DESC;
        BEGIN
            FOR dep IN dependent_logs_cur LOOP
                DBMS_OUTPUT.PUT_LINE('Проверяем зависимый лог: ' || dep.log_id);
                
                DECLARE
                    v_dep_old CLOB;
                    v_dep_new CLOB;
                    v_dep_table VARCHAR2(50);
                    v_dep_type VARCHAR2(10);
                    v_match BOOLEAN := FALSE;
                BEGIN
                    SELECT old_data, new_data, table_name, operation_type
                    INTO v_dep_old, v_dep_new, v_dep_table, v_dep_type
                    FROM audit_log WHERE log_id = dep.log_id;
                    
                    IF INSTR(v_dep_old, SUBSTR(v_new_data,1,100)) > 0 OR 
                       INSTR(v_dep_new, SUBSTR(v_new_data,1,100)) > 0 OR
                       INSTR(v_dep_old, SUBSTR(v_old_data,1,100)) > 0 OR
                       INSTR(v_dep_new, SUBSTR(v_old_data,1,100)) > 0 THEN
                        v_match := TRUE;
                    END IF;
                    
                    IF v_match THEN
                        DBMS_OUTPUT.PUT_LINE('Отменяем зависимый лог: ' || dep.log_id);
                        undo_operation(dep.log_id);
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN NULL;
                END;
            END LOOP;
        END;

        IF v_operation_type = 'INSERT' THEN
            DECLARE
                v_sql VARCHAR2(4000);
                v_where_clause VARCHAR2(4000) := '';
                v_data VARCHAR2(4000) := v_new_data;
                v_pos1 NUMBER;
                v_pos2 NUMBER;
                v_field VARCHAR2(100);
                v_value VARCHAR2(1000);
                v_norm_value VARCHAR2(1000);
                v_first BOOLEAN := TRUE;
            BEGIN
                WHILE LENGTH(v_data) > 0 LOOP
                    v_pos1 := INSTR(v_data, '=');
                    v_pos2 := INSTR(v_data, ',');
                    
                    IF v_pos2 = 0 THEN
                        v_pos2 := LENGTH(v_data) + 1;
                    END IF;
                    
                    v_field := SUBSTR(v_data, 1, v_pos1 - 1);
                    v_value := SUBSTR(v_data, v_pos1 + 1, v_pos2 - v_pos1 - 1);
                    v_norm_value := normalize_date(v_value);
                    
                    IF NOT v_first THEN
                        v_where_clause := v_where_clause || ' AND ';
                    END IF;
                    
                    IF v_norm_value = 'NULL' THEN
                        v_where_clause := v_where_clause || v_field || ' IS NULL';
                    ELSIF is_date_format(v_norm_value) THEN
                        v_where_clause := v_where_clause || v_field || ' = TO_DATE(''' || v_norm_value || ''', ''YYYY-MM-DD'')';
                    ELSE
                        BEGIN
                            IF TO_NUMBER(v_norm_value) IS NOT NULL THEN
                                v_where_clause := v_where_clause || v_field || ' = ' || v_norm_value;
                            ELSE
                                v_where_clause := v_where_clause || v_field || ' = ''' || 
                                                REPLACE(v_norm_value, '''', '''''') || '''';
                            END IF;
                        EXCEPTION
                            WHEN VALUE_ERROR OR INVALID_NUMBER THEN
                                v_where_clause := v_where_clause || v_field || ' = ''' || 
                                                REPLACE(v_norm_value, '''', '''''') || '''';
                        END;
                    END IF;
                    
                    v_first := FALSE;
                    
                    IF v_pos2 <= LENGTH(v_data) THEN
                        v_data := SUBSTR(v_data, v_pos2 + 1);
                    ELSE
                        v_data := '';
                    END IF;
                END LOOP;
                
                v_sql := 'DELETE FROM ' || v_table_name || ' WHERE ' || v_where_clause;
                EXECUTE IMMEDIATE v_sql;
                
                DBMS_OUTPUT.PUT_LINE('Отменен INSERT: ' || v_sql);
            END;
            
        ELSIF v_operation_type = 'DELETE' THEN
            DECLARE
                v_sql VARCHAR2(4000);
                v_fields VARCHAR2(4000) := '';
                v_values VARCHAR2(4000) := '';
                v_data VARCHAR2(4000) := v_old_data;
                v_pos1 NUMBER;
                v_pos2 NUMBER;
                v_field VARCHAR2(100);
                v_value VARCHAR2(1000);
                v_norm_value VARCHAR2(1000);
                v_first BOOLEAN := TRUE;
            BEGIN
                WHILE LENGTH(v_data) > 0 LOOP
                    v_pos1 := INSTR(v_data, '=');
                    v_pos2 := INSTR(v_data, ',');
                    
                    IF v_pos2 = 0 THEN
                        v_pos2 := LENGTH(v_data) + 1;
                    END IF;
                    
                    v_field := SUBSTR(v_data, 1, v_pos1 - 1);
                    v_value := SUBSTR(v_data, v_pos1 + 1, v_pos2 - v_pos1 - 1);
                    v_norm_value := normalize_date(v_value);
                    
                    IF NOT v_first THEN
                        v_fields := v_fields || ', ';
                        v_values := v_values || ', ';
                    END IF;
                    
                    v_fields := v_fields || v_field;
                    
                    IF v_norm_value = 'NULL' THEN
                        v_values := v_values || 'NULL';
                    ELSIF is_date_format(v_norm_value) THEN
                        v_values := v_values || 'TO_DATE(''' || v_norm_value || ''', ''YYYY-MM-DD'')';
                    ELSE
                        BEGIN
                            IF TO_NUMBER(v_norm_value) IS NOT NULL THEN
                                v_values := v_values || v_norm_value;
                            ELSE
                                v_values := v_values || '''' || REPLACE(v_norm_value, '''', '''''') || '''';
                            END IF;
                        EXCEPTION
                            WHEN VALUE_ERROR OR INVALID_NUMBER THEN
                                v_values := v_values || '''' || REPLACE(v_norm_value, '''', '''''') || '''';
                        END;
                    END IF;
                    
                    v_first := FALSE;
                    
                    IF v_pos2 <= LENGTH(v_data) THEN
                        v_data := SUBSTR(v_data, v_pos2 + 1);
                    ELSE
                        v_data := '';
                    END IF;
                END LOOP;
                
                v_sql := 'INSERT INTO ' || v_table_name || ' (' || v_fields || ') VALUES (' || v_values || ')';
                EXECUTE IMMEDIATE v_sql;
                
                DBMS_OUTPUT.PUT_LINE('Отменен DELETE: ' || v_sql);
            END;
            
        ELSIF v_operation_type = 'UPDATE' THEN
            DECLARE
                v_sql VARCHAR2(4000);
                v_set_clause VARCHAR2(4000) := '';
                v_where_clause VARCHAR2(4000) := '';
                v_old_data_str VARCHAR2(4000) := v_old_data;
                v_new_data_str VARCHAR2(4000) := v_new_data;
                v_pos1 NUMBER;
                v_pos2 NUMBER;
                v_field VARCHAR2(100);
                v_value VARCHAR2(1000);
                v_norm_value VARCHAR2(1000);
                v_first_set BOOLEAN := TRUE;
                v_first_where BOOLEAN := TRUE;
            BEGIN
                WHILE LENGTH(v_old_data_str) > 0 LOOP
                    v_pos1 := INSTR(v_old_data_str, '=');
                    v_pos2 := INSTR(v_old_data_str, ',');
                    
                    IF v_pos2 = 0 THEN
                        v_pos2 := LENGTH(v_old_data_str) + 1;
                    END IF;
                    
                    v_field := SUBSTR(v_old_data_str, 1, v_pos1 - 1);
                    v_value := SUBSTR(v_old_data_str, v_pos1 + 1, v_pos2 - v_pos1 - 1);
                    v_norm_value := normalize_date(v_value);
                    
                    IF NOT v_first_set THEN
                        v_set_clause := v_set_clause || ', ';
                    END IF;
                    
                    IF v_norm_value = 'NULL' THEN
                        v_set_clause := v_set_clause || v_field || ' = NULL';
                    ELSIF is_date_format(v_norm_value) THEN
                        v_set_clause := v_set_clause || v_field || ' = TO_DATE(''' || v_norm_value || ''', ''YYYY-MM-DD'')';
                    ELSE
                        BEGIN
                            IF TO_NUMBER(v_norm_value) IS NOT NULL THEN
                                v_set_clause := v_set_clause || v_field || ' = ' || v_norm_value;
                            ELSE
                                v_set_clause := v_set_clause || v_field || ' = ''' || 
                                              REPLACE(v_norm_value, '''', '''''') || '''';
                            END IF;
                        EXCEPTION
                            WHEN VALUE_ERROR OR INVALID_NUMBER THEN
                                v_set_clause := v_set_clause || v_field || ' = ''' || 
                                              REPLACE(v_norm_value, '''', '''''') || '''';
                        END;
                    END IF;
                    
                    v_first_set := FALSE;
                    
                    IF v_pos2 <= LENGTH(v_old_data_str) THEN
                        v_old_data_str := SUBSTR(v_old_data_str, v_pos2 + 1);
                    ELSE
                        v_old_data_str := '';
                    END IF;
                END LOOP;
                
                WHILE LENGTH(v_new_data_str) > 0 LOOP
                    v_pos1 := INSTR(v_new_data_str, '=');
                    v_pos2 := INSTR(v_new_data_str, ',');
                    
                    IF v_pos2 = 0 THEN
                        v_pos2 := LENGTH(v_new_data_str) + 1;
                    END IF;
                    
                    v_field := SUBSTR(v_new_data_str, 1, v_pos1 - 1);
                    v_value := SUBSTR(v_new_data_str, v_pos1 + 1, v_pos2 - v_pos1 - 1);
                    v_norm_value := normalize_date(v_value);
                    
                    IF NOT v_first_where THEN
                        v_where_clause := v_where_clause || ' AND ';
                    END IF;
                    
                    IF v_norm_value = 'NULL' THEN
                        v_where_clause := v_where_clause || v_field || ' IS NULL';
                    ELSIF is_date_format(v_norm_value) THEN
                        v_where_clause := v_where_clause || v_field || ' = TO_DATE(''' || v_norm_value || ''', ''YYYY-MM-DD'')';
                    ELSE
                        BEGIN
                            IF TO_NUMBER(v_norm_value) IS NOT NULL THEN
                                v_where_clause := v_where_clause || v_field || ' = ' || v_norm_value;
                            ELSE
                                v_where_clause := v_where_clause || v_field || ' = ''' || 
                                                REPLACE(v_norm_value, '''', '''''') || '''';
                            END IF;
                        EXCEPTION
                            WHEN VALUE_ERROR OR INVALID_NUMBER THEN
                                v_where_clause := v_where_clause || v_field || ' = ''' || 
                                                REPLACE(v_norm_value, '''', '''''') || '''';
                        END;
                    END IF;
                    
                    v_first_where := FALSE;
                    
                    IF v_pos2 <= LENGTH(v_new_data_str) THEN
                        v_new_data_str := SUBSTR(v_new_data_str, v_pos2 + 1);
                    ELSE
                        v_new_data_str := '';
                    END IF;
                END LOOP;
                
                v_sql := 'UPDATE ' || v_table_name || ' SET ' || v_set_clause || 
                        ' WHERE ' || v_where_clause;
                EXECUTE IMMEDIATE v_sql;
                
                DBMS_OUTPUT.PUT_LINE('Отменен UPDATE: ' || v_sql);
            END;
        END IF;
        
        DELETE FROM audit_log WHERE log_id = p_log_id;
        
        COMMIT;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Запись лога с ID ' || p_log_id || ' не найдена');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Не удалось отменить операцию: ' || SQLERRM);
    END undo_operation;

    PROCEDURE get_summary_report(
        p_cursor OUT SYS_REFCURSOR,
        p_flag1 VARCHAR2 DEFAULT 'FALSE',
        p_flag2 VARCHAR2 DEFAULT 'FALSE',
        p_flag3 VARCHAR2 DEFAULT 'FALSE'
    ) IS
        v_order_by VARCHAR2(500) := '';
        v_sql VARCHAR2(1000);
    BEGIN
        v_sql := 'SELECT table_name, operation_type, COUNT(*) as operation_count
                  FROM audit_log
                  GROUP BY table_name, operation_type';
        
        IF p_flag1 = 'TRUE' THEN
            v_order_by := ' ORDER BY table_name';
            IF p_flag2 = 'TRUE' THEN
                v_order_by := v_order_by || ', operation_type';
                IF p_flag3 = 'TRUE' THEN
                    v_order_by := v_order_by || ', COUNT(*)';
                END IF;
            ELSIF p_flag3 = 'TRUE' THEN
                v_order_by := v_order_by || ', COUNT(*)';
            END IF;
        ELSIF p_flag2 = 'TRUE' THEN
            v_order_by := ' ORDER BY operation_type';
            IF p_flag3 = 'TRUE' THEN
                v_order_by := v_order_by || ', COUNT(*)';
            END IF;
        ELSIF p_flag3 = 'TRUE' THEN
            v_order_by := ' ORDER BY COUNT(*)';
        END IF;
        
        IF LENGTH(v_order_by) > 0 THEN
            v_sql := v_sql || v_order_by;
        END IF;
        
        OPEN p_cursor FOR v_sql;
    END get_summary_report;
    
END medical_pkg;
/