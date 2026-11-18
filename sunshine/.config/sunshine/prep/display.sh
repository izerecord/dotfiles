#!/usr/bin/env bash
# Switch the KDE display layout between streaming and sitting at the desk.
#   display.sh stream   only the dummy plug, at the Moonlight client's resolution (Sunshine "do")
#   display.sh desk     every connected monitor, dummy off (Sunshine "undo", login, session.sh)
#   display.sh status   print stream, desk or mixed
#
# kscreen-doctor drops the WHOLE command (and still exits 0) if it names an output that
# isn't connected, e.g. a monitor that is switched off. So only outputs that kscreen-doctor
# currently reports are named, and the result is checked afterwards.
set -u
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

DUMMY=HDMI-A-1
FALLBACK_MODE=1920x1080@120
# Desk monitors left to right: name, mode, scale. Ones that aren't connected are skipped.
# Connected monitors not listed here are enabled to the right with their current mode.
DESK=(
    "DP-2 2560x1440@280 1.25"
    "DP-1 2560x1440@120 1.25"
)
# Client resolution for gamescope-auto; its presence means "streaming"
res="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/sunshine_client_res"

log() {
    echo "display.sh: $*" >&2
    logger -t sunshine-display -- "$*"
}

# Loads kscreen-doctor's state into $json (retries, KWin may still be starting at login)
read_outputs() {
    for _ in $(seq 20); do
        json=$(kscreen-doctor -j 2>/dev/null) &&
            jq -e '.outputs | length > 0' <<<"$json" >/dev/null 2>&1 && return 0
        sleep 1
    done
    log "kscreen-doctor does not respond"
    return 1
}

connected() { jq -e --arg n "$1" 'any(.outputs[]; .name == $n and .connected)' <<<"$json" >/dev/null; }

# Id of the mode on output $1 matching "WxH@R" (refresh rounded), empty if there is none
mode_id() {
    local w h r
    IFS='x@' read -r w h r <<<"$2"
    [[ $w =~ ^[0-9]+$ && $h =~ ^[0-9]+$ && $r =~ ^[0-9.]+$ ]] || return 0
    jq -r --arg n "$1" --argjson w "$w" --argjson h "$h" --argjson r "$r" '
        [.outputs[] | select(.name == $n) | .modes[]
         | select(.size.width == $w and .size.height == $h and (.refreshRate | round) == ($r | round))]
        | sort_by((.refreshRate - $r) | fabs) | first | .id // empty' <<<"$json"
}

# Dummy off and some monitor on. Which monitors are on is then left to you.
is_desk() {
    jq -e --arg d "$DUMMY" '[.outputs[] | select(.connected)] as $c
        | ($c | map(select(.name == $d)) | all(.enabled | not))
          and ($c | any(.name != $d and .enabled))' <<<"$json" >/dev/null
}

is_stream() {
    jq -e --arg d "$DUMMY" '[.outputs[] | select(.connected)] as $c
        | ($c | map(select(.name == $d)) | length == 1 and all(.enabled))
          and ($c | map(select(.name != $d)) | all(.enabled | not))' <<<"$json" >/dev/null
}

# Applies the kscreen-doctor arguments and waits until the predicate $1 holds
apply() {
    local check=$1
    shift
    log "kscreen-doctor $*"
    kscreen-doctor "$@" >/dev/null 2>&1
    for _ in $(seq 10); do
        sleep 0.5
        read_outputs && "$check" && return 0
    done
    log "layout is not $check after applying it"
    return 1
}

stream() {
    [ -n "${SUNSHINE_CLIENT_WIDTH:-}" ] &&
        echo "${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}x${SUNSHINE_CLIENT_FPS}" >"$res"

    # Failing here would abort the launch; streaming the desk monitor is the better fallback
    read_outputs || return 0
    if ! connected "$DUMMY"; then
        log "$DUMMY is not connected, streaming the desk monitors"
        return 0
    fi

    local mode=
    [ -n "${SUNSHINE_CLIENT_WIDTH:-}" ] &&
        mode=$(mode_id "$DUMMY" "${SUNSHINE_CLIENT_WIDTH}x${SUNSHINE_CLIENT_HEIGHT}@${SUNSHINE_CLIENT_FPS:-}")
    [ -n "$mode" ] || mode=$(mode_id "$DUMMY" "$FALLBACK_MODE")

    local args=("output.$DUMMY.enable")
    [ -n "$mode" ] && args+=("output.$DUMMY.mode.$mode")
    args+=("output.$DUMMY.scale.1" "output.$DUMMY.hdr.enable" "output.$DUMMY.wcg.enable" "output.$DUMMY.priority.1")
    local name
    for name in $(jq -r --arg d "$DUMMY" '.outputs[] | select(.connected and .enabled and .name != $d) | .name' <<<"$json"); do
        args+=("output.$name.disable")
    done
    apply is_stream "${args[@]}" || true
}

desk() {
    rm -f "$res"
    read_outputs || return 1
    is_desk && return 0

    local monitors
    mapfile -t monitors < <(jq -r --arg d "$DUMMY" '.outputs[] | select(.connected and .name != $d) | .name' <<<"$json")
    if [ ${#monitors[@]} -eq 0 ]; then
        log "no monitor besides $DUMMY is connected, leaving it on"
        return 1
    fi

    # Listed monitors first in their order, then any others
    local order=() entry name mode scale
    for entry in "${DESK[@]}"; do
        read -r name _ <<<"$entry"
        connected "$name" && order+=("$name")
    done
    for name in "${monitors[@]}"; do
        [[ " ${order[*]} " == *" $name "* ]] || order+=("$name")
    done

    local args=() x=0 prio=1 id width
    for name in "${order[@]}"; do
        mode= scale=
        for entry in "${DESK[@]}"; do
            [ "${entry%% *}" = "$name" ] && read -r _ mode scale <<<"$entry"
        done
        id=
        [ -n "$mode" ] && id=$(mode_id "$name" "$mode")
        [ -n "$mode" ] && [ -z "$id" ] && log "$name has no mode $mode, keeping its current one"
        if [ -n "$id" ]; then
            width=${mode%%x*}
        else
            width=$(jq -r --arg n "$name" '.outputs[] | select(.name == $n) | .size.width' <<<"$json")
        fi
        [ -n "$scale" ] || scale=$(jq -r --arg n "$name" '.outputs[] | select(.name == $n) | .scale' <<<"$json")

        args+=("output.$name.enable")
        [ -n "$id" ] && args+=("output.$name.mode.$id")
        args+=("output.$name.scale.$scale" "output.$name.position.$x,0" "output.$name.priority.$prio")
        x=$((x + $(awk -v w="$width" -v s="$scale" 'BEGIN { printf "%d", w / s + 0.5 }')))
        prio=$((prio + 1))
    done
    connected "$DUMMY" && args+=("output.$DUMMY.disable")
    apply is_desk "${args[@]}"
}

case "${1:-}" in
stream) stream ;;
desk) desk ;;
status)
    read_outputs || exit 1
    if is_stream; then echo stream; elif is_desk; then echo desk; else echo mixed; fi
    ;;
*)
    echo "usage: display.sh {stream|desk|status}" >&2
    exit 2
    ;;
esac
