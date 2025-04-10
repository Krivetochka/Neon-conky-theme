#!/bin/bash
# Начало пользовательского конфига

# Шаблон расписания: "Название пары|HH:MM-HH:MM|номер кабинета"

# mon – понедельник
# tue – вторник
# wed – среда
# thu – четверг
# fri – пятница
# sat – суббота
# sun – воскресенье

# _up - верхняя неделя; _down - нижняя(четная, нечетная в некоторых вузах); оставьте только shedule_деньнедели, если смена недель не требуется

# верхняя неделя
schedule_mon_up=(
  "Физика|11:50-13:20|234"
)

schedule_tue_up=(
  "Математика|08:30-10:00|223"
  "Химия|10:10-11:40|223"
  "Биология|11:50-13:20|223"
  "География|13:50-15:20|345"
  "Физкультура|17:10-18:40|Зал 2"
)

schedule_wed_up=(
  "История|11:50-13:20|401"
  "Литература|17:10-18:40|Вебинар"
)

schedule_thu_up=(
  "Математика|10:10-11:40|94"
  "Физика|11:50-13:20|94"
  "Химия|13:50-15:20|94"
  "Физкультура|17:10-18:40|Зал 1"
)

schedule_fri_up=(
  "Информатика|10:10-11:40|141"
  "История|17:10-18:40|Вебинар"
  "Биология|18:50-20:20|Вебинар"
)

schedule_sat_up=(
)

# нижняя неделя
schedule_mon_down=(
  "Физика|10:10-11:40|234"
  "Химия|11:50-13:20|234"
)

schedule_tue_down=(
  "Физика|08:30-10:00|227"
  "Физика|10:10-11:40|227"
  "Физика|11:50-13:20|227"
  "Химия|13:50-15:20|118"
  "Физкультура|17:10-18:40|Зал 2"
)

schedule_wed_down=(
  "История|17:10-18:40|Вебинар"
)

schedule_thu_down=(
  "Математика|10:10-11:40|229"
  "Математика|11:50-13:20|229"
  "Химия|13:50-15:20|229"
  "Физкультура|17:10-18:40|Зал 3"
)

schedule_fri_down=(
  "Информатика|10:10-11:40|421"
  "История|17:10-18:40|Вебинар"
  "История|18:50-20:20|Вебинар"
)

schedule_sat_down=(
)



offset1=190 # Отступ от левого края до времени пары
offset2=345 # Отступ от левого края до номера кабинета

current_week="_down" # "_up" или "_down" или ""; Во многих вузах эта система называется "четная или нечетная неделя", я пока не придумал автосмену недели, нужно каждую неделю менять конфиг. Если у вас нет смены недель, используйте "".

# конец пользовательского конфига

day_code=$(LC_TIME=C date +%a | tr '[:upper:]' '[:lower:]')
declare -A day_map=(
  [mon]="mon"
  [tue]="tue"
  [wed]="wed"
  [thu]="thu"
  [fri]="fri"
  [sat]="sat"
  [sun]="sun"
)
eval "current_schedule=(\"\${schedule_${day_map[$day_code]}$current_week[@]}\")"

current_time=$(date +%H:%M)

# Если расписание пустое (например, если нет занятий в этот день), выходим
if [ ${#current_schedule[@]} -eq 0 ]; then
  exit 0
fi

# Получаем последний элемент расписания
last_index=$((${#current_schedule[@]} - 1))
last_entry="${current_schedule[$last_index]}"
IFS='|' read -r _ last_time_range _ <<< "$last_entry"
IFS='-' read -r _ last_end <<< "$last_time_range"

# Если текущее время больше времени окончания последней пары, завершаем скрипт без вывода расписания
if [[ "$current_time" > "$last_end" ]]; then
  exit 0
fi

echo "\${hr}"
prev_end=""
echo "\${color}Предмет            Время          Кабинет \${color}"
for entry in "${current_schedule[@]}"; do

  IFS='|' read -r name time_range classroom <<< "$entry"
  IFS='-' read -r start end <<< "$time_range"
  

  
  # Если это не первая пара, проверяем, находится ли текущее время в периоде перемены
  if [[ -n "$prev_end" ]]; then
    if [[ "$current_time" > "$prev_end" && "$current_time" < "$start" ]]; then
      # Вывод перемены
      echo "\${color red}Перемена \${goto $offset1}$prev_end-$start\${color}"
    fi
  fi

  if [[ "$current_time" > "$start" && "$current_time" < "$end" ]]; then
    echo "\${color red}$name \${goto $offset1}$start-$end \${goto $offset2}$classroom \${color}"
  else
    echo "\${color lightgrey}$name \${goto $offset1}$start-$end \${goto $offset2}$classroom\${color}"
  fi
  prev_end="$end"
done
echo "\$hr"
