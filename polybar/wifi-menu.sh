#!/usr/bin/env bash

nmcli dev wifi rescan

# Formatted list. sed made me >_<
LIST=$(nmcli --fields SSID,SECURITY,BARS dev wifi list | sed '/^--/d' | sed 1d | sed -E "s/ WPA*.?\S//g" | sed -E "s//     /g" | sed -E "s/(▂▄▆█|\*{4})/󰤨/g" | sed -E "s/(▂▄▆_|\*{3} )/󰤥/g" | sed -E "s/(▂▄__|\*{2}  )/󰤢/g" | sed -E "s/(▂___|\*{1}   )/󰤟/g" | sed -E "s/.*([󰤨󰤥󰤢󰤟])/  \1/g")

# get current connection status
CONSTATE=$(nmcli -fields WIFI g)
if [[ "$CONSTATE" =~ "enabled" ]]; then
	TOGGLE="Disable WiFi 󰤭"
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	TOGGLE="Enable WiFi 󱚾"
fi

# display menu; store user choice
CHENTRY=$(echo -e "$TOGGLE\n$LIST" | uniq -u | rofi -theme wifi -dmenu -selected-row 1)
# store selected SSID
CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')

if [ "$CHENTRY" = "" ]; then
    exit
elif [ "$CHENTRY" = "Enable WiFi 󱚾" ]; then
	nmcli radio wifi on
elif [ "$CHENTRY" = "Disable WiFi 󰤭" ]; then
	nmcli radio wifi off
else
    # get list of known connections
    KNOWNCON=$(nmcli connection show)
	
	# If the connection is already in use, then this will still be able to get the SSID
	if [ "$CHSSID" = "*" ]; then
		CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $3}')
	fi

	# Parses the list of preconfigured connections to see if it already contains the chosen SSID. This speeds up the connection process
	if [[ $(echo "$KNOWNCON" | grep "$CHSSID") = "$CHSSID" ]]; then
		nmcli con up "$CHSSID"
	else
		if [[ "$CHENTRY" =~ "" ]]; then
			WIFIPASS=$(echo " Press Enter if network is saved" | rofi -theme wifi -dmenu -p " WiFi Password: " -lines 1 )
		fi
		if nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
		then
			notify-send 'Connection successful'
		else
			notify-send 'Connection failed'
		fi
	fi
fi

