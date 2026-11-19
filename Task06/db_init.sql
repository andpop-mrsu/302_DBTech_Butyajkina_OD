PRAGMA foreign_keys = ON;

-- Удаляем старые таблицы
DROP TABLE IF EXISTS movie_genres;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS occupations;

-- Справочник профессий (3НФ)
CREATE TABLE occupations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

-- Пользователи
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    -- Ограничение: не может быть двух пользователей с одинаковым e-mail
    email TEXT NOT NULL UNIQUE, 
    name TEXT NOT NULL, -- ФИО одной строкой (как было в исходной базе)
    -- Ограничение: пол только 'M' или 'F'
    gender TEXT CHECK (gender IN ('M', 'F')) NOT NULL, 
    register_date TEXT DEFAULT CURRENT_TIMESTAMP,
    occupation_id INTEGER,
    FOREIGN KEY (occupation_id) REFERENCES occupations(id) ON DELETE SET NULL
);

-- Фильмы
CREATE TABLE movies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    year INTEGER CHECK (year >= 1888)
);

-- Жанры (справочник)
CREATE TABLE genres (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

-- Связующая таблица фильмы-жанры (многие-ко-многим)
CREATE TABLE movie_genres (
    movie_id INTEGER,
    genre_id INTEGER,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
);

-- Оценки (отзывы)
CREATE TABLE ratings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    -- Ограничение: рейтинг от 0 до 5
    rating REAL CHECK (rating >= 0 AND rating <= 5) NOT NULL, 
    timestamp INTEGER NOT NULL,
    -- Нельзя удалить фильм, если по нему есть отзывы
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE RESTRICT, 
    -- При удалении пользователя автоматически удаляются все его отзывы
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE 
);

-- Теги
CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    tag TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Индексы для ускорения запросов
CREATE INDEX idx_users_name ON users(name); -- Поиск по фамилии (т.к. ФИО одной строкой)
CREATE INDEX idx_movies_title ON movies(title);
CREATE INDEX idx_movies_year ON movies(year);

-- ==========================================
-- ЗАПОЛНЕНИЕ ДАННЫМИ (из исходной базы)
-- ==========================================

-- Профессии (примерные, так как в исходной базе occupation — просто текст)
INSERT INTO occupations (name) VALUES 
('student'), ('engineer'), ('teacher'), ('other');

-- Пользователи (берем первых 5 для примера)
INSERT INTO users (email, name, gender, occupation_id) VALUES 
('ivanov@example.com', 'Ivanov Ivan', 'M', 1),
('smirnova@example.com', 'Smirnova Maria', 'F', 2),
('petrov@example.com', 'Petrov Alex', 'M', 1),
('sidorova@example.com', 'Sidorova Elena', 'F', 3),
('kuznetsov@example.com', 'Kuznetsov Petr', 'M', 4);

-- Фильмы (берем первые 10 для примера)
INSERT INTO movies (title, year) VALUES 
('Toy Story', 1995),
('Jumanji', 1995),
('Grumpier Old Men', 1995),
('Waiting to Exhale', 1995),
('Father of the Bride Part II', 1995),
('Heat', 1995),
('Sabrina', 1995),
('Tom and Huck', 1995),
('Sudden Death', 1995),
('GoldenEye', 1995);

-- Жанры (уникальные из первых 10 фильмов)
INSERT INTO genres (name) VALUES 
('Adventure'), ('Animation'), ('Children'), ('Comedy'), ('Fantasy'), 
('Romance'), ('Drama'), ('Action'), ('Crime'), ('Thriller');

-- Связываем фильмы и жанры (используем подзапросы по названиям)
INSERT INTO movie_genres (movie_id, genre_id) VALUES 
((SELECT id FROM movies WHERE title = 'Toy Story'), (SELECT id FROM genres WHERE name = 'Adventure')),
((SELECT id FROM movies WHERE title = 'Toy Story'), (SELECT id FROM genres WHERE name = 'Animation')),
((SELECT id FROM movies WHERE title = 'Toy Story'), (SELECT id FROM genres WHERE name = 'Children')),
((SELECT id FROM movies WHERE title = 'Toy Story'), (SELECT id FROM genres WHERE name = 'Comedy')),
((SELECT id FROM movies WHERE title = 'Toy Story'), (SELECT id FROM genres WHERE name = 'Fantasy')),
((SELECT id FROM movies WHERE title = 'Jumanji'), (SELECT id FROM genres WHERE name = 'Adventure')),
((SELECT id FROM movies WHERE title = 'Jumanji'), (SELECT id FROM genres WHERE name = 'Children')),
((SELECT id FROM movies WHERE title = 'Jumanji'), (SELECT id FROM genres WHERE name = 'Fantasy')),
((SELECT id FROM movies WHERE title = 'Heat'), (SELECT id FROM genres WHERE name = 'Action')),
((SELECT id FROM movies WHERE title = 'Heat'), (SELECT id FROM genres WHERE name = 'Crime')),
((SELECT id FROM movies WHERE title = 'Heat'), (SELECT id FROM genres WHERE name = 'Thriller'));

-- Оценки (примерные)
INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES 
((SELECT id FROM users WHERE name = 'Ivanov Ivan'), (SELECT id FROM movies WHERE title = 'Toy Story'), 5.0, 1600000000),
((SELECT id FROM users WHERE name = 'Smirnova Maria'), (SELECT id FROM movies WHERE title = 'Jumanji'), 4.0, 1600000100),
((SELECT id FROM users WHERE name = 'Petrov Alex'), (SELECT id FROM movies WHERE title = 'Heat'), 5.0, 1600000200),
((SELECT id FROM users WHERE name = 'Sidorova Elena'), (SELECT id FROM movies WHERE title = 'Toy Story'), 4.5, 1600000300),
((SELECT id FROM users WHERE name = 'Kuznetsov Petr'), (SELECT id FROM movies WHERE title = 'GoldenEye'), 4.0, 1600000400);