#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch polybar on active ACTIVE_MONITORS
ACTIVE_MONITORS=$(xrandr --listactivemonitors|awk '/ *[0-9]+:/{print $NF}')

for monitor in ${ACTIVE_MONITORS} ; do
  polybar ${monitor} &
done
