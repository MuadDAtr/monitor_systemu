#!/bin/bash
# Dynamiczny Monitor Systemu



# Definicje kolorów przy użyciu tput
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

# Obsługa zakończenia skryptu (Ctrl+C)
trap "echo -e '\nSkrypt zakończony.'; exit 0" SIGINT SIGTERM

while true; do
    clear
    echo -e "${BLUE}================== Monitor Systemu ==================${RESET}"
    echo -e "Data   : $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "Uptime : $(uptime -p)"
    echo -e "------------------------------------------------------"
    
    # Pobieranie średniego obciążenia procesora
    load_avg=$(uptime | awk -F 'load average:' '{ print $2 }' | sed 's/^[ \t]*//')
    # Wyodrębnienie pierwszej wartości średniego obciążenia
    current_load=$(echo $load_avg | cut -d',' -f1)
    # Pobranie liczby rdzeni procesora
    cores=$(nproc)
    
    # Ustalenie koloru: jeżeli obciążenie przekracza liczbę rdzeni, kolor zmienia się na czerwony
    if (( $(echo "$current_load > $cores" | bc -l) )); then
        load_color=$RED
    else
        load_color=$GREEN
    fi

    echo -e "Średnie obciążenie: ${load_color}${load_avg}${RESET} (Rdzenie: $cores)"
    echo -e "------------------------------------------------------"
    
    # Użycie pamięci (wiersz z polecenia free)
    total_mem=$(free -m | awk '/^Mem:/{print $2}')
    used_mem=$(free -m | awk '/^Mem:/{print $3}')
    mem_usage_percent=$(printf "%.0f" $(echo "scale=2; ($used_mem/$total_mem)*100" | bc -l))
    
    # Ustalenie koloru dla pamięci:
    # poniżej 50% – zielony, między 50 a 80% – żółty, powyżej 80% – czerwony.
    if [ "$mem_usage_percent" -gt 80 ]; then
      mem_color=$RED
    elif [ "$mem_usage_percent" -gt 50 ]; then
      mem_color=$YELLOW
    else
      mem_color=$GREEN
    fi
    echo -e "Pamięć: ${mem_color}${used_mem}MB / ${total_mem}MB (${mem_usage_percent}%)${RESET}"
    echo -e "------------------------------------------------------"
    
    # Użycie dysku dla partycji głównej
    disk_usage=$(df -h / | awk 'NR==2 {print $5 " (" $3 "/" $2 ")"}')
    echo -e "Dysk (/): ${YELLOW}${disk_usage}${RESET}"
    
    echo -e "${BLUE}======================================================${RESET}"
    
    sleep 2
done
