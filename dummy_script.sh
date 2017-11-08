#!/usr/bin/env sh

filename=backup_$(date +"%Y%m%d%H%M")
obsolete_filename=backup_$(date --date="1 minute ago" +"%Y%m%d%H%M")

psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select * from sessions limit 10" -o /root/$filename

rclone copy /root/$filename remote:$PGDATABASE/
rclone delete remote:$PGDATABASE/$obsolete_filename

#
# filename=backup_$(date +"%Y%m%d")
# obsolete_filename=backup_$(date --date="7 days ago" +"%Y%m%d")
#
# psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -c "select * from sessions limit 10" -o /root/$filename
# rclone copy /root/$filename remote:$PGDATABASE/
# rclone delete remote:$PGDATABASE/$obsolete_filename
