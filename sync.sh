#!/usr/bin/env bash

set -e

# config
OUTPUT_ROOT="${YAAP_DIR:-/mnt/sda/yaap}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$OUTPUT_ROOT"
cd "$OUTPUT_ROOT"

echo "YAAP Sync Script >> [1/2] initializing yaap seventeen in ${OUTPUT_ROOT}..."
repo init -u https://github.com/yaap/manifest.git -b seventeen --git-lfs

# device trees aren't part of the yaap manifest
mkdir -p .repo/local_manifests
cp "${SCRIPT_DIR}"/local_manifests/*.xml .repo/local_manifests/

echo "YAAP Sync Script >> [2/2] syncing..."
repo sync -j"$(nproc --all)" --no-tags --no-clone-bundle --current-branch

echo "YAAP Sync Script >> sync complete."
