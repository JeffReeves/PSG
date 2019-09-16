#!/bin/bash
# purpose: generates a fancy PS1 prompt containing various elements and emojis
# 1. Date and time with calendar, clockface, and time of day emojis.
# 2. User, machine, current directory, and $/# shell prompt.
#
# how to use:
# PS1="\$(${HOME}/PSG/PS1.sh)"
#
# note: the \ before the $ for command substitition is required
#
# author: Jeffrey Reeves
#
# arguments:
# $1 - date format string,         ex. "%a, %b %-e"
# $2 - time format string,         ex. "%R"
# $3 - timezone string,         ex. "America/Phoenix"
# $4 - set datetime manually,     ex. "5 Aug 2018 23:12:53"
#
# returns:
# string - 
# ex. "📅 Sunday, August 18, 2019 🕣 20:45 (-0700) 🌃"
# ex. "📅 Thursday, August 22, 2019 🕜 13:41 (-0700) 🌞"         
#
# string - 
# examples:
#    📅 Thursday, August 22, 2019 🕜 13:52 (-0700) 🌞
#    💻 otacon 🐢 jeff
#    📂 .../log/journal/3420da73d851400bb26d214f338f6e73
#
# TODO:
# - add option to have short PS1 or full PS1
# - add option to generate PS1 without emojis for plain text
# - add exit code from last command
# - add git branch and status info

# default values
LENGTH='long'
TIMEZONE="America/Phoenix"
DATETIME="now"

# user arguments
for ARGUMENT in "${@}"; do 
    case ${ARGUMENT} in
        --short|-s)
            LENGTH='short'
            shift
            ;;
        *)
            echo "[ERROR] Arguments passed to ${0} are invalid."
            exit 250
            ;;
    esac
done

# return values
TIME_OF_DAY=''
CLOCKFACE=''

# returns a suffix for the day (ex. "st", "nd", "rd", "th", etc.)
function get_day_suffix() {
    case $(date -d "${DATETIME}" +%d) in
        1|21|31)
            echo 'st'
            ;;
        2|22)    
            echo 'nd'
            ;;
        3|23)    
            echo 'rd'
            ;;
        *)       
            echo 'th'
            ;;
    esac
}

# formats based on length
case "${LENGTH}" in
    'short') # 0600 - 1100
        DATE_FORMAT="%a, %b %-e$(get_day_suffix)" # short version = Tues, Sept 18 @ 19:32
        TIME_FORMAT='%R' # short version = 19:16 
        ;;
    'long') # 1200 - 1600
        DATE_FORMAT="%A, %B %-e$(get_day_suffix), %Y" # long version = Sunday, August 18, 2019
        TIME_FORMAT='%R (%z)' # long version = 19:16 (-0700) 
        ;;
esac
 
# user input
# get date format
if [ ! -z "${1}" ]; then
    DATE_FORMAT="${1}"
fi

# get time format
if [ ! -z "${2}" ]; then
    TIME_FORMAT="${2}"
fi

# get timezone
if [ ! -z "${3}" ]; then
    TIMEZONE="${3}"
fi

# set datetime
if [ ! -z "${4}" ]; then
    DATETIME="${4}"
fi

# set the date and time
DATE=$(TZ="${TIMEZONE}" date -d "${DATETIME}" "+${DATE_FORMAT}")
TIME=$(TZ="${TIMEZONE}" date -d "${DATETIME}" "+${TIME_FORMAT}")

# get current hour and minute
HOUR=$(TZ="${TIMEZONE}" date -d "${DATETIME}" "+%H")
MINUTE=$(TZ="${TIMEZONE}" date -d "${DATETIME}" "+%M")

# colors
FGBG_CLEAR='\033[0m'
CLEAR_EOL='\033[K'

FG_CLEAR='\033[39m'
FG_BLACK='\033[30m'
FG_RED='\033[31m'
FG_GREEN='\033[32m'
FG_YELLOW='\033[33m'
FG_BLUE='\033[34m'
FG_MAGENTA='\033[35m'
FG_CYAN='\033[36m'
FG_LIGHT_GRAY='\033[37m'
FG_DARK_GRAY='\033[90m'
FG_LIGHT_RED='\033[91m'
FG_LIGHT_GREEN='\033[92m'
FG_LIGHT_YELLOW='\033[93m'
FG_LIGHT_BLUE='\033[94m'
FG_LIGHT_MAGENTA='\033[95m'
FG_LIGHT_CYAN='\033[96m'
FG_WHITE='\033[97m'

BG_CLEAR='\033[49m'
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_LIGHT_GRAY='\033[47m'
BG_DARK_GRAY='\033[100m'
BG_LIGHT_RED='\033[101m'
BG_LIGHT_GREEN='\033[102m'
BG_LIGHT_YELLOW='\033[103m'
BG_LIGHT_BLUE='\033[104m'
BG_LIGHT_MAGENTA='\033[105m'
BG_LIGHT_CYAN='\033[106m'
BG_WHITE='\033[107m'

# characters/emojis
CALENDAR='\U1F4C5'
# time of day
MORNING='\U1F304'
AFTERNOON='\U1F31E'
EVENING='\U1F306'
NIGHT='\U1F303'
MIDNIGHT='\U1F319'
# hour/half-hour
ONE='\U1F550'
ONE_THIRTY='\U1F55C'
TWO='\U1F551'
TWO_THIRTY='\U1F55D'
THREE='\U1F552'
THREE_THIRTY='\U1F55E'
FOUR='\U1F553'
FOUR_THIRTY='\U1F55F'
FIVE='\U1F554'
FIVE_THIRTY='\U1F560'
SIX='\U1F555'
SIX_THIRTY='\U1F561'
SEVEN='\U1F556'
SEVEN_THIRTY='\U1F562'
EIGHT='\U1F557'
EIGHT_THIRTY='\U1F563'
NINE='\U1F558'
NINE_THIRTY='\U1F564'
TEN='\U1F559'
TEN_THIRTY='\U1F565'
ELEVEN='\U1F55A'
ELEVEN_THIRTY='\U1F566'
TWELVE='\U1F55B'
TWELVE_THIRTY='\U1F567'

# temp variables
HOUR_NAME='TWELVE'
CLOCKFACE_NAME="TWELVE_THIRTY"

# functions
function is_half_past() {
# checks if the minute value is half past the hour

    local MINUTE=${1}

    # string to append to variable variable later
    case "${MINUTE}" in
        0|1[0-9]|2[0-9])
            echo ''
            ;;
        3[0-9]|4[0-9]|5[0-9]|60)
            echo '_THIRTY'
            ;;
        *)
            return 1
            ;;
    esac    
}

# determine time of day by hour
case "${HOUR}" in
    0[6-9]|1[0-1]) # 0600 - 1100
        TIME_OF_DAY="${MORNING}"
        ;;
    1[2-6]) # 1200 - 1600
        TIME_OF_DAY="${AFTERNOON}"
        ;;
    1[7-9]) # 1700 - 1900
        TIME_OF_DAY="${EVENING}"
        ;;
    2[0-3]) # 2000 - 2300
        TIME_OF_DAY="${NIGHT}"
        ;;
    0[0-5]|24) # 0000 - 0500
        TIME_OF_DAY="${MIDNIGHT}"
        ;;
esac


# determine hour name by hour
case "${HOUR}" in
    00|12|24)
        HOUR_NAME="TWELVE"
        ;;
    01|13)
        HOUR_NAME="ONE"
        ;;
    02|14)
        HOUR_NAME="TWO"
        ;;
    03|15)
        HOUR_NAME="THREE"
        ;;
    04|16)
        HOUR_NAME="FOUR"
        ;;
    05|17)
        HOUR_NAME="FIVE"
        ;;
    06|18)
        HOUR_NAME="SIX"
        ;;
    07|19)
        HOUR_NAME="SEVEN"
        ;;
    08|20)
        HOUR_NAME="EIGHT"
        ;;
    09|21)
        HOUR_NAME="NINE"
        ;;
    10|22)
        HOUR_NAME="TEN"
        ;;
    11|23)
        HOUR_NAME="ELEVEN"
        ;;
esac

# determine clockface for hour/half-hour
CLOCKFACE_NAME="${HOUR_NAME}$(is_half_past "${MINUTE}")"
CLOCKFACE="${!CLOCKFACE_NAME}"

# print values
#echo -e "${CALENDAR}" "${DATE}" "${CLOCKFACE}" "${TIME}" "${TIME_OF_DAY}"
#printf "%-2b %-s %-2b %-s %-2b\n" "${CALENDAR}" "${DATE}" "${CLOCKFACE}" "${TIME}" "${TIME_OF_DAY}"


# functions
function shorten_path() {

    local CURRENT_PATH="$(pwd)"
    local USER_HOME="/home/${USER}"
    local ROOT_HOME="/root"

    #echo "[DEBUG] CURRENT_PATH: ${CURRENT_PATH}"

    # shorten user home directory to ~ character
    if [[ "${CURRENT_PATH}" =~ "${USER_HOME}" ]] || \
       [[ "${CURRENT_PATH}" =~ "${ROOT_HOME}" ]]; then

        CURRENT_PATH=$(echo "${CURRENT_PATH}" | sed "s_${USER_HOME}_~_")
    fi

    # count number of paths
    local PATH_COUNT=$(echo "${CURRENT_PATH}" | tr -cd '/' | wc -c)

    # if the path count is greater than 3, trim the path
    if [ "${PATH_COUNT}" -gt '3' ]; then
        CURRENT_PATH=$(echo "${CURRENT_PATH}" | rev | cut -d'/' -f-3 | rev)
    fi

    # if trim lost ~ symbol or leading / character
    if [[ "${CURRENT_PATH}" != "~"* ]] && \
       [[ "${CURRENT_PATH}" != "/"* ]]; then
        CURRENT_PATH=".../${CURRENT_PATH}"
    fi

    echo "${CURRENT_PATH}"
}

# characters/emojis
RIGHT_ARROW='\U25B6'
# normal user
TURTLE='\U1F422'
COMPUTER='\U1F4BB' # alt: '\U1F5A5'
FOLDER='\U1F4C2'
CASH='\U1F4B2'
# root
COP='\U1F46E'
BICEP='\U1F4AA'

# defaults
USER_ICON="${TURTLE}"
PROMPT_ICON="${CASH}"

# get details
SHORT_DIRECTORY="$(shorten_path)"
FULL_DIRECTORY="$(pwd)"

if [ -z "${USER}" ]; then
    USER=$(whoami)
fi

if [ -z "${HOSTNAME}" ]; then
    HOSTNAME=$(uname -n)
fi

# change icons if logged in as root
if [ "${USER}" == 'root' ]; then
    USER_ICON="${COP}"
    PROMPT_ICON="${BICEP} #"
fi


# characters/emojis for exit code
CHECK='\U2705'
CROSS='\U274C'
OKAY_HAND='\U1F44C'
THUMBS_UP='\U1F44D'
THUMBS_DOWN='\U1F44E'
BOMB='\U1F4A3'
EXPLOSION='\U1F4A5'


# final output

# LINE 1 - DATE & TIME
printf "\n%-b%-b%-2b %-s %-2b %-s %-2b%-b%-b" \
"${BG_BLACK}" "${FG_WHITE}" \
"${CALENDAR}" "${DATE}" "${CLOCKFACE}" "${TIME}" "${TIME_OF_DAY}" \
"${CLEAR_EOL}" "${FGBG_CLEAR}"

# LINE 2 - HOST & USER
printf "\n%-2b %-s %-2b %-s" \
"${COMPUTER}" "${HOSTNAME}" "${USER_ICON}" "${USER}"

# LINE 3 - WORKING DIRECTORY
printf "\n%-2b %-s" \
"${FOLDER}" "${SHORT_DIRECTORY}" 

# LINE 4 - PROMPT
printf "\n%-2b " \
"${PROMPT_ICON}"

# TODO:
# - fix PS1 length on VSCode integrated terminal, 
#     which causes extra characters to show up when 
#    scrolling back through history.