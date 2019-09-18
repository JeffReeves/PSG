#!/bin/bash
# purpose: generate a date and time string for use in a shell prompt string
# how to use: 
#   ./date-time.sh [arguments]
# author: Jeff Reeves

# default values
DEBUG='false'
LENGTH='long'
EMOJI='false'
DATETIME='now'

# user arguments
for ARGUMENT in "${@}"; do 
    case ${ARGUMENT} in
        --debug|-v)
            DEBUG='true'
            shift
            ;;
        --short|-s)
            LENGTH='short'
            shift
            ;;
        --emoji|-e)
            EMOJI='true'
            shift
            ;;
        --datetime*|-d*)
            DATETIME=$(echo "${1}" | awk -F '(^--datetime|^-d)=?' '{ print $2 }')
            shift
            ;;
        --timezone*|-t*)
            TIMEZONE=$(echo "${1}" | awk -F '(^--timezone|^-t)=?' '{ print $2 }')
            if [ ! -z ${TIMEZONE} ]; then 
                export TZ="${TIMEZONE}"
            fi
            shift
            ;;
        *)
            echo "[ERROR] Arguments passed to ${0} are invalid."
            exit 250
            ;;
    esac
done

# debug output
if [ "${DEBUG}" == 'true' ]; then
    echo "[DEBUG]"
    echo "LENGTH: ${LENGTH}"
    echo "EMOJI: ${EMOJI}"
    echo "DATETIME: ${DATETIME}"
    echo "TIMEZONE: ${TIMEZONE}"
    echo ""
fi

# returns a suffix for the day
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
    'short')
        # Tues, Sept 18th
        # 19:32
        DATE_FORMAT="%a, %b %-e$(get_day_suffix)"
        TIME_FORMAT='%R'
        ;;
    'long')
        # Sunday, August 18th, 2019
        # 19:16 (-0700)
        DATE_FORMAT="%A, %B %-e$(get_day_suffix), %Y"
        TIME_FORMAT='%R (%z)'
        ;;
esac

# set date and time
DATE=$(date -d "${DATETIME}" "+${DATE_FORMAT}")
TIME=$(date -d "${DATETIME}" "+${TIME_FORMAT}")

# if emojis are disabled
if [ "${EMOJI}" == 'false' ]; then 
    
    # output plain text
    printf "%-s @ %-s" \
    "${DATE}" "${TIME}"

    exit 0
else

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

    # checks if the minute value is half past the hour
    function is_half_past() {

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

    # get current hour and minute
    HOUR=$(date -d "${DATETIME}" "+%H")
    MINUTE=$(date -d "${DATETIME}" "+%M")

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

    # output emoji string
    printf "%-2b %-s %-2b %-s %-2b" \
    "${CALENDAR}" "${DATE}" "${CLOCKFACE}" "${TIME}" "${TIME_OF_DAY}"
fi

# COLORED OUTPUT
# TODO:
# - include common color library
# printf "%-b%-b%-2b %-s %-2b %-s %-2b%-b%-b" \
# "${BG_BLACK}" "${FG_WHITE}" \
# "${CALENDAR}" "${DATE}" "${CLOCKFACE}" "${TIME}" "${TIME_OF_DAY}" \
# "${CLEAR_EOL}" "${FGBG_CLEAR}"