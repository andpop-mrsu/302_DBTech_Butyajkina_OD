#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили. В списке оставить первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT u1.first_name || ' ' || u1.surname AS user1, u2.first_name || ' ' || u2.surname AS user2, m.title FROM ratings r1 JOIN ratings r2 ON r1.movieId = r2.movieId AND r1.userId < r2.userId JOIN users u1 ON r1.userId = u1.userId JOIN users u2 ON r2.userId = u2.userId JOIN movies m ON r1.movieId = m.movieId LIMIT 100;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT m.title, u.first_name || ' ' || u.surname AS user_name, r.rating, strftime('%Y-%m-%d', r.timestamp) AS rating_date FROM ratings r JOIN users u ON r.userId = u.userId JOIN movies m ON r.movieId = m.movieId ORDER BY r.timestamp DESC LIMIT 10;"
echo " "

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке 'Рекомендуем' для фильмов должно быть написано 'Да' или 'Нет'."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH MovieAverages AS (SELECT movieId, AVG(rating) AS avg_rating FROM ratings GROUP BY movieId), RankedAverages AS (SELECT movieId, avg_rating, MAX(avg_rating) OVER() as max_avg, MIN(avg_rating) OVER() as min_avg FROM MovieAverages) SELECT m.title, m.year, ra.avg_rating, CASE WHEN ra.avg_rating = ra.max_avg THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем' FROM RankedAverages ra JOIN movies m ON ra.movieId = m.movieId WHERE ra.avg_rating = ra.max_avg OR ra.avg_rating = ra.min_avg ORDER BY m.year, m.title;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(r.rating) AS total_ratings, AVG(r.rating) AS avg_rating FROM ratings r JOIN users u ON r.userId = u.userId WHERE u.gender = 'F' AND strftime('%Y', r.timestamp) BETWEEN '2010' AND '2012';"
echo " "

echo "5. Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH AvgRatings AS (SELECT movieId, AVG(rating) AS avg_rating FROM ratings GROUP BY movieId) SELECT m.title, m.year, ar.avg_rating, RANK() OVER (ORDER BY ar.avg_rating DESC) AS rating_place FROM movies m JOIN AvgRatings ar ON m.movieId = ar.movieId ORDER BY m.year, m.title LIMIT 20;"
echo " "

echo "6. Вывести список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации' (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT surname || ' ' || first_name || '|' || strftime('%Y-%m-%d', registration_date) AS user_info FROM users ORDER BY registration_date DESC LIMIT 10;"
echo " "

echo "7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE nums(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM nums WHERE n < 10) SELECT n1.n || 'x' || n2.n || '=' || (n1.n * n2.n) AS multiplication_table FROM nums n1 CROSS JOIN nums n2;"
echo " "

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres(movieId, genre, rest) AS (SELECT movieId, '', genres || '|' FROM movies UNION ALL SELECT movieId, substr(rest, 0, instr(rest, '|')), substr(rest, instr(rest, '|') + 1) FROM split_genres WHERE rest <> '') SELECT DISTINCT genre FROM split_genres WHERE genre <> '' ORDER BY genre;"
echo " "