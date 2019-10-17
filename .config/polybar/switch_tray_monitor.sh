#!/bin/bash

CURRENT_DIR=$(dirname $0)
CONF_FILE="${CURRENT_DIR}/config"

MONITOR="${1}"


# Using the primary monitor if no are passed as param
if [ -z "${MONITOR}" ] ; then
  MONITOR=$(xrandr|awk '/primary/{print $1}')
fi

# Checking if monitor exists
if ! xrandr --listmonitors|egrep -q ".* +${MONITOR}$" ; then
  echo "Unrecognized monitor : ${MONITOR}"
  exit 1
fi


# Switch monitor in config file
TRAY_OPT="tray-position"
TRAY_ON="right"
TRAY_OFF=""

line_idx=1
in_bar_block=0
is_good_monitor=0

while read -r line ; do
  if [[ "${line}" =~ ^\[ ]] ; then
    if [[ ! "${line}" =~ ^\[bar ]] ; then
      in_bar_block=0
    else
      in_bar_block=1

      if [[ "${line}" =~ ^\[bar\/${MONITOR}\]$ ]] ; then
        is_good_monitor=1
      else
        is_good_monitor=0
      fi
    fi
  fi

  if [ ${in_bar_block} -eq 1 ] && [[ "${line}" =~ ^${TRAY_OPT} ]] ; then
    if [ ${is_good_monitor} -eq 1 ] ; then
      tray_value=${TRAY_ON}
    else
      tray_value=${TRAY_OFF}
    fi
    
    sed -ie "${line_idx}s/.*/${TRAY_OPT} = ${tray_value}/" ${CONF_FILE}
  fi

  line_idx=$(( line_idx + 1 ))
done < ${CONF_FILE}
