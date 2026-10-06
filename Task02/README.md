# Task02 — ETL: генерация базы movies_rating.db

## Требования к окружению
- Python 3.6+
- SQLite 3 (команда `sqlite3` доступна в PATH)
- bash (Linux/macOS — из коробки; Windows — Git Bash или WSL)

## Запуск
Из каталога Task02:

    bash db_init.bat

## Что делает
1. `make_db_init.py` читает файлы из `dataset/` (movies.csv, ratings.csv,
   tags.csv, users.txt) и генерирует SQL-скрипт `db_init.sql`.
2. `sqlite3` загружает `db_init.sql` в базу `movies_rating.db`,
   предварительно удаляя старые таблицы.

## Результат
Файл `movies_rating.db` с таблицами movies, ratings, tags, users,
заполненными данными из исходных файлов.