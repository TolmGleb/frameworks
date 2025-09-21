-- Создание базы данных
CREATE DATABASE construction_defect_control WITH ENCODING = 'UTF8';

\c construction_defect_control;

-- Справочник ролей пользователей
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Основная таблица пользователей
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    patronymic VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Связь пользователей с ролями (Many-to-Many)
CREATE TABLE user_roles (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Таблица проектов (строительных объектов)
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT,
    start_date DATE,
    planned_end_date DATE,
    actual_end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INTEGER NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица этапов проекта
CREATE TABLE project_stages (
    id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sequence_number INTEGER NOT NULL,
    start_date DATE,
    planned_end_date DATE,
    actual_end_date DATE,
    is_completed BOOLEAN DEFAULT FALSE,
    UNIQUE(project_id, sequence_number)
);

-- Справочник статусов дефекта
CREATE TABLE defect_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    code VARCHAR(20) NOT NULL UNIQUE,
    is_initial BOOLEAN DEFAULT FALSE,
    allows_closure BOOLEAN DEFAULT FALSE
);

-- Справочник приоритетов дефекта
CREATE TABLE defect_priorities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    code VARCHAR(20) NOT NULL UNIQUE,
    severity INTEGER NOT NULL UNIQUE
);

-- Основная таблица дефектов
CREATE TABLE defects (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    project_stage_id INTEGER REFERENCES project_stages(id) ON DELETE SET NULL,
    status_id INTEGER NOT NULL REFERENCES defect_statuses(id),
    priority_id INTEGER NOT NULL REFERENCES defect_priorities(id),
    author_id INTEGER NOT NULL REFERENCES users(id),
    assignee_id INTEGER REFERENCES users(id),
    planned_completion_date TIMESTAMP WITH TIME ZONE,
    actual_completion_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица для хранения комментариев к дефектам
CREATE TABLE defect_comments (
    id SERIAL PRIMARY KEY,
    defect_id INTEGER NOT NULL REFERENCES defects(id) ON DELETE CASCADE,
    author_id INTEGER NOT NULL REFERENCES users(id),
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица для хранения истории изменений дефектов (аудит)
CREATE TABLE defect_history (
    id SERIAL PRIMARY KEY,
    defect_id INTEGER NOT NULL REFERENCES defects(id) ON DELETE CASCADE,
    changed_by INTEGER NOT NULL REFERENCES users(id),
    changed_field VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    change_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Таблица для хранения вложений (фото, документы)
CREATE TABLE attachments (
    id SERIAL PRIMARY KEY,
    defect_id INTEGER NOT NULL REFERENCES defects(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size INTEGER,
    mime_type VARCHAR(100),
    uploaded_by INTEGER NOT NULL REFERENCES users(id),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для ускорения часто используемых запросов
CREATE INDEX idx_defects_project_id ON defects(project_id);
CREATE INDEX idx_defects_status_id ON defects(status_id);
CREATE INDEX idx_defects_assignee_id ON defects(assignee_id);
CREATE INDEX idx_defects_created_at ON defects(created_at);
CREATE INDEX idx_defects_planned_completion_date ON defects(planned_completion_date);

CREATE INDEX idx_defect_comments_defect_id ON defect_comments(defect_id);
CREATE INDEX idx_defect_history_defect_id ON defect_history(defect_id);
CREATE INDEX idx_attachments_defect_id ON attachments(defect_id);

-- Триггерная функция для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Создание триггеров для автоматического обновления поля updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_defects_updated_at BEFORE UPDATE ON defects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_defect_comments_updated_at BEFORE UPDATE ON defect_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Заполнение справочных данных
INSERT INTO roles (name, description) VALUES
('инженер', 'Регистрация дефектов, обновление информации, работа над задачами'),
('менеджер', 'Назначение задач, контроль сроков, формирование отчётов'),
('наблюдатель', 'Просмотр прогресса и отчётности без возможности редактирования');

INSERT INTO defect_statuses (name, code, is_initial, allows_closure) VALUES
('Новая', 'new', TRUE, FALSE),
('В работе', 'in_progress', FALSE, FALSE),
('На проверке', 'on_review', FALSE, FALSE),
('Закрыта', 'closed', FALSE, TRUE),
('Отменена', 'cancelled', FALSE, TRUE);

INSERT INTO defect_priorities (name, code, severity) VALUES
('Низкий', 'low', 1),
('Средний', 'medium', 2),
('Высокий', 'high', 3),
('Критический', 'critical', 4);


INSERT INTO users (username, email, password_hash, first_name, last_name, patronymic) VALUES
('admin', 'admin@systemakontrola.ru', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Алексей', 'Администраторов', 'Иванович'),
('manager1', 'manager1@systemakontrola.ru', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Петр', 'Менеджеров', 'Сергеевич'),
('manager2', 'manager2@systemakontrola.ru', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Ольга', 'Управляева', 'Петровна'),
('engineer1', 'engineer1@systemakontrola.ru', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Иван', 'Инженеров', 'Александрович'),
('engineer2', 'engineer2@systemakontrola.ru', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Мария', 'Техничева', 'Владимировна'),
('observer1', 'observer1@systemakontrola.ru', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Сергей', 'Наблюдателев', 'Дмитриевич');

-- Назначение ролей пользователям
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1), (1, 2), -- admin - инженер и менеджер
(2, 2), -- manager1 - менеджер
(3, 2), -- manager2 - менеджер
(4, 1), -- engineer1 - инженер
(5, 1), -- engineer2 - инженер
(6, 3); -- observer1 - наблюдатель

-- Создание тестовых проектов
INSERT INTO projects (name, description, address, start_date, planned_end_date, created_by) VALUES
('ЖК "Северный Ветер"', 'Многоэтажный жилой комплекс с подземной парковкой', 'ул. Строителей, 15', '2024-01-15', '2024-12-20', 2),
('Бизнес-центр "Ясень"', 'Офисное здание класса А с конференц-залами', 'пр. Мира, 28', '2024-02-01', '2024-11-30', 2),
('Школа №45', 'Трехэтажное здание школы на 800 учащихся', 'ул. Образования, 12', '2024-03-10', '2025-08-15', 3);

-- Создание этапов для проектов
INSERT INTO project_stages (project_id, name, description, sequence_number, start_date, planned_end_date) VALUES
-- Этапы для ЖК "Северный Ветер"
(1, 'Подготовка площадки', 'Расчистка территории, планировка', 1, '2024-01-15', '2024-02-28'),
(1, 'Фундаментные работы', 'Земляные работы, заливка фундамента', 2, '2024-03-01', '2024-04-15'),
(1, 'Возведение каркаса', 'Монтаж несущих конструкций', 3, '2024-04-16', '2024-06-30'),
(1, 'Кровельные работы', 'Устройство кровли', 4, '2024-07-01', '2024-08-15'),
(1, 'Отделочные работы', 'Внутренняя и внешняя отделка', 5, '2024-08-16', '2024-11-30'),
(1, 'Благоустройство', 'Обустройство территории', 6, '2024-12-01', '2024-12-20'),

-- Этапы для Бизнес-центра "Ясень"
(2, 'Геодезические работы', 'Разметка территории', 1, '2024-02-01', '2024-02-15'),
(2, 'Земляные работы', 'Котлован, дренаж', 2, '2024-02-16', '2024-03-15'),
(2, 'Фундамент', 'Устройство монолитного фундамента', 3, '2024-03-16', '2024-04-30'),
(2, 'Каркас здания', 'Монтаж металлоконструкций', 4, '2024-05-01', '2024-06-30'),
(2, 'Ограждающие конструкции', 'Стены, перекрытия', 5, '2024-07-01', '2024-08-31'),
(2, 'Инженерные системы', 'Электрика, сантехника, вентиляция', 6, '2024-09-01', '2024-10-15'),
(2, 'Отделка', 'Внутренняя отделка помещений', 7, '2024-10-16', '2024-11-30'),

-- Этапы для Школы №45
(3, 'Подготовительный этап', 'Ограждение площадки, подвод коммуникаций', 1, '2024-03-10', '2024-04-10'),
(3, 'Фундамент', 'Земляные работы и заливка фундамента', 2, '2024-04-11', '2024-05-31'),
(3, 'Стены и перекрытия', 'Кладка стен, монтаж перекрытий', 3, '2024-06-01', '2024-08-15'),
(3, 'Кровля', 'Устройство кровельной системы', 4, '2024-08-16', '2024-09-30'),
(3, 'Фасадные работы', 'Отделка фасада', 5, '2024-10-01', '2024-11-30'),
(3, 'Внутренняя отделка', 'Отделка помещений', 6, '2024-12-01', '2025-04-30'),
(3, 'Благоустройство', 'Обустройство территории школы', 7, '2025-05-01', '2025-08-15');

-- Создание тестовых дефектов
INSERT INTO defects (title, description, project_id, project_stage_id, status_id, priority_id, author_id, assignee_id, planned_completion_date) VALUES
-- Дефекты для ЖК "Северный Ветер"
('Трещина в фундаменте', 'Обнаружена трещина шириной 2 мм в северо-западном углу фундамента. Требуется экспертиза и усиление конструкции.', 1, 2, 1, 4, 2, 4, '2024-04-10'),
('Неровная кладка стен', 'Отклонение от вертикали в кирпичной кладке 3 этажа составляет 15 мм при допустимых 10 мм.', 1, 3, 2, 3, 3, 4, '2024-05-15'),
('Протечка кровли', 'После дождя обнаружены протечки в районе мансардных окон. Необходима проверка гидроизоляции.', 1, 4, 1, 3, 2, 5, '2024-08-20'),
('Некачественная штукатурка', 'На стенах в подъезде №2 наблюдается отслоение штукатурки. Требуется переделка.', 1, 5, 3, 2, 3, 5, '2024-10-10'),

-- Дефекты для Бизнес-центра "Ясень"
('Несоответствие проекту электропроводки', 'В офисных помещениях 2 этажа разводка электропроводки не соответствует утвержденному проекту.', 2, 6, 1, 4, 2, 4, '2024-10-20'),
('Занижение потолков', 'Фактическая высота потолков на 3 этаже составляет 2.65 м вместо проектных 2.85 м.', 2, 5, 2, 3, 3, 4, '2024-09-15'),
('Негерметичные оконные блоки', 'В зимний период обнаружены сквозняки из-под оконных блоков на северном фасаде.', 2, 7, 4, 2, 2, 5, '2024-11-30'),
('Повреждение лифтовых шахт', 'При монтаже лифтового оборудования повреждены отделочные панели шахт.', 2, 7, 1, 3, 3, 5, '2024-11-10'),

-- Дефекты для Школы №45
('Неправильный уклон кровли', 'Уклон кровли спортивного зала не соответствует проекту,可能导致 застоя воды.', 3, 4, 1, 3, 2, 4, '2024-10-05'),
('Трещины в несущих колоннах', 'В колоннах актового зала обнаружены волосяные трещины. Требуется обследование.', 3, 3, 2, 4, 3, 4, '2024-07-20'),
('Некачественная покраска фасада', 'Наблюдается неравномерное окрашивание фасадных панелей, видны потеки.', 3, 5, 3, 2, 2, 5, '2024-12-15'),
('Несоответствие сантехнических работ', 'Разводка сантехнических коммуникаций в столовой не соответствует проектной документации.', 3, 6, 1, 3, 3, 5, '2025-03-31');

-- Добавление комментариев к дефектам
INSERT INTO defect_comments (defect_id, author_id, comment_text) VALUES
(1, 2, 'Вызван специалист для проведения экспертизы фундамента. Ожидаем заключение к 05.04.2024'),
(1, 4, 'Проведен визуальный осмотр. Трещина стабильна, расширения не наблюдается.'),
(2, 4, 'Начал выравнивание кладки. Установлены дополнительные маяки.'),
(3, 2, 'Заказаны материалы для ремонта гидроизоляции. Поставка ожидается 15.08.2024'),
(4, 5, 'Подготовил поверхности к перештукатуриванию. Заказана новая партия смеси.'),

(5, 3, 'Требуется срочная встреча с subcontractor по электромонтажным работам.'),
(6, 4, 'Провели замеры во всех помещениях 3 этажа. Отклонения подтверждены.'),
(7, 5, 'Установлены новые уплотнители на все проблемные окна. Тестирование после дождя.'),
(8, 2, 'Составлен акт о повреждениях. Подрядчик обязан устранить за свой счет.'),

(9, 4, 'Вызван кровельщик для оценки ситуации и составления плана работ.'),
(10, 3, 'Заказано обследование конструкций специализированной организацией.'),
(11, 5, 'Закупаются материалы для перекрашивания фасада. Начало работ - 01.12.2024'),
(12, 4, 'Составлена схема несоответствий. Требуется согласование с проектировщиком.');

-- Добавление истории изменений дефектов
INSERT INTO defect_history (defect_id, changed_by, changed_field, old_value, new_value) VALUES
(1, 2, 'status_id', '1', '2'),
(1, 2, 'assignee_id', NULL, '4'),
(2, 3, 'priority_id', '2', '3'),
(3, 2, 'planned_completion_date', NULL, '2024-08-20'),
(4, 5, 'status_id', '2', '3'),

(5, 2, 'status_id', '1', '2'),
(6, 4, 'description', 'Занижение потолков', 'Фактическая высота потолков на 3 этаже составляет 2.65 м вместо проектных 2.85 м.'),
(7, 5, 'status_id', '2', '4'),
(8, 3, 'priority_id', '2', '3'),

(9, 2, 'assignee_id', NULL, '4'),
(10, 4, 'status_id', '1', '2'),
(11, 5, 'planned_completion_date', '2024-11-30', '2024-12-15'),
(12, 3, 'description', 'Несоответствие сантехнических работ', 'Разводка сантехнических коммуникаций в столовой не соответствует проектной документации.');


INSERT INTO attachments (defect_id, file_name, file_path, file_size, mime_type, uploaded_by) VALUES
(1, 'fundament_crack.jpg', '/attachments/defect_1/fundament_crack.jpg', 2457600, 'image/jpeg', 2),
(1, 'expert_report.pdf', '/attachments/defect_1/expert_report.pdf', 512000, 'application/pdf', 4),
(3, 'roof_leak.mp4', '/attachments/defect_3/roof_leak.mp4', 10485760, 'video/mp4', 2),
(5, 'wiring_diagram.png', '/attachments/defect_5/wiring_diagram.png', 1228800, 'image/png', 3),
(7, 'window_seal_test.pdf', '/attachments/defect_7/window_seal_test.pdf', 384000, 'application/pdf', 5),
(10, 'column_crack_photo.jpg', '/attachments/defect_10/column_crack_photo.jpg', 1843200, 'image/jpeg', 4);

-- Создание пользователя для приложения
CREATE USER app_user WITH PASSWORD 'app_password_123';
GRANT CONNECT ON DATABASE construction_defect_control TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Создание представлений для отчетности
CREATE VIEW defects_report AS
SELECT 
    d.id,
    d.title,
    p.name as project_name,
    ps.name as stage_name,
    ds.name as status_name,
    dp.name as priority_name,
    CONCAT(auth.first_name, ' ', auth.last_name) as author_name,
    CONCAT(assign.first_name, ' ', assign.last_name) as assignee_name,
    d.created_at,
    d.planned_completion_date,
    d.actual_completion_date
FROM defects d
LEFT JOIN projects p ON d.project_id = p.id
LEFT JOIN project_stages ps ON d.project_stage_id = ps.id
LEFT JOIN defect_statuses ds ON d.status_id = ds.id
LEFT JOIN defect_priorities dp ON d.priority_id = dp.id
LEFT JOIN users auth ON d.author_id = auth.id
LEFT JOIN users assign ON d.assignee_id = assign.id;

CREATE VIEW project_stats AS
SELECT 
    p.id as project_id,
    p.name as project_name,
    COUNT(d.id) as total_defects,
    COUNT(CASE WHEN ds.code = 'new' THEN 1 END) as new_defects,
    COUNT(CASE WHEN ds.code = 'in_progress' THEN 1 END) as in_progress_defects,
    COUNT(CASE WHEN ds.code = 'on_review' THEN 1 END) as on_review_defects,
    COUNT(CASE WHEN ds.code IN ('closed', 'cancelled') THEN 1 END) as closed_defects
FROM projects p
LEFT JOIN defects d ON p.id = d.project_id
LEFT JOIN defect_statuses ds ON d.status_id = ds.id
GROUP BY p.id, p.name;

-- Индекс для полнотекстового поиска
CREATE INDEX idx_defects_search ON defects USING gin(
    to_tsvector('russian', title || ' ' || description)
);

-- Функция для получения дефектов с фильтрацией
CREATE OR REPLACE FUNCTION get_filtered_defects(
    p_project_id INTEGER DEFAULT NULL,
    p_status_code VARCHAR DEFAULT NULL,
    p_priority_code VARCHAR DEFAULT NULL,
    p_assignee_id INTEGER DEFAULT NULL
)
RETURNS TABLE (
    defect_id INTEGER,
    title VARCHAR,
    project_name VARCHAR,
    status_name VARCHAR,
    priority_name VARCHAR,
    assignee_name VARCHAR,
    created_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id,
        d.title,
        p.name,
        ds.name,
        dp.name,
        CONCAT(u.first_name, ' ', u.last_name),
        d.created_at
    FROM defects d
    LEFT JOIN projects p ON d.project_id = p.id
    LEFT JOIN defect_statuses ds ON d.status_id = ds.id
    LEFT JOIN defect_priorities dp ON d.priority_id = dp.id
    LEFT JOIN users u ON d.assignee_id = u.id
    WHERE (p_project_id IS NULL OR d.project_id = p_project_id)
      AND (p_status_code IS NULL OR ds.code = p_status_code)
      AND (p_priority_code IS NULL OR dp.code = p_priority_code)
      AND (p_assignee_id IS NULL OR d.assignee_id = p_assignee_id)
    ORDER BY d.created_at DESC;
END;
$$ LANGUAGE plpgsql;
