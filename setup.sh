#!/bin/bash

###################################
###	ENVIONRMENT VARIABLES	###
###################################

 DEPENDENCIES="\
	samba \
	samba-common-bin \
	"
	
 CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
 
 GREEN='\033[0;32m'
 RED='\033[0;31m'
 LGREEN='\033[1;32m'
 LRED='\033[1;31m'
 LCYAN='\033[1;36m'
 NC='\033[0m'

 

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

 function setupSambaShare () {
	local smbConf="/etc/samba/smb.conf"
	
	mkdir -m 1777 $1
		
	cp ${CURRENT_DIR}/files/smb.conf ${smbConf}
	chmod 644 ${smbConf}
	
	echo "[share]" 							>> ${smbConf}
	echo "   Comment = Tesla shared folder" >> ${smbConf} 
	echo "   Path = ${1}"					>> ${smbConf}
	echo "   Browseable = yes"				>> ${smbConf}
	echo "   Writeable = yes"				>> ${smbConf}
	echo "   only guest = no"				>> ${smbConf}
	echo "   create mask = 0777"			>> ${smbConf}
	echo "   directory mask = 0777"			>> ${smbConf}
	echo "   Public = yes"					>> ${smbConf}
	
	echo ""
	echo "Lets change your SMB password"
	smbpasswd -a pi 
	
	/etc/init.d/samba restart
 }

 function configMenu () {

	
	while [ "$finished" != "true" ]; do
		clear
		echo -e "${LCYAN}Program Parameters: ${NC}"
		echo -e ""
		echo -e "  ${GREEN}Samba Share Location:${NC}		${sambaShare:-/mnt/Tesla_Share}"
		echo -e "  ${GREEN}USB Mount:${NC}			${usbMount:-/mnt/USB_Mount}"
		echo -e ""
		
		prompt="Do you want to use above parameters?: "
		options=("Yes" "No")
		
		PS3="$prompt"
		select opt in "${options[@]}"; do
			case "$REPLY" in
				1 ) 
					finished="true"
					break
					;;
					
				2 ) 
					clear
					echo -e "${LCYAN}Program Parameters: ${NC}"
					echo -e ""
					
					prompt="Which parameter would you like to change?: "
					options=("Samba Share Location" "USB Mount")
					
					PS3="$prompt"
					select opt in "${options[@]}"; do
						case "$REPLY" in
							1 ) echo "Samba Share Location: "
								read sambaShare
								break
								;;
								
							2 ) echo "USB Mount: "
								read usbMount
								break
								;;
								
							* ) 
								echo -e "${RED}ERROR!: ${NC}Invalid input = $REPLY"
								echo -e "${RED}ERROR!: ${NC}Please try again (select 1..2)!"
								;;
							
						esac
					done
					break
					;;
					
				* ) 
					echo -e "${RED}ERROR!: ${NC}Invalid input = $REPLY"
					echo -e "${RED}ERROR!: ${NC}Please try again (select 1 or 2)!"
				;;
			esac
		done
	done

	echo ""
	prompt="Would you like to proceed with the installation?: "
	options=("Yes" "No")
	
	PS3="$prompt"
	select opt in "${options[@]}"; do
		case "$REPLY" in 
			1 ) 
				break
				;;
			
			2 ) 
				exit 0
				;;
				
			* ) 
				echo -e "${RED}ERROR!: ${NC}Invalid input = $REPLY"
				echo -e "${RED}ERROR!: ${NC}Please try again (select 1 or 2)!"
		esac
	done
 }

###################################
###	CODE			###
###################################

 sudoCheck

# installDependencies
 
 configMenu
 
# setupSambaShare "${sambaShare}"
