## DB Backup Utility

This repo captures some of the steps taken to explore what would be needed to capture, encrypt, and store database backups outside of AWS/RDS.

### Capturing Backups

```
docker run -d -e "RCLONE_REFRESH_TOKEN=<your_google_refresh_token>" \
              -e "RCLONE_TEAM_DRIVE=<your_google_team_drive_id>" \
              -e "RCLONE_EXPIRY=<your_google_access_token_expiry>" \
              -e "RCLONE_ACCESS_TOKEN=<your_google_access_token>" \
              -e "PGHOST=<your_postgres_host>" \
              -e PGPORT=<your_postgres_port> \
              -e "PGUSER=<your_postgres_username>" \
              -e "PGDATABASE=<your_postgres_database>" \
              -e "PGPASSWORD=<your_postgres_password>" \
              rds_backup_gdrive:latest
```

### Encrypt the Backup

To encrypt the backup, we took the steps from (here)[https://www.imagescape.com/blog/2015/12/18/encrypted-postgres-backups/]

    # Generate a public private key pair
    openssl req -x509 -nodes -days 1000000 -newkey rsa:4096 -keyout backup_key.pem\
    -subj "/C=US/CN=www.theknot.com" \
    -out backup_key.pem.pub

    # Encrypt with public key  
    pg_dump my_database | bzip2 | openssl smime -encrypt -aes256 -binary \
    -outform DEM -out my_database.sql.bz2.ssl backup_key.pem.pub

    # Decrypt to a file using private key
    openssl smime -decrypt -in my_database.sql.bz2.ssl -binary \
    -inform DEM -inkey backup_key.pem -out my_database.sql.bz2

    # Decrypt to stdout using private key
    openssl smime -decrypt -in my_database.sql.bz2.ssl -binary \
    -inform DEM -inkey backup_key.pem | bzcat
