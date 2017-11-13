#!/usr/bin/env sh

echo "Backup started."

filename=backup_$(date +"%Y%m%d")
obsolete_filename=backup_$(date --date="1 day ago" +"%Y%m%d")

pg_dump \
  --no-password | bzip2 | openssl smime -encrypt -aes256 -binary \
  -outform DEM -out /root/$filename.sql.bz2.ssl /root/rds_backup_key.pem.pub

echo "Backup finished."

ls -la /root
ls -la /root/.config/rclone
cat /root/.config/rclone/rclone.conf

echo "Copying backup to GDrive."

which rclone

/usr/bin/rclone lsl remote:/ -vv

/usr/bin/rclone copy /root/entrypoint.sh remote:$PGDATABASE/ -vv
# rm /root/$filename

echo "Backup copied to GDrive."
