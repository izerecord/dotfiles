#!/usr/bin/env bash
# Open/close Big Picture for the Moonlight session, but leave it alone while a game runs.
#   bigpicture.sh open    open Big Picture, unless a game is running (it would cover the game)
#   bigpicture.sh close   close Big Picture, unless a game is running
#
# Big Picture stays open under a running game between sessions, so reconnecting
# shows the game instead of a fresh Big Picture window on top of it.
set -u

log() {
    echo "bigpicture.sh: $*" >&2
    logger -t sunshine-display -- "$*"
}

# Steam starts every game through its reaper: "reaper SteamLaunch AppId=<id> -- ..."
game_running() { pgrep -f '/reaper SteamLaunch AppId=[0-9]+' >/dev/null; }

case "${1:-}" in
open | close)
    if game_running; then
        log "a game is running, leaving Big Picture as it is ($1)"
        exit 0
    fi
    exec setsid steam "steam://$1/bigpicture"
    ;;
*)
    echo "usage: bigpicture.sh {open|close}" >&2
    exit 2
    ;;
esac
