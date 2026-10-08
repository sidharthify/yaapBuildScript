# YAAP Build Script
Both scripts work on the source tree in `$YAAP_DIR` (defaults to `/mnt/sda/yaap`).

### Syncing
`./sync.sh` initializes and syncs YAAP seventeen, along with the device, kernel and vendor trees in `local_manifests/`.

### Building
`./build.sh --build-all --user --upload` builds for both cheetah and panther, and uploads them.

`./build.sh codename --gapps --user` builds a single build normally.

`./build.sh cheetah --vanilla --userdebug --upload` builds a single build and uploads it.

Every build is logged to `$YAAP_LOG_DIR` (defaults to `$YAAP_DIR/logs`).

Builds use ninja instead of siso by default, since siso needs ~60GB of RAM. Set `SOONG_NINJA` to override it.

### Example
`YAAP_DIR=~/yaap ./sync.sh && YAAP_DIR=~/yaap ./build.sh panther --vanilla --userdebug`
