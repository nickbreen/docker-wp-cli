#!/bin/bash

if [ $CRON_ENV_FILE ]
then
  (
    echo set -a
    for V in ${!CRON*}
    do
      echo "export ${V}='${!V}'"
    done
  ) > $CRON_ENV_FILE
fi

[ $TZ ] && echo $TZ > /etc/timezone

crontab -u ${CRON_OWNER:=$(whoami)} - <<< "$CRON_TAB"

exec "${@}"
