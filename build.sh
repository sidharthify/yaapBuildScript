#!/usr/bin/env bash

set -e

build_device() {
    local device="$1"      # panther or cheetah
    local variant="$2"     # user or userdebug
    local gapps="$3"       # vanilla or gapps

    . build/envsetup.sh
    lunch "yaap_${device}-${variant}"

    if [ "$gapps" = true ]; then
        YAAP_BUILDTYPE=Banshee TARGET_BUILD_GAPPS=true m yaap
    else
        YAAP_BUILDTYPE=Banshee m yaap
    fi
}

device=""
variant="user"
gapps=false

while [ $# -gt 0 ]; do
    case "$1" in
        panther|cheetah)
            device="$1"
            ;;
        --user)
            variant="user"
            ;;
        --userdebug)
            variant="userdebug"
            ;;
        --gapps)
            gapps=true
            ;;
        --vanilla)
            gapps=false
            ;;
        *)
            echo "unknown option: $1" >&2
            exit 1
            ;;
    esac
    shift
done

if [ -z "$device" ]; then
    echo "specify device: panther or cheetah" >&2
    exit 1
fi

build_device "$device" "$variant" "$gapps"
