#!/bin/bash
# purpose: outputs the current host, with special formatting based on hostname
# how to use: 
#   ./host.sh [arguments]
# author: Jeff Reeves

# default values
DEBUG='false'
LENGTH='long'
EMOJI='false'
HOSTS_FILE='hosts.txt'
LAB='LAB'
DEV='DEVELOPMENT'
TEST='TEST-QA'
PROD='PRODUCTION'
ENVIRONMENTS="${LAB} ${DEV} ${TEST} ${PROD}"
ENVIRONMENT="${LAB}"

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
        --hosts-file*|--hosts*|-h*)
            HOSTS_FILE=$(echo "${1}" | awk -F '(^--hosts-file|^--hosts|^-h)=?' '{ print $2 }')
            shift
            ;;
        --environments*|--envs*|-e*)
            ENVIRONMENTS=$(echo "${1}" | awk -F '(^--environments|^--envs|^-)=?' '{ print $2 }')
            shift
            ;;
        --lab*|-l*)
            LAB=$(echo "${1}" | awk -F '(^--lab|^-l)=?' '{ print $2 }')
            shift
            ;;
        --development*|--dev*|-d*)
            DEV=$(echo "${1}" | awk -F '(^--development|^--dev|^-d)=?' '{ print $2 }')
            shift
            ;;
        --test*|-t*|--qa*|-q*)
            QA=$(echo "${1}" | awk -F '(^--test|^-t|^--qa|^-q)=?' '{ print $2 }')
            shift
            ;;
        --production*|--prod*|-p*)
            PROD=$(echo "${1}" | awk -F '(^--production|^--prod|^-p)=?' '{ print $2 }')
            shift
            ;;
        *)
            echo "[ERROR] Arguments passed to ${0} are invalid."
            exit 250
            ;;
    esac
done

# debug output A
if [ "${DEBUG}" == 'true' ]; then
    echo "[DEBUG A]"
    echo "LENGTH: ${LENGTH}"
    echo "EMOJI: ${EMOJI}"
    echo "HOSTS_FILE: ${HOSTS_FILE}"
    echo "ENVIRONMENTS: ${ENVIRONMENTS}"
    echo "ENVIRONMENT: ${ENVIRONMENT}"
    echo ""
fi

# create default hosts file, if empty or does not exist
if [ ! -s "${HOSTS_FILE}" ]; then

    echo "[WARNING] hosts file ${HOSTS_FILE} missing or empty"
    echo "[TASK] Creating default hosts file (${HOSTS_FILE})..."

    for ITEM in ${ENVIRONMENTS}; do
        echo -e "[${ITEM}]\n\n" >> "${HOSTS_FILE}"
        EXIT_CODE=$?
        if [ "${EXIT_CODE}" -ne '0' ]; then
            echo "[ERROR] Unable to create/write to ${HOSTS_FILE}"
            echo "[HELP] Verify ${HOSTS_FILE} exists and contains hostnames"
            exit 100
        fi
    done

    echo "[SUCCESS] Wrote default hosts file at ${HOSTS_FILE}"
    echo "[HELP] Edit hosts file to include desired environments and hostnames, then run script again"
    echo ""
    exit 1
fi

# set hostname, if not present
if [ -z "${HOSTNAME}" ]; then
    HOSTNAME=$(uname -n)
fi

# iterate over lines in host file to find environment
while IFS='' read -r LINE || [ -n "${LINE}" ]; do

    # if line contains [] brackets, extract the environment
    if [[ "${LINE}" == \[*] ]]; then
        ENVIRONMENT=$(echo "${LINE}" | sed -E "s/^\[(.*)\]$/\\1/")
    elif [[ "${LINE}" == "${HOSTNAME}" ]]; then
        break
    fi

done < "${HOSTS_FILE}"

# characters/emojis
# TODO:
# - include emojis and colors in shared library file
COMPUTER='\U1F4BB'
DESKTOP='\U1F5A5'   # not supported everywhere
BLUE_BOOK='\U1F4D8'
GREEN_BOOK='\U1F4D7'
ORANGE_BOOK='\U1F4D9'
RED_BOOK='\U1F4D5'

# set formatting based on environment
case "${ENVIRONMENT}" in
    "${LAB}")
        ENVIRONMENT="E0"
        ENVIRONMENT_EMOJI="${BLUE_BOOK}"
        ;;
    "${DEV}")
        ENVIRONMENT="E1"
        ENVIRONMENT_EMOJI="${GREEN_BOOK}"
        ;;
    "${TEST}")
        ENVIRONMENT="E2"
        ENVIRONMENT_EMOJI="${ORANGE_BOOK}"
        ;;
    "${PROD}")
        ENVIRONMENT="E3"
        ENVIRONMENT_EMOJI="${RED_BOOK}"
        ;;
    *)
        ENVIRONMENT="E0"
        ENVIRONMENT_EMOJI="${BLUE_BOOK}"
        ;;
esac

# debug output B
if [ "${DEBUG}" == 'true' ]; then
    echo "[DEBUG B]"
    echo "ENVIRONMENT: ${ENVIRONMENT}"
    echo "HOSTNAME: ${HOSTNAME}"
    echo ""
fi

# if emojis are disabled
if [ "${EMOJI}" == 'false' ]; then 
    
    # output plain text
    printf "[%-s] %-s" \
    "${ENVIRONMENT}" "${HOSTNAME}"

    exit 0
else

    # characters/emojis
    COMPUTER='\U1F4BB'
    DESKTOP='\U1F5A5'   # not supported everywhere

    # output emoji string
    printf "%-2b [%-2b] %-s" \
    "${COMPUTER}" "${ENVIRONMENT_EMOJI}" "${HOSTNAME}"
fi