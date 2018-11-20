#!/bin/bash

XRANDR=$(which xrandr)

MONITORS=( $(${XRANDR} | awk '( $2 == "connected" ){ print $1 }') )
NUM_MONITORS=${#MONITORS[@]}

TITLES=()
COMMANDS=()
SEPARATORS=()
ACTIVE_MONITORS=()

ICON_SIMPLE_ARROW=""	# "=>"
ICON_DOUBLE_ARROW=""	# "<=>"

ICON_SIMPLE_SCREEN=""
ICON_CLONE_SCREENS=""
ICON_DUAL_SCREENS=""
ICON_TRIPLE_SCREENS=""


declare -i index=0


##
# Display
##
MAX_LENGTH_MONITOR_NAME=0
for i in ${!MONITORS[*]} ; do
	[ ${#MONITORS[i]} -gt ${MAX_LENGTH_MONITOR_NAME} ] && MAX_LENGTH_MONITOR_NAME=${#MONITORS[i]}
done


format_monitors_list() {
	local separator="${1}" ; shift
	local result=""

	for monitor in "$@" ; do
		gap=$(( ${MAX_LENGTH_MONITOR_NAME} - ${#monitor} + 1 ))
		blank=$(awk "BEGIN { OFS=\" \"; NF=${gap}; print }")

		[ -n "${result}" ] && result+=" ${separator}  "

		result+="${monitor}${blank}"
	done

	printf "%s\n" "${result}"
}



##
# Single screen
##
gen_xrandr_only() {
	local selected=$1
	local cmd="xrandr --output ${MONITORS[selected]} --auto"

	for i in ${!MONITORS[*]} ; do
		if [ ${selected} != ${i} ] ; then
			cmd="${cmd} --output ${MONITORS[i]} --off"
		fi
	done

	echo ${cmd}
}


SEPARATORS[index]="${ICON_SIMPLE_SCREEN} Simple"

for i in ${!MONITORS[*]} ; do
	TITLES[index]="${MONITORS[i]}"
	COMMANDS[index]=$(gen_xrandr_only $i)
	ACTIVE_MONITORS[index]="${MONITORS[i]}"
	index+=1
done



##
# Clone monitors
##
if [ "${NUM_MONITORS}" -ge 2 ] ; then
	SEPARATORS[index]="${ICON_CLONE_SCREENS} Clone"

	# 2 monitors
	for a in ${!MONITORS[*]} ; do
		for b in ${!MONITORS[*]} ; do
			if [ "${a}" != "${b}" ] ; then
				for i in ${!MONITORS[*]} ; do
					if [ "${a}" != "${i}" ] && [ "${b}" != "${i}" ] ; then
						MONITORS_TO_OFF="--output ${MONITORS[i]} --off"
					fi
				done

				TITLES[index]="$(format_monitors_list ${ICON_DOUBLE_ARROW} ${MONITORS[a]} ${MONITORS[b]})"
				COMMANDS[index]="xrandr --output ${MONITORS[a]} --auto --output ${MONITORS[b]} --auto --same-as ${MONITORS[a]} ${MONITORS_TO_OFF}"
				ACTIVE_MONITORS[index]="${MONITORS[a]} ${MONITORS[b]}"

				index+=1
			fi
		done
	done

	# 3 monitors
	if [ ${NUM_MONITORS} -ge 3 ] ; then
		TITLES[index]="$(format_monitors_list ${ICON_DOUBLE_ARROW} ${MONITORS[0]} ${MONITORS[1]} ${MONITORS[2]})"
		COMMANDS[index]="xrandr --output ${MONITORS[0]} --auto --output ${MONITORS[1]} --auto --same-as ${MONITORS[0]} --output ${MONITORS[2]} --auto --same-as ${MONITORS[0]}"
		ACTIVE_MONITORS[index]="${MONITORS[0]} ${MONITORS[1]} ${MONITORS[2]}"

		index+=1
	fi
fi



##
# Dual screen options
##
SEPARATORS[index]="${ICON_DUAL_SCREENS} Dual"

for a in ${!MONITORS[*]} ; do
	for b in ${!MONITORS[*]} ; do
		if [ "${a}" != "${b}" ] ; then
			for i in ${!MONITORS[*]} ; do
				if [ "${a}" != "${i}" ] && [ "${b}" != "${i}" ] ; then
					MONITORS_TO_OFF="--output ${MONITORS[i]} --off"
				fi
			done

			TITLES[index]="$(format_monitors_list ${ICON_SIMPLE_ARROW} ${MONITORS[a]} ${MONITORS[b]})"
			COMMANDS[index]="xrandr --output ${MONITORS[a]} --auto --output ${MONITORS[b]} --auto --right-of ${MONITORS[a]} ${MONITORS_TO_OFF}"
			ACTIVE_MONITORS[index]="${MONITORS[a]} ${MONITORS[b]}"

			index+=1
		fi
	done
done



##
# Triple screen options
##
SEPARATORS[index]="${ICON_TRIPLE_SCREENS} Triple"

for a in ${!MONITORS[*]} ; do
	for b in ${!MONITORS[*]} ; do
		for c in ${!MONITORS[*]} ; do
			if [ "${a}" != "${b}" ] && [ "${a}" != "${c}" ] && [ "${b}" != "${c}" ] ; then
				TITLES[index]="$(format_monitors_list ${ICON_SIMPLE_ARROW} ${MONITORS[a]} ${MONITORS[b]} ${MONITORS[c]})"
				COMMANDS[index]="xrandr --output ${MONITORS[b]} --auto --output ${MONITORS[a]} --auto --left-of ${MONITORS[b]} --output ${MONITORS[c]} --auto --right-of ${MONITORS[b]}"
				ACTIVE_MONITORS[index]="${MONITORS[a]} ${MONITORS[b]} ${MONITORS[c]}"

				index+=1
			fi
		done
	done
done



##
#  Generate entries, where first is key.
##
ENTRIES=""
SEPARATORS_INDEXES=""
SEPARATORS_NB=0

for i in ${!TITLES[*]} ; do
	if [ -n "${SEPARATORS[i]}" ] ; then
		[ -n "${ENTRIES}" ] && ENTRIES+="\n"
		ENTRIES+="\n${SEPARATORS[i]}"
		SEPARATORS_INDEXES="${SEPARATORS_INDEXES:+$SEPARATORS_INDEXES,}$((i + 1 + (SEPARATORS_NB * 2)))"
		SEPARATORS_NB=$((SEPARATORS_NB + 1))
	fi

	ENTRIES+="\n[${i}]  ${TITLES[i]}"
done



# Display layouts
if [ "${1}" = "--gui" ] ; then
	layout_id=$(echo -e "${ENTRIES}" | rofi -dmenu -i -p "Monitor Setup: " -a ${SEPARATORS_INDEXES} -no-custom | awk '{print $1}'| sed 's/\.\|\[\|\]\| //g')
else
	echo -e "${ENTRIES}"
fi


# Reading layout ID from stdin (pipe) or args
if [ -z "${layout_id}" ] ; then
	if [ -p /dev/stdin ] ; then
		layout_id=$(</dev/stdin)
	elif [ $# -ne 0 ] ; then
		layout_id="${1}"
	fi
fi


# Exiting with success if no layout id is provided
if [ -z "${layout_id}" ] ; then
	exit 0
fi


# Calling the command whished
if [[ "${layout_id}" =~ [0-9]+ ]] && [ -n "${COMMANDS[layout_id]}" ] ; then
	eval "${COMMANDS[layout_id]}"

	# Polybar
	${HOME}/.i3/bin/polybar.sh ${ACTIVE_MONITORS[layout_id]}
else
	echo "Layout ID not found : ${layout_id}"
	exit 1
fi
