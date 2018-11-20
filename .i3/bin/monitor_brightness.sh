#!/bin/sh

if [ $# -ne 1 ] ; then
	exit 1
fi

OUTPUT="eDP-1"
CURRENT=$(xrandr --verbose | grep "${OUTPUT}" -A10 | awk -F': ' '/Brightness: /{print $2}')
STEP="0.1"

if [ "${1}" = "-" ] ; then
	NEW=$(echo "scale=2 ; ${CURRENT}-${STEP}" | bc)
elif [ "${1}" = "+" ] && [ ! "${CURRENT}" = "1.0" ]; then
	NEW=$(echo "scale=2 ; ${CURRENT}+${STEP}" | bc)
fi

if [ -n "${NEW}" ] ; then
	xrandr --output ${OUTPUT} --brightness ${NEW}
fi
