#!/bin/bash

exif_args=-all=

f_number=
shutter_speed=
iso_sensitivity=
exif_preset=

# parse command line arguments
while (( $# )); do
  case "$1" in
    -f|--fnumber) f_number="$2"; shift;;
    -s|--shutter) shutter_speed="$2"; shift;;
    -i|--iso) iso_sensitivity="$2"; shift;;
    --) shift; break;;
  esac && shift
done

# positional arguments
if (( $# < 2 )); then
  echo "Usage error: too few arguments." >&2
  exit
else
  exif_preset="$1"; shift
fi

# ask interactively
[ -z "$f_number" ] && read -p "FNumber? " f_number
[ -z "$shutter_speed" ] && read -p "ExposureTime? " shutter_speed
[ -z "$iso_sensitivity" ] && read -p "ISO? " iso_sensitivity

# print summary
[ -z "$f_number" ] || echo "FNumber=$f_number"
[ -z "$shutter_speed" ] || echo "ExposureTime=$shutter_speed"
[ -z "$iso_sensitivity" ] || echo "ISO=$iso_sensitivity"

# prepare EXIF command
[ -z "$f_number" ] || exif_args+=" -FNumber=$f_number"
[ -z "$shutter_speed" ] || exif_args+=" -ExposureTime=$shutter_speed"
[ -z "$iso_sensitivity" ] || exif_args+=" -ISO=$iso_sensitivity"

exiftool $exif_args -@ ${exif_preset}.exifargs "$@"


