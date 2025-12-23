--====================================
--|  Скрипт для заполнения таблиц    |
--====================================

-- 1. Заполняем медицинские организации
INSERT INTO medical_org (name, address, type) VALUES 
('Городская больница №1', 'ул. Ленина, 25', 'hospital');
INSERT INTO medical_org (name, address, type) VALUES
('Поликлиника №34', 'ул. Пушкина, д. Колотушкина', 'clinic');

-- 2. Заполняем персонал
INSERT INTO staff (name, role, specialization, phone) VALUES 
('Андрей Евгеньевич Быков', 'doctor', 'терапевт', '+7 (495) 111-11-11');
INSERT INTO staff (name, role, specialization, phone) VALUES
('Иван Натанович Купитман', 'doctor', 'венеролог', '+7 (495) 222-22-22');
INSERT INTO staff (name, role, specialization, phone) VALUES
('Семён Семёнович Лобанов', 'nurse', 'терапевт', '+7 (495) 333-33-33');
INSERT INTO staff (name, role, specialization, phone) VALUES
('Борис Аркадьевич Левин', 'nurse', 'терапевт', '+7 (495) 444-44-44');
INSERT INTO staff (name, role, specialization, phone) VALUES
('Глеб Викторович Романенко', 'nurse', 'терапевт', '+7 (495) 555-55-55');
INSERT INTO staff (name, role, specialization, phone) VALUES
('Любовь Михайловна Скрябина', 'doctor', NULL, '+7 (495) 666-66-66');
INSERT INTO staff (name, role, specialization, phone) VALUES
('Фил Ричардс', 'nurse', NULL, '+1 945-111-2233');

-- 3. Заполняем пациентов
INSERT INTO patient (name, birth_date, insurance, clinic_id) VALUES 
('Максим Аверин', TO_DATE('15-03-1975', 'DD-MM-YYYY'), '1234567890', 2);
INSERT INTO patient (name, birth_date, insurance, clinic_id) VALUES
('Эдгард Запашный', TO_DATE('20-04-1980', 'DD-MM-YYYY'), '2345678901', 2);
INSERT INTO patient (name, birth_date, insurance, clinic_id) VALUES
('Александр Голубев', TO_DATE('25-05-1985', 'DD-MM-YYYY'), '3456789012', 2);
INSERT INTO patient (name, birth_date, insurance, clinic_id) VALUES
('Сергей Жуков', TO_DATE('30-06-1990', 'DD-MM-YYYY'), '4567890123', 2);
INSERT INTO patient (name, birth_date, insurance, clinic_id) VALUES
('Гарик Харламов', TO_DATE('05-07-1995', 'DD-MM-YYYY'), '5678901234', 2);

-- 4. Заполняем лечение пациентов
INSERT INTO treatment (patient_id, org_id, start_date, end_date, diagnosis) VALUES 
(1, 1, TO_DATE('01-01-2023', 'DD-MM-YYYY'), NULL, 'Грипп, средней степени тяжести');
INSERT INTO treatment (patient_id, org_id, start_date, end_date, diagnosis) VALUES
(2, 1, TO_DATE('05-01-2023', 'DD-MM-YYYY'), TO_DATE('15-01-2023', 'DD-MM-YYYY'), 'ОРВИ');
INSERT INTO treatment (patient_id, org_id, start_date, end_date, diagnosis) VALUES
(3, 1, TO_DATE('10-01-2023', 'DD-MM-YYYY'), NULL, 'Пневмония левого лёгкого');
INSERT INTO treatment (patient_id, org_id, start_date, end_date, diagnosis) VALUES
(4, 1, TO_DATE('15-01-2023', 'DD-MM-YYYY'), TO_DATE('25-01-2023', 'DD-MM-YYYY'), 'Бронхит');
INSERT INTO treatment (patient_id, org_id, start_date, end_date, diagnosis) VALUES
(5, 1, TO_DATE('20-01-2023', 'DD-MM-YYYY'), NULL, 'Гипертонический криз');

-- 5. Заполняем назначения врачей
INSERT INTO doctor_assignment (treatment_id, doctor_id, role) VALUES 
(1, 1, 'primary');
INSERT INTO doctor_assignment (treatment_id, doctor_id, role) VALUES
(1, 2, 'consultant');
INSERT INTO doctor_assignment (treatment_id, doctor_id, role) VALUES
(2, 3, 'primary');
INSERT INTO doctor_assignment (treatment_id, doctor_id, role) VALUES
(3, 4, 'primary');
INSERT INTO doctor_assignment (treatment_id, doctor_id, role) VALUES
(4, 5, 'primary');
INSERT INTO doctor_assignment (treatment_id, doctor_id, role) VALUES
(5, 1, 'primary');

SELECT 'Данные успешно добавлены' AS Message FROM DUAL;
