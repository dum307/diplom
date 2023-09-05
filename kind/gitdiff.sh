#!/bin/bash

# Получаем список измененных и созданных файлов между последним и предпоследним коммитами
#changed_files=$(git diff --name-only --diff-filter=ACM HEAD HEAD~1)
# changed_files=$(git diff --name-only --diff-filter=a HEAD HEAD~1)
changed_files=$(git diff --name-only HEAD HEAD~1)

# Преобразуем список в формат JSON
json_output="{"
first_file=true

for file in $changed_files; do
  if [ "$first_file" = true ]; then
    json_output+="\"$file\""
    first_file=false
  else
    json_output+=", \"$file\""
  fi
done

json_output+="}"

# Выводим JSON
echo "$json_output"