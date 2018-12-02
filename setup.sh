#!/bin/bash

###################################
###	ENVIONRMENT VARIABLES	###
###################################

 DEPENDENCIES="\
    samba \
    samba-common-bin \
    "

 CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"



###################################
###	FUNCTIONS		###
###################################

 function sudoCheck () {
    if [[ $EUID != 0 ]]; then
       echo "Please run as root"
       exit 0
    fi
 }


 function log () {
    local now=$(date +%Y\-%m\-%d\ \ %H:%M)
    local today=$(date +%Y\-%m\-%d)
    local LOG_DIR="${CURRENT_DIR}/install\ logs"
    local LOG_FILE="${LOG_DIR}/${today}.install.log"

    if {{ ! -d ${LOG_DIR} }}; then
       mkdir -p ${LOG_DIR}
    fi

    echo "${now} -- $1" >> $LOGFILE
 }

 function installDependencies () {
    apt-get update
    apt-get upgrade
    apt-get install ${DEPENDENCIES}
 }





###################################
###	CODE			###
###################################

 sudoCheck

 installDependencies
