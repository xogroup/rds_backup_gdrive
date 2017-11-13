#!/usr/bin/env sh

echo "Backup started."

filename=backup_$(date +"%Y%m%d")
obsolete_filename=backup_$(date --date="1 day ago" +"%Y%m%d")

pg_dump \
  --no-password \
  -f /root/$filename

echo "Backup finished."

ls -la /root
cat /root/.config/rclone/rclone.conf

echo "Copying backup to GDrive."

rclone copy /root/entrypoint.sh remote:$PGDATABASE/
# rm /root/$filename

echo "Backup copied to GDrive."
