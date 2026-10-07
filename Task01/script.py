import csv
from collections import Counter

file_path = 'Task01/ratings.csv'  # проверьте реальное имя файла в dataset

user_ids = []
with open(file_path, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    next(reader)  # пропустить заголовок, если он есть
    for row in reader:
        user_ids.append(row[0])  # ID пользователя — предполагаем 1-й столбец

counts = Counter(user_ids)
min_id = min(counts, key=int)
max_id = max(counts, key=int)

with open('Task01/ratings_count.txt', 'w') as f:
    f.write(f"{min_id} {counts[min_id]}\n")
    f.write(f"{max_id} {counts[max_id]}\n")

print("Готово! Файл ratings_count.txt создан.")