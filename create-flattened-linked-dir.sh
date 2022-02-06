#!/usr/bin/env bash
## depman: coreutils man-pages

help () {
  echo "create-flattened-linked-dir.sh"
  echo "-- catchy title not included --"
  echo "creates a new directory out of symlinks to all files in source directory (recursive)"
  echo "create-flattened-linked-dir.sh src dest"
}

#for f in $(find $1 -type f -not -path '*/.*' -exec echo '{}' +); do
#  FNAME=$(pwd)/$f
#  # echo $FNAME
#  echo $f
#done

if [ -z "$2" ]; then
  help
  exit
fi

DEST=$(eval "echo $2") # somewhat dangerous, but oh well
mkdir -p "$DEST"
while IFS= read -r -d '' n; do
  F=$(printf '%q\n' "$n")
  FESC=$(eval "echo $F") # somewhat dangerous, but oh well
  FNAME=$(readlink -f "$FESC")
  ln -s "$FNAME" "$DEST/"
done < <(find "$1" -mindepth 1 -type f -not -path '*/,*' -print0)
