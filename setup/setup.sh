#!/bin/bash -eu

###############################################################
#####			VARIABLES
###############################################################

#	Constants
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
WHITE='\033[1;37m'
NC='\033[0m'



###############################################################
#####			FUNCTIONS
###############################################################

# function for outputting updates to CLI with color
# usuage: screen_output "<condition>" "<string>"
function screen_output () {
	local condition="$1"
	local output="$2"
		
	case $condition in
		"checking" )
			echo -e "${CYAN}CHECKING:${NC} $2"
			;;
		"update" )
			echo -e "${GREEN}UPDATE:${NC} $2"
			;;
		"error" )
			echo -e "${RED}ERROR:${NC} $2"
			;;
		"change" )
			echo -e "${YELLOW}CHANGED:${NC} $2"
			;;
		"status" )
			echo -e "${WHITE}STATUS:${NC} $2"
			;;
	esac
}

# function for appending files of a given text, if not present
# usuage: append_file "<filename>" "<string>"
function append_file () {
	local filename="$1"
	local text="$2"
	
	screen_output "checking" "\"$filename\" for needed changes"

	if grep -Fxq "$text" $filename 
		then
			screen_output "status" "no changes needed"
		else
			echo -e "$text" | sudo tee -a $filename > /dev/null
			screen_output "change" "\"$filename\" updated"
		fi
}



###############################################################
#####			CODE
###############################################################

# checks to ensure ran as root
if [[ $EUID != 0 ]]; then
    screen_output "error" "please run as root"
    exit 0
fi

# copy necessary files
for dir in ./files/*; do
	for file in $dir/*; do
		parent="$(basename "$file")"
		echo -e "$parent"
	done
done



