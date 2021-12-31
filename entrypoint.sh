#!/bin/bash

function shutdown() {
    # Wait for backup to finish
    while [ -n "$(pgrep run.sh)" ]; do
        sleep .2
    done

    exit 0
}
trap shutdown SIGTERM SIGINT

# If no arguments are provided, enter passive mode.
if [ "$#" -eq 0 ]; then
    echo "Starting backup job with CRON schedule $CRON_SCHEDULE"

    env >/etc/environment
    echo "$CRON_SCHEDULE /run.sh" >/etc/crontabs/root

    crond -f -l 2 &
    wait ${!}
fi

exec restic "$@"
