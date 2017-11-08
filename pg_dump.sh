#!/usr/bin/env sh

echo "Backup started."

filename=backup_$(date +"%Y%m%d")
obsolete_filename=backup_$(date --date="1 day ago" +"%Y%m%d")

pg_dump \
  --no-password | bzip2 | openssl smime -encrypt -aes256 -binary \
-outform DEM -out /root/$filename.sql.bz2.ssl rds_backup_key.pem.pub

rm /root/$filename
rclone copy /root/$filename.sql.bz2.ssl remote:$PGDATABASE/
rclone delete remote:$PGDATABASE/$obsolete_filename.sql.bz2.ssl

echo "Backup finished."
