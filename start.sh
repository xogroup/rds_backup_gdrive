#!/usr/bin/env bash

/usr/bin/crontab /etc/cron.d/create_backup
cron -f
