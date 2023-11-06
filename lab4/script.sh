#!/bin/bash

# Константы для параметров форматирования текста
RED="\033[31m"
GREEN="\033[32m"
BOLD="\033[1m"
ITALIC="\033[3m"
RESET="\033[0m"

# Функция для вывода help-сообщения
print_help() {
	echo -e "${BOLD}Использование:${RESET} $0 [${ITALIC}ПАРАМЕТР${RESET}]"
	echo "Этот скрипт выполняет поиск в файловой системе преподавателя по заданным параметрам."
	echo
	echo -e "${BOLD}Параметры:${RESET}"
	echo -e "  -r, --min_retakes <${ITALIC}НОМЕР ГРУППЫ${RESET}>	Вывод имени студента с минимальным количеством пересдач"
	echo -e "  -s, --sort_group <${ITALIC}НОМЕР ГРУППЫ${RESET}>	Вывод списка группы, упорядоченного по количеству попыток сдачи теста"
	echo -e "  -m, --missed <${ITALIC}ФАМИЛИЯ СТУДЕНТА${RESET}>	Вывод по фамилии студента номеров пропущенных занятий"
	echo -e "  -d, --dossier <${ITALIC}ФАМИЛИЯ СТУДЕНТА${RESET}>	Вывод по фамилии студента его досье; его удаление по подтверждению пользователя"
	echo
	echo -e "${BOLD}Примеры:${RESET}"
	echo "$0 -r A-06-20"
	echo "$0 --sort A-09-20"
	echo "$0 -m DavydovAD"
	echo "$0 -d BoldyrenIN"
}

# Вывод ошибки
error() {
	echo -e "${RED}$1${RESET}"
}

# Проверка на наличие тестов по заданному предмету
check_if_tests_exist() {
	if [[ -z $(ls "./$1/tests" | grep TEST-.) ]]; then
		error "Ошибка: файлы с тестами не найдены."
		echo "Проверьте, что в директории ./$1/tests есть файлы TEST-*"
		exit 1
	fi
}

# Проверка на соостветствие фамилии шаблону
check_surname() {
	if [[ "$1" =~ [^a-zA-Z\-] ]]; then
		error "Ошибка: Неверный формат фамилии."
		echo "Фамилия должна содержать только латинские буквы."
        exit 1
	fi
}

# Проверка каждой строки из файла с тестом на соответствие шаблону
check_tests_template() {
	for line in $1; do
		if ! [[ $line =~ ^(A-[0-9][0-9]-[0-9][0-9];[a-zA-Z\-]*;[0-9]*;[0-9];2)$ ]]; then
			error "Ошибка: Строка '$line' не соответствует шаблону."
			exit 1
		fi
	done
}

# Функция для выбора варианта из предложенного списка
list_selection() {
	# Список вариантов для выбора
	list="$1"
	
	i=1
	while (( $i <= $(echo "$list" | wc -l) ))
	do
		# Вывод номера i и i-й строки
		echo "$i - $(echo "$list" | head -n $i | tail -n 1)"
	
		((i=i+1))
	done
	
	echo -e -n "${BOLD}>>${RESET} "
	read
	
	if ! [[ $REPLY =~ ^[0-9]+$ ]] || (( $REPLY < 1 )) || (( $REPLY > $(echo "$list" | wc -l) )); then
		error "Ошибка: некорректный ввод."
		exit 1
	fi
	
	return $REPLY
}

# Вывод списка доступных групп
group_list() {
	echo -e "${BOLD}Список доступных групп:${RESET}"
	ls ./students/groups
}

# Функция для вывода help-сообщения для ключа -r или --min_retakes
min_retakes_help() {
	echo "Вывод имени студента с минимальным количеством пересдач."
	echo -e "${BOLD}Использование:${RESET} $0 -r <${ITALIC}НОМЕР ГРУППЫ${RESET}>"
	echo "Формат группы должен быть: A-NN-YY."
	group_list
}



# Вывод имени студента с минимальным количеством пересдач
min_retakes() {
    local group=$1

	# Проверка соответствия шаблону группы
	if ! [[ "$group" =~ ^A-[0-9][1-9]-[0-9][0-9]$ ]]; then
		error "Ошибка: Неверный формат номера группы."
		echo "Формат группы должен быть: A-NN-YY."
		return 1
	fi
	
	# Проверка на наличие такой группы
	if (( $(ls ./students/groups | grep $group | wc -l) == 0 )); then
		error "Ошибка: группа не найдена."
		group_list
		return 1
	fi
	
	# Выбор предмета
	echo -e "${BOLD}Выберите предмет:${RESET}" 
	subjects="$(find . -maxdepth 1 -type d | grep ./ | grep -v students | sed "s/\.\///")"
	list_selection "$subjects"
	subject=$(echo "$subjects" | head -n $? | tail -n 1)
	
	# Проверка на наличие тестов по данному предмету
	check_if_tests_exist $subject
	
	# Проверка каждой строки из файла с тестом на соответствие шаблону
	check_tests_template "$(grep "$group" ./$subject/tests/TEST-* | grep "2$" | sed "s/.*:\(.*\)/\1/")"
	
	# Все пересдачи в указанной группе
    retakes=$(grep "$group" ./$subject/tests/TEST-* | grep "2$" | sed "s/.*;\(.*\);.*;.*;.*/\1/g" | sort | uniq -c | sort)

	if [ -z "$retakes" ]; then
		echo "Не найдено студентов с пересдачами."
	else
		# Минимальное количество пересдач в группе
		min_retakes=$(echo "$retakes" | head -n 1 | sed 's/ *\([0-9]\+\) .*/\1/')
		# Имена всех студентов с минимальным количеством пересдач
		students=$(echo "$retakes" | grep "$min_retakes " | sed "s/[^a-zA-Z]*//")
		
		echo -e "${BOLD}Студенты с мнимальным количеством пересдач ($min_retakes) по предмету $subject в группе $group:${RESET}"
		echo "$students"
	fi
}

# Функция для вывода help-сообщения для ключа -s или --sort
sort_group_help() {
	echo "Вывод списка группы, упорядоченного по количеству попыток сдачи теста."
	echo -e "${BOLD}Использование:${RESET} $0 -s <${ITALIC}НОМЕР ГРУППЫ${RESET}>"
	echo "Формат группы должен быть: A-NN-YY."
	group_list
}

# Вывод списка группы, упорядоченного по количеству попыток сдачи теста
sort_group() {
    group=$1

	# Проверка соответствия шаблону группы
	if ! [[ "$group" =~ ^A-[0-9][1-9]-[0-9][0-9]$ ]]; then
		error "Ошибка: Неверный формат номера группы."
		echo "Формат группы должен быть: A-NN-YY."
		exit 1
	fi
	
	# Проверка на наличие такой группы
	if (( $(ls ./students/groups | grep $group | wc -l) == 0 )); then
		error "Ошибка: группа не найдена."
		group_list
		exit 1
	fi
	
	# Выбор предмета
	echo -e "${BOLD}Выберите предмет:${RESET}"
	subjects="$(find . -maxdepth 1 -type d | grep ./ | grep -v students | sed "s/\.\///")"
	list_selection "$subjects"
	subject=$(echo "$subjects" | head -n $? | tail -n 1)
	
	# Проверка на наличие тестов по данному предмету
	check_if_tests_exist $subject
	
	# Выбор теста
	echo -e "${BOLD}Список доступных тестов:${RESET}"
	ls ./$subject/tests
	echo -e -n "${BOLD}Введите номер теста:${RESET} "
	read
	
	if [ ! -f ./$subject/tests/TEST-$REPLY ]; then
		error "Ошибка: тест не найден."
		return 1
	fi
	
	if [[ -z $(grep "$group" ./$subject/tests/TEST-$REPLY) ]]; then
		echo "Пересдачи в группе $group по тесту TEST-$REPLY не найдены."
		return 0
	fi
	
	# Проверка каждой строки из файла с тестом на соответствие шаблону
	check_tests_template "$(grep "$group" ./$subject/tests/TEST-$REPLY | grep "2$" | sed "s/.*:\(.*\)/\1/")"
	
	# Все пересдачи в указанной группе
	group_list=$(grep "$group" ./$subject/tests/TEST-$REPLY | sed "s/.*;\(.*\);.*;.*;.*/\1/g" | sort | uniq -c | sort | sed "s/^[[:space:]]*//")
	
	echo "$group_list"
}

# Функция для вывода help-сообщения для ключа -m или --missed
missed_help() {
	echo "Вывод по фамилии студента номеров пропущенных занятий."
	echo -e "${BOLD}Использование:${RESET} $0 -m <${ITALIC}ФАМИЛИЯ СТУДЕНТА${RESET}>"
}

# Вывод по фамилии студента номеров пропущенных занятий
missed() {
    surname=$1
	
	check_surname $surname
	
	#Список студентов, найденных по данной фамилии
	students=$(grep -r "$surname" ./students/groups/ | sed "s/.*\(A-[0-9][0-9]-[0-9][0-9]\):\([a-zA-Z]*\)/\1 \2/")

	if [[ -z $students ]]; then
		# Если нет студентов с такой фамилией
		error "Ошибка: студент $surname не найден."
		return 1
	elif (( $(echo "$students" | wc -l) > 1 )); then
		echo -e "${BOLD}Найдено несколько студентов:${RESET}"

		# Выбор из нескольких найденных студентов
		list_selection "$students"
		students=$(echo "$students" | head -n $? | tail -n 1)
	else
		student=$(echo $students)
	fi
	
	surname=$(echo $students | sed "s/.* //")
	group=$(echo $students | sed "s/ .*//")
	
	# Выбор предмета
	echo -e "${BOLD}Выберите предмет:${RESET}" 
	subjects="$(find . -maxdepth 1 -type d | grep ./ | grep -v students | sed "s/\.\///")"
	list_selection "$subjects"
	subject=$(echo "$subjects" | head -n $? | tail -n 1)

	# Отсутствие файла с посещаемостью
	if ! [[ -f ./$subject/${group}-attendance ]]; then
		error "Файл с посещаемостью отсутствует: ./$subject/${group}-attendance"
		return 1
	fi

	student_attendance=$(grep "$surname" ./$subject/${group}-attendance | sed "s/.* //")
	
	# В файле есть искомая фамилия, но информация о пропусках отсутствует
	if [[ -z $student_attendance ]]; then
		error "Ошибка: информации о пропусках не найдено."
		return 1
	fi
	
	# Если пропуски отсутствуют
	if ! [[ $student_attendance == *"0"* ]]; then
		echo -e -n "${BOLD}У студента $surname из группы $group отсутствуют пропущенные занятия.${RESET} "
		return 0
	# Если все пропущены
	elif ! [[ $student_attendance == *"1"* ]]; then
		echo -e -n "${BOLD}У студента $surname из группы $group пропущены все занятия.${RESET} "
		return 0
	fi
	
	echo -e -n "${BOLD}Номера пропущеных занятий студента $surname из группы $group:${RESET} "
	for ((i=0; i<${#student_attendance}; i++)); do
		if [ "${student_attendance:i:1}" == "0" ]; then
			echo -n "$((i + 1)) "
		fi
	done
}

# Функция для вывода help-сообщения для ключа -d или --dossier
dossier_help() {
	echo "Вывод по фамилии студента его досье; его удаление по подтверждению пользователя."
	echo -e "${BOLD}Использование:${RESET} $0 -d <${ITALIC}ФАМИЛИЯ СТУДЕНТА${RESET}>"
}

# Вывод по фамилии студента его досье; его удаление по подтверждению пользователя
dossier() {
    surname=$1
	
	check_surname $surname
	
	filepath="./students/general/notes/${surname:0:1}Names.log"
	
	# Если нет фамилий наачинающихся на первую букву указанной фамилии
	if [[ -f $filepath ]]; then
		matches=$(grep -c "$surname" $filepath)
		
		# Если нет студентов с такой фамилией
		if (( matches == 0 )); then
			echo "По фамилии $surname не найдено ни одного досье."
			return 1
		# Если студент с такой фамилией один
		elif (( matches == 1 )); then
			# Если найдено только одно совпадение
			match=1
		# Если студентов с такой фамилией несколько
		else
			# Если найдено более одного совпадения
			echo "Найдено несколько студентов с фамилией '$surname'."
			echo -e "${BOLD}Выберите досье:${RESET}"
			
			i=1
			while (( $i <= matches ))
			do
				# Вывод номера i и i-го досье
				echo "$i - $(grep -m $i -A1 "$surname" $filepath | tail -n 2)"
			
				(( i=i+1 ))
			done
			
			read -r -p ">> " match
			
			if ! [[ $match =~ ^[0-9]+$ ]] || (( $match < 1 )) || (( $match > $matches )); then
				echo
				echo "Ошибка: некорректный ввод."
				return 1
			fi
		fi

	else
		# Если файл не существует (нет фамилий на эту букву)
		echo "Студент $surname не найден."
		return 1
	fi
	
	surname=$(grep -m $match "$surname" $filepath | head -n $match | tail -n 1)
	dossier=$(grep -m $match -A1 "$surname" $filepath | tail -n 1)
	
	# Если досье по какой то причине отсутствует
	if [[ $dossier == *"="* ]]; then
		error "Ошибка: фамилия найдена, однако досье отсутствует."
		return 1
	fi
	
	# Вывод найденного досье
	echo -e -n "${BOLD}Досье студента $surname:${RESET} "
	echo "$dossier"
	
	read -r -p "Удалить досье студента $surname? (y/n): " response

	case $response in
		([yY][eE][sS]|[yY]|[дД][аА]|[дД])
			# Получение номера строки с фамилией в файле
			line_number=$(grep -m $match -n "$surname" $filepath | tail -n 1 | cut -d: -f1)
			# Удаление строки с фамилией, а также одной строки выше и ниже нее
			sed -i "$((line_number-1)),$((line_number+1))d" $filepath
			echo -e "${BOLD}${GREEN}Досье удалено.${RESET}"
			exit 0
			;;
		([nN][oO]|[nN]|[нН][еЕ][тТ]|[нН])
			exit 0
			;;
		(*)
			error "Ошибка: неверная команда."
			exit 1
			;;
	esac
}

# Обработка ключей
option="$1"

case $option in
	(-r|--min_retakes)
		# Обработка ключа -r или --min_retakes
		
		#Если не введена группа
		if [[ -z $2 ]]; then
			min_retakes_help
			exit 0
		fi
		
		min_retakes $2
		exit 0
		;;
	(-s|--sort_group)
		# Обработка ключа -s или --sort
		
		#Если не введена группа
		if [[ -z $2 ]]; then
			sort_group_help
			exit 0
		fi
		
		sort_group $2
		exit 0
		;;
	(-m|--missed)
		# Обработка ключа -m или --missed
		
		#Если не введена фамилия
		if [[ -z $2 ]]; then
			missed_help
			exit 0
		fi
		
		missed $2
		exit 0
		;;
	(-d|--dossier)
		# Обработка ключа -d или --dossier
		
		#Если не введена фамилия
		if [[ -z $2 ]]; then
			dossier_help
			exit 0
		fi
		
		dossier $2
		exit 0
		;;
	(-h|--help)
		# Вывод help-сообщения и выход из скрипта
		print_help
		exit 0
		;;
	(?*)
		# Неизвестный ключ
		error "Ошибка: неизвестный параметр: $option"
		print_help
		exit 1
		;;
	(*)
		# Отсутствие параметра
		echo -e "${BOLD}Использование:${RESET} $0 [ПАРАМЕТР]"
		echo "Введите $0 --help для дополнительной информации."
		exit 1
		;;
esac