#!/bin/sh

set -u # Treat unset variables as an error.

trap "exit" TERM QUIT INT
trap "kill_spotify" EXIT

log() {
    echo "[spotifysupervisor] $*"
}

getpid_spotify() {
    PID=UNSET
    if [ -f /config/spotify.pid ]; then
        PID="$(cat /config/spotify.pid)"
        # Make sure the saved PID is still running and is associated to
        # spotify.
        if [ ! -f /proc/$PID/cmdline ] || ! cat /proc/$PID/cmdline | grep -qw "spotify"; then
            PID=UNSET
        fi
    fi
    if [ "$PID" = "UNSET" ]; then
        PID="$(ps -o pid,args | grep -w "spotify" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    fi
    echo "${PID:-UNSET}"
}

is_spotify_running() {
    [ "$(getpid_spotify)" != "UNSET" ]
}

start_spotify() {
        spotify > /config/logs/output.log 2>&1 &
}

kill_spotify() {
    PID="$(getpid_spotify)"
    if [ "$PID" != "UNSET" ]; then
        log "Terminating Spotify..."
        kill $PID
        wait $PID
    fi
}

if ! is_spotify_running; then
    log "Spotify not started yet.  Proceeding..."
    start_spotify
fi

SPOTIFY_NOT_RUNNING=0
while [ "$SPOTIFY_NOT_RUNNING" -lt 60 ]
do
    if is_spotify_running; then
        SPOTIFY_NOT_RUNNING=0
    else
        SPOTIFY_NOT_RUNNING="$(expr $SPOTIFY_NOT_RUNNING + 1)"
    fi
    sleep 1
done

log "Spotify no longer running.  Exiting..."
