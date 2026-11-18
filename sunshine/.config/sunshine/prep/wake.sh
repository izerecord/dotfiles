#!/usr/bin/env bash
# Wake the displays as soon as a Moonlight client talks to Sunshine.
#
# Sunshine probes capture and encoder on launch BEFORE it runs any prep command. With KDE's
# display power saving every output is off (DPMS), KMS capture finds no monitor and the
# launch fails with "Failed to initialize video capture/encoding", so display.sh never runs.
# Moonlight polls the host (ports 47984/47989) while it shows the computer list, so waking
# the displays on that traffic puts them back on before an app is picked.
#
# While Moonlight is open on a client, the displays therefore don't stay off.
set -u

INTERVAL=${INTERVAL:-1}   # seconds between checks
COOLDOWN=${COOLDOWN:-10}  # seconds to wait after a wake before trying again

log() {
    echo "wake.sh: $*" >&2
    logger -t sunshine-display -- "$*"
}

# A client talked to Sunshine's HTTP(S) ports recently. Its polls are short requests, but
# Sunshine closes them, so each leaves a TIME-WAIT socket for ~60s that a 1s check sees.
client_polling() {
    ss -tanH '( sport = :47984 or sport = :47989 )' |
        awk '$1 == "ESTAB" || $1 == "TIME-WAIT" {print $5}' |
        grep -qvE '^(127\.|\[::1\]|\[::ffff:127\.)'
}

# Any connected output that is powered on
display_on() {
    local s
    for s in /sys/class/drm/card*-*/; do
        [ "$(cat "$s/status" 2>/dev/null)" = connected ] &&
            [ "$(cat "$s/dpms" 2>/dev/null)" = On ] && return 0
    done
    return 1
}

while :; do
    if client_polling && ! display_on; then
        log "a Moonlight client is polling and all displays are off, waking them"
        kscreen-doctor --dpms on >/dev/null 2>&1 || log "kscreen-doctor --dpms on failed"
        sleep "$COOLDOWN"
    fi
    sleep "$INTERVAL"
done
