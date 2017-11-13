#!/usr/bin/env sh

echo "Backup started."

filename=backup_$(date +"%Y%m%d")
obsolete_filename=backup_$(date --date="1 day ago" +"%Y%m%d")

pg_dump \
  --no-password | bzip2 | openssl smime -encrypt -aes256 -binary \
  -outform DEM -out /root/$filename.sql.bz2.ssl /etc/secret-volume/ssh-publickey

echo "Backup finished."

ls -la /root

rclone lsl remote:/ --config /root/.config/rclone/rclone.conf -v

echo "Copying backup to GDrive."

rclone copy /root/entrypoint.sh remote:$PGDATABASE/ --config /root/.config/rclone/rclone.conf -v
# rm /root/$filename

echo "Backup copied to GDrive."
