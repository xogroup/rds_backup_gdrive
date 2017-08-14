## DB Backup Utility

This repo captures some of the steps taken to explore what would be needed to capture, encrypt, and store database backups outside of AWS/RDS.

### Capturing Backups

To capture a backup for a postgres database, the pg_dump command is used:

    pg_dump -d <DB> -U <User> -h <Host> --no-password > out.sql

For Postgres, to avoid a password prompt, you must use a (pgpass)[https://www.postgresql.org/docs/9.4/static/libpq-pgpass.html] file, placed in the home directory with the following permissions:

    chmod 0600 ~/.pgpass

To caputre a backup for a MongoDB database, the mongodump command is used:

    mongodump --host <host> --port <port> --db <db> --username <user> --password <PW> --out <DIR for output>


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
 
### Storing the Backup

Storage was the biggest question so far. Something like Google Drive would be an easy option but might not be as secure. One option we explored was using (Rclone)[https://rclone.org/drive/] to sync to Google Drive:

    rclone copy dump.sql core_data_dump:data_dumps

Another option was to use a XO owned drive/server. One that was suggested was  \prdisilon\SqlReplData however we were not yet able to get moving data to that drive to work as expected.
