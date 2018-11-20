#!/bin/bash

is_running() {
	matches=$(pgrep -f "${1}" -c 2> /dev/null||true)

	if [ "${matches}" -eq 0 ] ; then
		return 1
	fi

	return 0
}


# Supervisord
supervisord -c ~/.supervisord.conf &>/dev/null &

# Wallpaper
nitrogen --restore

# Mouse sensibility
xset m 10/5 1

# Clipboard
is_running clipit || {
	exec clipit &>/dev/null &
}

# Keyring
is_running gnome-keyring-daemon || {
	exec gnome-keyring-daemon &>/dev/null &
}

# Scratchpad
is_running "urxvt -name urxvt_scratchpad" || {
	exec urxvt -name urxvt_scratchpad -geometry 300x80 -e tmux &>/dev/null &
}

# Wicd
is_running wicd-client || {
	exec wicd-gtk -t &>/dev/null &
}

# Flameshot
is_running flameshot || {
	exec flameshot &>/dev/null &
}

# SeaDrive
is_running seadrive-gui || {
	exec seadrive-gui &>/dev/null &
}

# Compton
is_running compton || {
	exec compton &>/dev/null &
}

# Auto lock Screen
is_running xautolock || {
	exec xautolock -detectsleep -time 5 \
		-locker "betterlockscreen -l dim" \
		-notify 30 \
		-notifier "notify-send -u critical -t 30000 'Alert' 'Locking screen in 30 seconds'" \
		&>/dev/null &
}
