#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch polybar on active monitors
MONITORS=$(xrandr --listactivemonitors|awk '/ *[0-9]+:/{print $NF}')
ALL_BARS=$(awk -F'/' '/^\[bar/{print $NF}' ~/.config/polybar/config|sed 's/]//g')

for bar in ${ALL_BARS} ; do
  for monitor in ${MONITORS} ; do
    #echo "$bar --> $monitor"
    #[[ "${bar}" =~ "${monitor}" ]] && polybar -r ${bar}
    if [[ "${bar}" =~ "${monitor}" ]] ; then
      polybar -r ${bar} &
    fi
  done
done
