#!/bin/bash
# Install the reviewed notification fork, never the upstream release overlay.
set -euo pipefail
UPDATE_DIR=$(mktemp -d /tmp/appreciate-update.XXXXXX)
export UPDATE_DIR
# Build from a clean checkout so uncommitted local edits are never overwritten.
git clone --quiet --depth 1 --branch master https://github.com/immanuelk1m/Appreciate.git "$UPDATE_DIR/source"
CI=1 bash "$UPDATE_DIR/source/macos/build.sh"
bash "$UPDATE_DIR/source/local-checks/notifications.sh"
APP=/Applications/Appreciate.app
BUILT_APP="$UPDATE_DIR/source/macos/build/Appreciate.app"
codesign --force --deep --sign - "$BUILT_APP"
codesign --verify --deep --strict "$BUILT_APP"
if [ -d "$APP" ]; then ditto "$APP" "$UPDATE_DIR/original.app"; fi
if defaults export ca.srid.appreciate "$UPDATE_DIR/preferences.plist" 2>/dev/null; then
    :
else
    rm -f "$UPDATE_DIR/preferences.plist"
fi
rollback() {
    echo "Installation failed; restoring backup from $UPDATE_DIR"
    trap - ERR
    pkill -x Appreciate || true
    rm -rf "$APP"
    if [ -d "$UPDATE_DIR/original.app" ]; then ditto "$UPDATE_DIR/original.app" "$APP"; fi
    if [ -f "$UPDATE_DIR/preferences.plist" ]; then defaults import ca.srid.appreciate "$UPDATE_DIR/preferences.plist"; fi
    if [ -d "$APP" ]; then open "$APP"; fi
    exit 1
}
trap rollback ERR
pkill -x Appreciate || true
sleep 1
rm -rf "$APP"
ditto "$BUILT_APP" "$APP"
open "$APP"
sleep 2
pgrep -x Appreciate >/dev/null
python3 - <<'PY'
import os, plistlib, subprocess
from pathlib import Path
backup = Path(os.environ['UPDATE_DIR']) / 'preferences.plist'
if backup.exists():
    before = plistlib.loads(backup.read_bytes())
    after = plistlib.loads(subprocess.check_output(['defaults', 'export', 'ca.srid.appreciate', '-']))
    for key in ('packs', 'selectedPack', 'displayDurationSeconds', 'minIntervalMinutes', 'maxIntervalMinutes', 'launchAtLogin', 'isEnabled'):
        assert before.get(key) == after.get(key), f'Preference changed: {key}'
    print('PASS: saved packs and all reminder settings preserved')
PY
trap - ERR
printf 'Installed notification fork commit %s. Backup: %s\n' "$(git -C "$UPDATE_DIR/source" rev-parse --short HEAD)" "$UPDATE_DIR"
