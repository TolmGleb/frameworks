-- Создание базы данных
CREATE DATABASE construction_defect_control;

\c construction_defect_control;

-- Основная таблица пользователей
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('инженер', 'менеджер', 'наблюдатель')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица проектов (строительных объектов)
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Основная таблица дефектов
CREATE TABLE defects (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    project_id INTEGER NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'Новая' CHECK (status IN ('Новая', 'В работе', 'На проверке', 'Закрыта', 'Отменена')),
    priority VARCHAR(50) NOT NULL DEFAULT 'Средний' CHECK (priority IN ('Низкий', 'Средний', 'Высокий', 'Критический')),
    author_id INTEGER NOT NULL REFERENCES users(id),
    assignee_id INTEGER REFERENCES users(id),
    planned_completion_date DATE,
    actual_completion_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица для хранения комментариев к дефектам
CREATE TABLE defect_comments (
    id SERIAL PRIMARY KEY,
    defect_id INTEGER NOT NULL REFERENCES defects(id) ON DELETE CASCADE,
    author_id INTEGER NOT NULL REFERENCES users(id),
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Заполнение тестовыми пользователями 
INSERT INTO users (username, password_hash, first_name, last_name, role) VALUES
('admin', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Алексей', 'Администраторов', 'менеджер'),
('manager1', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Петр', 'Менеджеров', 'менеджер'),
('engineer1', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Иван', 'Инженеров', 'инженер'),
('engineer2', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Мария', 'Техничева', 'инженер'),
('observer1', '$2b$10$r4A5s7d8f9g0h1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7z8a9b0c1d', 'Сергей', 'Наблюдателев', 'наблюдатель');

-- Создание тестовых проектов
INSERT INTO projects (name, description, address) VALUES
('ЖК "Северный Ветер"', 'Многоэтажный жилой комплекс с подземной парковкой', 'ул. Строителей, 15'),
('Бизнес-центр "Ясень"', 'Офисное здание класса А с конференц-залами', 'пр. Мира, 28'),
('Школа №45', 'Трехэтажное здание школы на 800 учащихся', 'ул. Образования, 12');

-- Создание тестовых дефектов
INSERT INTO defects (title, description, project_id, status, priority, author_id, assignee_id, planned_completion_date) VALUES
('Трещина в фундаменте', 'Обнаружена трещина шириной 2 мм в северо-западном углу фундамента', 1, 'Новая', 'Критический', 2, 3, '2024-04-10'),
('Неровная кладка стен', 'Отклонение от вертикали в кирпичной кладке 3 этажа', 1, 'В работе', 'Высокий', 2, 3, '2024-05-15'),
('Протечка кровли', 'После дождя обнаружены протечки в районе мансардных окон', 1, 'Новая', 'Высокий', 2, 4, '2024-08-20'),
('Некачественная штукатурка', 'На стенах в подъезде отслоение штукатурки', 1, 'На проверке', 'Средний', 2, 4, '2024-10-10'),

('Несоответствие электропроводки', 'Разводка электропроводки не соответствует проекту', 2, 'Новая', 'Критический', 2, 3, '2024-10-20'),
('Занижение потолков', 'Фактическая высота потолков ниже проектной', 2, 'В работе', 'Высокий', 2, 3, '2024-09-15'),
('Негерметичные оконные блоки', 'Обнаружены сквозняки из-под оконных блоков', 2, 'Закрыта', 'Средний', 2, 4, '2024-11-30'),

('Неправильный уклон кровли', 'Уклон кровли не соответствует проекту', 3, 'Новая', 'Высокий', 2, 3, '2024-10-05'),
('Трещины в несущих колоннах', 'В колоннах обнаружены волосяные трещины', 3, 'В работе', 'Критический', 2, 3, '2024-07-20');

-- Добавление комментариев к дефектам
INSERT INTO defect_comments (defect_id, author_id, comment_text) VALUES
(1, 2, 'Вызван специалист для проведения экспертизы фундамента'),
(1, 3, 'Проведен визуальный осмотр. Трещина стабильна'),
(2, 3, 'Начал выравнивание кладки. Установлены дополнительные маяки'),
(3, 2, 'Заказаны материалы для ремонта гидроизоляции'),
(4, 4, 'Подготовил поверхности к перештукатуриванию'),

(5, 2, 'Требуется встреча с subcontractor по электромонтажным работам'),
(6, 3, 'Провели замеры во всех помещениях. Отклонения подтверждены'),
(7, 4, 'Установлены новые уплотнители на все проблемные окна'),

(8, 2, 'Вызван кровельщик для оценки ситуации'),
(9, 3, 'Заказано обследование конструкций специализированной организацией');

-- Простые индексы для ускорения запросов
CREATE INDEX idx_defects_project_id ON defects(project_id);
CREATE INDEX idx_defects_status ON defects(status);
CREATE INDEX idx_defects_assignee_id ON defects(assignee_id);
CREATE INDEX idx_defects_created_at ON defects(created_at);

CREATE INDEX idx_defect_comments_defect_id ON defect_comments(defect_id);

-- Функция для обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для автоматического обновления updated_at
--CREATE TRIGGER update_defects_updated_at 
--BEFORE UPDATE ON defects 
--FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Сообщение об успешном завершении
SELECT 'Упрощенная база данных успешно создана!' as message;
SELECT 'Тестовые пользователи:' as info;
SELECT username, first_name || ' ' || last_name as full_name, role FROM users;
SELECT 'Тестовые проекты:' as info;
SELECT name, address FROM projects;
SELECT 'Всего дефектов: ' || COUNT(*) as defects_count FROM defects;