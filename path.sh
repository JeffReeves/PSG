#!/bin/bash
# purpose: outputs the pwd, with special formatting
# how to use: 
#   ./path.sh [arguments]
# author: Jeff Reeves

# default values
DEBUG='false'
LENGTH='short'
EMOJI='false'
GET_DETAILS='false'
MOUNT_SHOW='false'
PARTITION_SHOW='false'

# user arguments
for ARGUMENT in "${@}"; do 
    case ${ARGUMENT} in
        --debug|-v)
            DEBUG='true'
            shift
            ;;
        --long|-l)
            LENGTH='long'
            shift
            ;;
        --emoji|-e)
            EMOJI='true'
            shift
            ;;
        --get-details|-g)
            GET_DETAILS='true'
            shift
            ;;
        --mount-show|--mount|-m)
            GET_DETAILS='true'
            MOUNT_SHOW='true'
            shift
            ;;
        --partition-show|--partition|-p)
            GET_DETAILS='true'
            PARTITION_SHOW='true'
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
    echo "GET_DETAILS: ${GET_DETAILS}"
    echo "MOUNT_SHOW: ${MOUNT_SHOW}"
    echo "PARTITION_SHOW: ${PARTITION_SHOW}"
    echo ""
fi

function shorten_path() {

    local CURRENT_PATH="$(pwd)"
    local USER_HOME="/home/${USER}"
    local ROOT_HOME="/root"

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

    # if trim removed leading ~ or / character, prepend ...
    if [[ "${CURRENT_PATH}" != "~"* ]] && \
       [[ "${CURRENT_PATH}" != "/"* ]]; then
        CURRENT_PATH=".../${CURRENT_PATH}"
    fi

    echo "${CURRENT_PATH}"
}

# set path length
if [ "${LENGTH}" == 'short' ]; then
    PWD_PATH="$(shorten_path)"
else
    PWD_PATH="$(pwd)"
fi

# get mount and partition details, if desired
if [ "${GET_DETAILS}" == 'true' ]; then 

    # use findmnt command, if available
    FINDMNT=$(command -v findmnt)
    if [ ! -z "${FINDMNT}" ]; then
        MOUNT_DETAILS=$(findmnt -T "$(pwd)" -f | tail -n1)
        MOUNT_POINT=$(echo "${MOUNT_DETAILS}" | awk '{ print $1 }')
        MOUNT_PARTITION=$(echo "${MOUNT_DETAILS}" | awk '{ print $2 }')
    fi
fi

# debug output B
if [ "${DEBUG}" == 'true' ]; then
    echo "[DEBUG B]"
    echo "PWD_PATH: ${PWD_PATH}"
    echo "MOUNT_DETAILS: ${MOUNT_DETAILS}"
    echo "MOUNT_POINT: ${MOUNT_POINT}"
    echo "MOUNT_PARTITION: ${MOUNT_PARTITION}"
    echo ""
fi

# stores full final output string
FINAL_OUTPUT="${PWD_PATH}"

# add mount point, if desired
if [ "${MOUNT_SHOW}" == 'true' ]; then
    FINAL_OUTPUT+=" MOUNT: ${MOUNT_POINT}"
fi

# add partition, if desired
if [ "${PARTITION_SHOW}" == 'true' ]; then
    FINAL_OUTPUT+=" PARTITION: ${MOUNT_PARTITION}"
fi

# if emojis are disabled
if [ "${EMOJI}" == 'false' ]; then 
    
    # output plain text
    printf "%-s" \
    "${FINAL_OUTPUT}"

else

    # characters/emojis
    # TODO:
    # - include emojis and colors in shared library file
    FOLDER='\U1F4C2'
    BRIEFCASE='\U1F4BC'
    PAGE='\U1F4C4'
    HOUSE='\U1F3E0'
    BUILDING='\U1F3E2'
    STORE='\U1F3EC'

    # output emoji string
    printf "%-2b %-s" \
    "${FOLDER}" "${FINAL_OUTPUT}" 
fi