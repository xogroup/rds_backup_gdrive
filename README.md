## RDB Backup to Google Team Drive

This repo contains the Docker image that will capture a RDS Postgres Database backup and upload it to a Google Team Drive.

### Installing and configuring [rclone](https://rclone.org/drive/)

```
$ cd ~/tmp
$ wget -q https://downloads.rclone.org/rclone-v1.38-linux-arm64.zip
$ unzip ~/tmp/rclone-$RCLONE_VERSION-linux-arm64.zip
$ cp ~/tmp/rclone-v1.38-linux-arm64/rclone /usr/local/bin
$ rclone config
```

**Please only select `RDS Backups` Team Drive.** All XO backups should live there.

When the configuration process is finished, a file will be generated in this location: `~/.config/rclone/rclone.conf`
The file will look like this:

```
[remote]
type = drive
client_id =
client_secret =
token = {"access_token":"<RCLONE_REFRESH_TOKEN>","token_type":"Bearer","refresh_token":"<RCLONE_ACCESS_TOKEN>","expiry":"<RCLONE_EXPIRY>"}
team_drive = <RCLONE_TEAM_DRIVE>
```

Extract the following environment variables from that file:

- RCLONE_REFRESH_TOKEN
- RCLONE_ACCESS_TOKEN
- RCLONE_EXPIRY
- RCLONE_TEAM_DRIVE

These are some of the environment variables you will need to pass to the Docker run command.

### Building the image

```
$ docker build -t rds_backup_gdrive:latest .
```

### Running the container locally

The container needs to be run in the background to capture and replace rclone environment variables into the `rclone.conf` file.

```
$ docker run -d -e "RCLONE_REFRESH_TOKEN=<RCLONE_REFRESH_TOKEN>" \
              -e "RCLONE_TEAM_DRIVE=<RCLONE_TEAM_DRIVE>" \
              -e "RCLONE_EXPIRY=<RCLONE_EXPIRY>" \
              -e "RCLONE_ACCESS_TOKEN=<RCLONE_ACCESS_TOKEN>" \
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
