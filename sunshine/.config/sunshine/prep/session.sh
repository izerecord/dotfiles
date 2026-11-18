#!/usr/bin/env bash
# End Sunshine sessions that were left running, so the desk monitors come back.
#   session.sh watch   follow Sunshine's log and end the session GRACE seconds after the
#                      client disconnected without coming back (Deck slept, Wi-Fi dropped, ...)
#   session.sh end     end it right now (bind to a key for when the screens are dark)
#
# Ending closes the app through Sunshine's API, so its undo commands run as usual.
# That needs ~/.config/sunshine/api.netrc (chmod 600), with the web UI login:
#   machine localhost login <user> password <password>
# Without it, only the displays are switched back.
set -u

GRACE=${GRACE:-180}
UNIT=app-dev.lizardbyte.app.Sunshine.service
NETRC="$HOME/.config/sunshine/api.netrc"
DISPLAY_SH="$HOME/.config/sunshine/prep/display.sh"

log() { echo "session.sh: $*" >&2; }

end_session() {
    if [ -r "$NETRC" ] &&
        curl -sfk --max-time 10 --netrc-file "$NETRC" -X POST \
            -H 'Origin: https://localhost:47990' -H 'Content-Type: application/json' \
            https://localhost:47990/api/apps/close | jq -e '.status == true' >/dev/null; then
        log "closed the running app"
        # Sunshine runs display.sh desk itself as the undo command; give it a head start
        sleep 3
    else
        log "could not close the app through Sunshine's API, only restoring the displays"
    fi
    "$DISPLAY_SH" desk
}

watch() {
    local deadline=0 line rc t
    while :; do
        if [ "$deadline" -gt 0 ]; then
            t=$((deadline - EPOCHSECONDS))
            if [ "$t" -le 0 ]; then
                log "client has been gone for ${GRACE}s, ending the session"
                end_session
                deadline=0
                continue
            fi
            read -r -t "$t" line
            rc=$?
            [ "$rc" -gt 128 ] && continue
        else
            read -r line
            rc=$?
        fi
        if [ "$rc" -ne 0 ]; then
            log "lost Sunshine's log"
            exit 1
        fi

        case $line in
        *"CLIENT DISCONNECTED"*)
            log "client disconnected, ending the session in ${GRACE}s unless it comes back"
            deadline=$((EPOCHSECONDS + GRACE))
            ;;
        *"CLIENT CONNECTED"* | *"Executing Undo Cmd"*)
            [ "$deadline" -gt 0 ] && log "client is back or the session ended, nothing to do"
            deadline=0
            ;;
        esac
    done < <(journalctl --user --follow --lines=0 --output=cat --unit="$UNIT")
}

case "${1:-}" in
watch) watch ;;
end) end_session ;;
*)
    echo "usage: session.sh {watch|end}" >&2
    exit 2
    ;;
esac
