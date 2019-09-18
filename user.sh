#!/bin/bash
# purpose: outputs the current user, with special formatting based on username
# how to use: 
#   ./user.sh [arguments]
# author: Jeff Reeves

# default values
DEBUG='false'
EMOJI='false'
USER_ICON='MAN'
ROOT_ICON='POLICE_OFFICER'

# user arguments
for ARGUMENT in "${@}"; do 
    case ${ARGUMENT} in
        --debug|-v)
            DEBUG='true'
            shift
            ;;
        --emoji|-e)
            EMOJI='true'
            shift
            ;;
        --user-icon*|--user*|-u*)
            USER_ICON=$(echo "${1}" | awk -F '(^--user-icon|^--user|^-u)=?' '{ print $2 }')
            shift
            ;;
        --root-icon*|--root*|-r*)
            ROOT_ICON=$(echo "${1}" | awk -F '(^--root-icon|^--root|^-r)=?' '{ print $2 }')
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
    echo "EMOJI: ${EMOJI}"
    echo "USER_ICON: ${USER_ICON}"
    echo "ROOT_ICON: ${ROOT_ICON}"
    echo ""
fi

# characters/emojis
# TODO:
# - include emojis and colors in shared library file
# standard users
SILHOUETTE='\U1F464'
MAN='\U1F468'
CONSTRUCTION_WORKER='\U1F477'
GHOST='\U1F47B'
ALIEN='\U1F47D'
TURTLE='\U1F422'
# root
POLICE_OFFICER='\U1F46E'
ROYAL_GUARD='\U1F482'

# set uid, if not present
if [ -z "${UID}" ]; then
    UID=$(id -u)
fi

# set icons based on user and uid
if [ "${UID}" == '0' ]; then
    USER_EMOJI="${!ROOT_ICON}"
else
    USER_EMOJI="${!USER_ICON}"
fi

# set username, if not present
if [ -z "${USER}" ]; then
    USER=$(whoami)
fi

# debug output B
if [ "${DEBUG}" == 'true' ]; then
    echo "[DEBUG B]"
    echo "UID: ${UID}"
    echo -e "USER_EMOJI: ${USER_EMOJI}"
    echo "USER: ${USER}"
    echo ""
fi

# if emojis are disabled
if [ "${EMOJI}" == 'false' ]; then

    # output plain text
    printf "%-s" \
    "${USER}"
else

    # output emoji string
    printf "%-2b %-s" \
    "${USER_EMOJI}" "${USER}"
fi