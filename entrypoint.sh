#!/usr/bin/env sh

sed -i "s~_RCLONE_REFRESH_TOKEN_~$RCLONE_REFRESH_TOKEN~g" /root/.config/rclone/rclone.conf
sed -i "s~_RCLONE_ACCESS_TOKEN_~$RCLONE_ACCESS_TOKEN~g" /root/.config/rclone/rclone.conf
sed -i "s~_RCLONE_TEAM_DRIVE_~$RCLONE_TEAM_DRIVE~g" /root/.config/rclone/rclone.conf
sed -i "s~_RCLONE_EXPIRY_~$RCLONE_EXPIRY~g" /root/.config/rclone/rclone.conf

exec "$@"
