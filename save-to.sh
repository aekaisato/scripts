#!/usr/bin/env bash
## depman: coreutils xclip imagemagick file

help () {
  echo "save-to.sh"
  echo "save-to.sh [-c / --clipboard] [-p / path \$path] [-m mimetype]"
  exit 0
}

PARAMS="" # https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php
while (( "$#" )); do
  case "$1" in
    -c|--clipboard)
      CLIPBOARD=0
      shift
      ;;
    -p|--path)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        FILE=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        help
        exit 1
      fi
      ;;
    -m|--mime)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        MMIME=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        help
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      help
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

CONTENT64=$(cat - | base64 -w 0)
CONTENTTEMP=$(echo $CONTENT64 | base64 --decode)
MIME=$(echo $CONTENTTEMP | file -b --mime-type -)
if [ ! -z "$MMIME" ]; then
  MIME="$MMIME"
fi
TYPE=${MIME#*/}
echo "$MIME"
if [ ! -z "$CLIPBOARD" ]; then
  echo "saving to clipboard..."
  saveclip () {
    cat - | xclip -selection clipboard -t $1
  }
  if [[ $MIME == *"image"* ]] && [[ $MIME != "image/png" ]]; then
    echo "input is an image -- converting to png..."
    echo $CONTENT64 | base64 --decode | convert $TYPE:- png:- | saveclip 'image/png'
  else
    echo $CONTENT64 | base64 --decode | saveclip $MIME
  fi
fi
if [ ! -z "$FILE" ]; then
  echo "saving to ""$FILE""..."
  (echo $CONTENT64 | base64 --decode) > "$FILE"
fi
