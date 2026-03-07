#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOARD="nice_nano/nrf52840/zmk"
IMAGE="zmkfirmware/zmk-build-arm:stable"

docker run --rm -v "${SCRIPT_DIR}:/workdir" -w /workdir "$IMAGE" sh -c "
    set -eu
    west init -l config 2>/dev/null || true
    west update
    west zephyr-export
    for side in left right; do
        echo \"Building splinter_\${side}...\"
        west build -s zmk/app -b ${BOARD} -p -- \
            -DSHIELD=\"splinter_\${side}\" \
            -DZMK_CONFIG=/workdir/config
        cp -f build/zephyr/zmk.uf2 /workdir/splinter_\${side}-nice_nano.uf2
        echo \"Created splinter_\${side}-nice_nano.uf2\"
    done
"

echo "Done. Flash files:"
echo "  Left (central):     splinter_left-nice_nano.uf2"
echo "  Right (peripheral): splinter_right-nice_nano.uf2"
