#!/usr/bin/env sh

echo "Backup started."
ls -la /etc/secret-volume/
cat /etc/secret-volume/ssh-publickey

filename=backup_$(date +"%Y%m%d")
obsolete_filename=backup_$(date --date="1 day ago" +"%Y%m%d")

pg_dump \
  --no-password \
  -f /root/$filename

echo "Backup finished."

ls -la /root

echo "Copying backup to GDrive."

rclone copy /root/$filename remote:$PGDATABASE/
rm /root/$filename

echo "Backup copied to GDrive."
