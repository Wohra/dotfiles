#!/bin/bash

BIN_DIR=$(dirname $0)

is_running() {
	matches=$(pgrep -f "${1}" -c 2> /dev/null||true)

	if [ "${matches}" -eq 0 ] ; then
		return 1
	fi

	return 0
}


# Wallpaper
nitrogen --restore

# Mouse sensibility
xset m 10/5 1

# Clipboard
is_running clipit || {
	exec clipit &>/dev/null &
}

# Daemon notification
# --> lancé par monit
#launch $HOME/install/dunst-1.0.0/dunst

# Compton
is_running '^compton$' || {
	#exec compton -min &>/dev/null &
	exec compton &>/dev/null &
}

# Pulse
#is_running pulseaudio || {
#	exec pulseaudio --sytem=false &>/dev/null &
#}

# Network Manager applet
is_running nm-applet || {
	exec nm-applet -t &>/dev/null &
}

# Network Manager applet
is_running flameshot || {
	exec flameshot &>/dev/null &
}

# Auto lock Screen
##is_running xautolock || {
	##exec xautolock -detectsleep -time 5 \
		##-locker "${BIN_DIR}/lockscreen.sh -l" \
		##-notify 30 \
		##-notifier "notify-send -u critical -t 30000 'Alert' 'Locking screen in 30 seconds'" \
		##&>/dev/null &
##}
