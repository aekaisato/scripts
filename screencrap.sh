#!/usr/bin/env bash
## depman: maim xdotool grep 

SCREENSHOTS_FOLDER="$HOME/Pictures/Screenshots"

help () {
  echo "screencrap.sh"
  echo "screencrap.sh [command]"
  echo "commands available: help activewindow currentmonitor full select"
}

save () {
  mkdir -p $SCREENSHOTS_FOLDER
  cat - | save-to.sh -c -p "$SCREENSHOTS_FOLDER/$(date +'Screenshot_%Y%m%d_%H%M%S.png')" -m "image/png"
}

get-monitors () {
  xrandr | grep ' connected' | grep -o '[0-9]\+x[0-9]\++[0-9]\++[0-9]\+'
}

screenshot-current-monitor () {
  eval $(xdotool getmouselocation --shell)
  MONITORS=$(get-monitors)
  for M in $MONITORS
  do
    MSIZE=${M%+*+*}
    MPOS=+${M#*+}
    MSX=${MSIZE%x*}
    MSY=${MSIZE#*x}
    MPX=${MPOS%+*}
    MPX=${MPX#*+}
    MPY=${MPOS#*+*+}

    if (( $X >= $MPX )) && (( $X <= $(($MPX + $MSX)) )) && (( $Y >= $MPY )) && (( $Y <= $(($MPY + $MSY)) )); then
      maim -g "$M"
      break;
    fi
  done
}

if [[ "$1" == "activewindow" ]]; then
  maim -i $(xdotool getactivewindow) | save
elif [[ "$1" == "currentmonitor" ]]; then
  screenshot-current-monitor | save
elif [[ "$1" == "full" ]]; then
  maim | save
elif [[ "$1" == "select" ]]; then
  maim -s | save
else
  help
fi
