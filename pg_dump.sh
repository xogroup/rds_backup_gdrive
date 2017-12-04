#!/usr/bin/env sh

echo "Backup started."

filename=backup_$(date +"%Y%m%d")
obsolete_filename=backup_$(date --date="7 days ago" +"%Y%m%d")

pg_dump \
  --no-password | bzip2 | openssl smime -encrypt -aes256 -binary \
  -outform DEM -out /root/$filename.sql.bz2.ssl /etc/secret-volume/ssh-publickey

echo "Backup finished."

echo "Copying backup to GDrive."

rm /root/$filename
rclone copy /root/$filename.sql.bz2.ssl remote:$PGDATABASE/ -vv
rclone delete remote:$PGDATABASE/$obsolete_filename.sql.bz2.ssl -vv

echo "Backup copied to GDrive."
