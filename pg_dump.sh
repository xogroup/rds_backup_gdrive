#!/usr/bin/env sh

echo "Backup started."

pg_dump \
  --no-password \
  -f /root/backup_file \
  -v \
  -Z 9

echo "Backup finished."
