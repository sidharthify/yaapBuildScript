#!/usr/bin/env bash

set -e

# config
OUTPUT_ROOT="/mnt/sda/yaap/"
RCLONE_REMOTE="gdrive"
RCLONE_ROOT_FOLDER="yaap-builds" 

handle_artifacts() {
    local device="$1"
    local build_type="$2" # vanilla or banshee
    local do_upload="$3"
    
    local type_orig="$build_type"
    local dest="${OUTPUT_ROOT}/${device}"
    local out="${OUTPUT_ROOT}/out/target/product/${device}"

    echo "YAAP Build Script >> [1/2] moving artifacts for ${device} (${build_type}) to ${dest}..."
    mkdir -p "$dest"

    if ls "$out"/*.zip 1> /dev/null 2>&1; then
        mv "$out"/*.zip "$dest/"
        mv "$out"/*.zip.sha256sum "$dest/"
        
        if [ -f "$out/${device}.json" ]; then
            mkdir -p "$dest/$build_type"
            mv "$out/${device}.json" "$dest/${build_type}"
        fi
        
        echo "YAAP Build Script >> artifacts moved locally."
        
        if [ "$do_upload" = true ]; then
            echo ">> [2/2] uploading to google drive (remote: ${RCLONE_REMOTE})..."
            
            # check if rclone is installed
            if ! command -v rclone &> /dev/null; then
                echo "!! error: rclone is not installed. skipping upload."
                return
            fi

            # mirror the structure of the local folder to the gdrive folder
            rclone copy "$dest" "${RCLONE_REMOTE}:${RCLONE_ROOT_FOLDER}/${device}/${build_type}" --progress
            
            echo "YAAP Build Script >> upload complete."
        fi
    else
        echo "YAAP Build Scrip >> !! error: no zip file found in ${out}."
        exit 1
    fi
}

perform_build() {
    local device="$1"
    local variant="$2"
    local is_gapps="$3"
    local do_upload="$4"

    echo "-----------------------------------------------------"
    echo "YAAP Build Script: starting build: ${device} ${variant} (gapps=${is_gapps})"
    echo "-----------------------------------------------------"

    . build/envsetup.sh
    lunch "yaap_${device}-${variant}"

    local build_type_name="Vanilla"
    if [ "$is_gapps" = true ]; then
        build_type_name="Banshee"
        YAAP_BUILDTYPE=Banshee TARGET_BUILD_GAPPS=true m yaap
    else
        YAAP_BUILDTYPE=Vanilla m yaap
    fi

    handle_artifacts "$device" "$build_type_name" "$do_upload"
}

# defaults
device=""
variant="user"
gapps=false
build_all=false
upload=false

while [ $# -gt 0 ]; do
    case "$1" in
        panther|cheetah) device="$1" ;;
        --user) variant="user" ;;
        --userdebug) variant="userdebug" ;;
        --gapps) gapps=true ;;
        --vanilla) gapps=false ;;
        --build-all) build_all=true ;;
        --upload) upload=true ;; # NEW FLAG
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

if [ "$build_all" = true ]; then
    echo ">> build-all sequence initiated..."
    # we pass "$upload" to every build call
    perform_build "panther" "$variant" false "$upload"
    perform_build "panther" "$variant" true "$upload"
    perform_build "cheetah" "$variant" false "$upload"
    perform_build "cheetah" "$variant" true "$upload"
else
    if [ -z "$device" ]; then
        echo "specify device: panther or cheetah" >&2; exit 1
    fi
    perform_build "$device" "$variant" "$gapps" "$upload"
fi
