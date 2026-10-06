#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import csv
import os
import re

DATASET = "dataset"
OUT = "db_init.sql"


def esc(s: str) -> str:
    """Экранирование одинарных кавычек для SQL."""
    return str(s).replace("'", "''")


def parse_movies(path):
    """movies.csv: movieId,title,genres (CSV с заголовком)."""
    rows = []
    with open(path, encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for r in reader:
            mid = int(r["movieId"])
            title = r["title"]
            genres = r["genres"]
            # вырезаем год из названия: "Toy Story (1995)"
            m = re.search(r"\((\d{4})\)\s*$", title)
            year = int(m.group(1)) if m else None
            if m:
                title = title[:m.start()].strip()
            rows.append((mid, title, year, genres))
    return rows


def parse_ratings(path):
    """ratings.csv: userId,movieId,rating,timestamp."""
    rows = []
    with open(path, encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append((
                int(r["userId"]),
                int(r["movieId"]),
                float(r["rating"]),
                int(r["timestamp"]),
            ))
    return rows


def parse_tags(path):
    """tags.csv: userId,movieId,tag,timestamp."""
    rows = []
    with open(path, encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append((
                int(r["userId"]),
                int(r["movieId"]),
                r["tag"],
                int(r["timestamp"]),
            ))
    return rows


def parse_users(path):
    """users.txt: id|name|email|gender|register_date|occupation."""
    rows = []
    with open(path, encoding="utf-8", newline="") as f:
        for line in f:
            line = line.rstrip("\n").rstrip("\r")
            if not line:
                continue
            parts = line.split("|")
            if len(parts) < 6:
                continue
            uid = int(parts[0])
            name = parts[1]
            email = parts[2]
            gender = parts[3]
            reg = parts[4]
            occ = parts[5]
            rows.append((uid, name, email, gender, reg, occ))
    return rows


def main():
    movies = parse_movies(os.path.join(DATASET, "movies.csv"))
    ratings = parse_ratings(os.path.join(DATASET, "ratings.csv"))
    tags = parse_tags(os.path.join(DATASET, "tags.csv"))
    users = parse_users(os.path.join(DATASET, "users.txt"))

    with open(OUT, "w", encoding="utf-8") as out:
        out.write("PRAGMA foreign_keys=OFF;\n")
        out.write("BEGIN TRANSACTION;\n")
        for t in ("ratings", "tags", "movies", "users"):
            out.write(f"DROP TABLE IF EXISTS {t};\n")

        out.write("""
CREATE TABLE movies (
  id       INTEGER PRIMARY KEY,
  title    TEXT    NOT NULL,
  year     INTEGER,
  genres   TEXT
);

CREATE TABLE ratings (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id   INTEGER NOT NULL,
  movie_id  INTEGER NOT NULL,
  rating    REAL    NOT NULL,
  timestamp INTEGER NOT NULL
);

CREATE TABLE tags (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id   INTEGER NOT NULL,
  movie_id  INTEGER NOT NULL,
  tag       TEXT    NOT NULL,
  timestamp INTEGER NOT NULL
);

CREATE TABLE users (
  id            INTEGER PRIMARY KEY,
  name          TEXT    NOT NULL,
  email         TEXT    NOT NULL,
  gender        TEXT    NOT NULL,
  register_date TEXT    NOT NULL,
  occupation    TEXT    NOT NULL
);
""")

        for mid, title, year, genres in movies:
            y = "NULL" if year is None else str(year)
            out.write(
                f"INSERT INTO movies(id,title,year,genres) VALUES "
                f"({mid},'{esc(title)}',{y},'{esc(genres)}');\n"
            )

        for uid, mid, rating, ts in ratings:
            out.write(
                f"INSERT INTO ratings(user_id,movie_id,rating,timestamp) VALUES "
                f"({uid},{mid},{rating},{ts});\n"
            )

        for uid, mid, tag, ts in tags:
            out.write(
                f"INSERT INTO tags(user_id,movie_id,tag,timestamp) VALUES "
                f"({uid},{mid},'{esc(tag)}',{ts});\n"
            )

        for uid, name, email, gender, reg, occ in users:
            out.write(
                f"INSERT INTO users(id,name,email,gender,register_date,occupation) "
                f"VALUES ({uid},'{esc(name)}','{esc(email)}','{gender}','{reg}','{esc(occ)}');\n"
            )

        out.write("COMMIT;\n")

    print(f"OK: movies={len(movies)} ratings={len(ratings)} tags={len(tags)} users={len(users)}")


if __name__ == "__main__":
    main()