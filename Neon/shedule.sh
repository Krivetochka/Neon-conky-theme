#!/bin/bash
# Start of user config

# Schedule template: "Class name|HH:MM-HH:MM|Classroom number"

# mon – Monday
# tue – Tuesday
# wed – Wednesday
# thu – Thursday
# fri – Friday
# sat – Saturday
# sun – Sunday

# _up - upper week; _down - lower (even, or odd in some universities); leave only schedule_weekday if week switching is not needed

# Example of a schedule:
# upper week
schedule_mon_up=(
  "Physics|11:50-13:20|234"
)

schedule_tue_up=(
  "Math|08:30-10:00|223"
  "Chemistry|10:10-11:40|223"
  "Biology|11:50-13:20|223"
  "Geography|13:50-15:20|345"
  "P.E.|17:10-18:40|Hall 2"
)

schedule_wed_up=(
  "History|11:50-13:20|401"
  "Literature|17:10-18:40|Web"
)

schedule_thu_up=(
  "Math|10:10-11:40|94"
  "Physics|11:50-13:20|94"
  "Chemistry|13:50-15:20|94"
  "P.E.|17:10-18:40|Hall 1"
)

schedule_fri_up=(
  "CS|10:10-11:40|141"
  "History|17:10-18:40|Web"
  "Biology|18:50-20:20|Web"
)

schedule_sat_up=(
)

# lower week
schedule_mon_down=(
  "Physics|10:10-11:40|234"
  "Chemistry|11:50-13:20|234"
)

schedule_tue_down=(
  "Physics|08:30-10:00|227"
  "Physics|10:10-11:40|227"
  "Physics|11:50-13:20|227"
  "Chemistry|13:50-15:20|118"
  "P.E.|17:10-18:40|Hall 2"
)

schedule_wed_down=(
  "History|17:10-18:40|Web"
)

schedule_thu_down=(
  "Math|10:10-11:40|229"
  "Math|11:50-13:20|229"
  "Chemistry|13:50-15:20|229"
  "P.E.|17:10-18:40|Hall 3"
)

schedule_fri_down=(
  "CS|10:10-11:40|421"
  "History|17:10-18:40|Web"
  "History|18:50-20:20|Web"
)

schedule_sat_down=(
)



offset1=190 # Offset from left edge to class time
offset2=345 # Offset from left edge to classroom number

current_week="_down" # "_up" or "_down" or ""; In many universities this is called "even or odd week", I haven't come up with auto-switching yet, you need to manually change the config weekly. If you don’t have week switching, use "".

# End of user config

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

# If schedule is empty (e.g., no classes that day), exit
if [ ${#current_schedule[@]} -eq 0 ]; then
  exit 0
fi

# Get last schedule entry
last_index=$((${#current_schedule[@]} - 1))
last_entry="${current_schedule[$last_index]}"
IFS='|' read -r _ last_time_range _ <<< "$last_entry"
IFS='-' read -r _ last_end <<< "$last_time_range"

# If current time is after the end of the last class, exit the script without output
if [[ "$current_time" > "$last_end" ]]; then
  exit 0
fi

echo "\${hr}"
prev_end=""
echo "\${color}Subject            Time           Room \${color}"
for entry in "${current_schedule[@]}"; do

  IFS='|' read -r name time_range classroom <<< "$entry"
  IFS='-' read -r start end <<< "$time_range"
  

  
  # If this is not the first class, check if current time is during the break
  if [[ -n "$prev_end" ]]; then
    if [[ "$current_time" > "$prev_end" && "$current_time" < "$start" ]]; then
      # Show break
      echo "\${color red}Break \${goto $offset1}$prev_end-$start\${color}"
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

