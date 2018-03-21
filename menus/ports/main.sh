#!/bin/bash
#
# [PlexGuide Menu]
#
# GitHub:   https://github.com/Admin9705/PlexGuide.com-The-Awesome-Plex-Server
# Author:   Admin9705
# URL:      https://plexguide.com
#
# PlexGuide Copyright (C) 2018 PlexGuide.com
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################
export NCURSES_NO_UTF8_ACS=1

file="/opt/appdata/plexguide/ports-no"
if [ -e "$file" ]
then
    status="Closed"
else
	status="Open"
fi

dialog --title "Very Important" --msgbox "\nYour Applications Port Status: $status\n\nYou must decide to keep your PORTS opened or closed.  Only close your PORTS if your REVERSE PROXY (subdomains) are working!" 0 0

############ Menu
HEIGHT=10
WIDTH=52
CHOICE_HEIGHT=4
BACKTITLE="Visit https://PlexGuide.com - Automations Made Simple"
TITLE="Make a Choice"
MENU="Application Ports are currently >>> $status"

OPTIONS=(A "Open Application Ports"
         B "Close Application Ports"
         Z "No Change")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        A)
			rm -r /opt/appdata/plexguide/ports-no 1>/dev/null 2>&1
 			ansible-playbook /opt/plexguide/ansible/config.yml --tags ports --skip-tags closed
 			dialog --title "Note" --msgbox "\nApplication Ports are Open (Worst for Security)" 0 0
            ;;
        B)
			touch /opt/appdata/plexguide/ports-no 1>/dev/null 2>&1	
			ansible-playbook /opt/plexguide/ansible/config.yml --tags ports --skip-tags open
			dialog --title "Note" --msgbox "\nApplication Ports are Closed (Best for Security)" 0 0
            ;;
        Z)
            clear
            exit 0 ;;
esac

dialog --title "Very Important" --msgbox "\nWe must rebuild each container occardingly! Please Be Patient!" 0 0
docker ps -a --format "{{.Names}}"  > /opt/appdata/plexguide/running
while read p; do
  echo $p > /tmp/program_var
  app=$( cat /tmp/program_var )
  dialog --infobox "Reconsturcting Your Container: $app" 3 50
  ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags "$app" --skip-tags webtools #1>/dev/null 2>&1
  #read -n 1 -s -r -p "Press any key to continue "
done </opt/appdata/plexguide/running

echo "$app: All Applications Ports Are $status" > /tmp/pushover
ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags pushover &>/dev/null &
