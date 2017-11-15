## RDS Backup to Google Team Drive

This repo contains the Docker image that will capture a RDS Postgres Database backup in production and upload it to a Google Team Drive.

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
$ docker run -it --rm \
  -e "RCLONE_REFRESH_TOKEN=<RCLONE_REFRESH_TOKEN>" \
  -e "RCLONE_TEAM_DRIVE=<RCLONE_TEAM_DRIVE>" \
  -e "RCLONE_EXPIRY=<RCLONE_EXPIRY>" \
  -e "RCLONE_ACCESS_TOKEN=<RCLONE_ACCESS_TOKEN>" \
  -e "PGHOST=<your_postgres_host>" \
  -e PGPORT=<your_postgres_port> \
  -e "PGUSER=<your_postgres_username>" \
  -e "PGDATABASE=<your_postgres_database>" \
  -e "PGPASSWORD=<your_postgres_password>" \
  xogroup/rds_backup_gdrive:latest
```

### Adding a scheduled job on Kubernetes

1. Create a yaml file with all of your secrets **base 64 encoded**.
    - Create a copy of [secrets_template.yaml file](secrets_template.yaml)
    - Replace `<k8_db_backup_secret_name>` with desired name for collection of secrets on k8, like `users-backup-secrets`
    - Replace the values for each key under data with the base 64 encoded version of the value.
      - E.g. If the value for `rclone_refresh_token` is `abcdefg`, the value would be `YWJjZGVmZw==`.
      - To get the base 64 encoded version, run `echo -n "abcdefg" | base64`.
2. Use that secrets file to create a new secret in Kubernetes in your namespace
    - `kubectl create -f <name_of_secrets_file>.yaml --namespace <your_team_namespace>`
    - You should see `secret "<k8_db_backup_secret_name>" created` in the console if it was created successfully
3. Create a cronjob from `cronjob-template.yaml`
    - Create a copy of [cronjob-template.yaml](cronjob-template.yaml)
    - Edit `<name_of_cronjob_and_container>` on line 4 and line 16 to a name you would like for your cronjob and container
    - Edit `spec.schedule: "* 3 * * *"` on line 6 to whenever you would like your job to be run, or leave the default that will run at 3 AM every day
    - Replace all instances of `<k8_db_backup_secret_name>` with the secret created from step 2
    - Run `kubectl create -f <name_of_cronjob_file>.yaml --namespace <your_team_namespace>` to create the cronjob
    - See [users-rds-backup-cronjob.yaml](users-rds-backup-cronjob.yaml) for a working example

### Getting logs from pod started by cronjob

This command will watch for jobs that get spun up. It works most effectively when run just before your job is scheduled to kick off.
```
$ kubectl get jobs --watch
```
The output should look something like:
```
NAME                               DESIRED   SUCCESSFUL   AGE
users-rds-backup-1510701770   1         0            0s
```
Take the name of the job and replace `<job_name>` in `pod` definition.
E.g. `<job_name>` => `users-rds-backup-1510701770`
```
$ pod=$(kubectl get pods -a --selector=job-name=<job_name> --output=jsonpath={.items..metadata.name})
$ kubectl describe pods/$pod
$ kubectl logs $pod
```
You can also attach `-f` to `kubectl logs $pod` to watch the logs.

### Getting logs from pod started by cronjob

This command will watch for jobs that get spun up. It works most effectively when run just before your job is scheduled to kick off.
```
$ kubectl get jobs --watch
```
The output should look something like:
```
NAME                               DESIRED   SUCCESSFUL   AGE
users-rds-backup-1510701770   1         0            0s
```
Take the name of the job and replace `<job_name>` in `pod` definition.
E.g. `<job_name>` => `users-rds-backup-1510701770`
```
$ pod=$(kubectl get pods -a --selector=job-name=<job_name> --output=jsonpath={.items..metadata.name})
$ kubectl describe pods/$pod
$ kubectl logs $pod
```
You can also attach `-f` to `kubectl logs $pod` to watch the logs.

### Decrypting the Backup

The private key `rds_backup_key.pem` can be found in Passwordstate.

```
$ openssl smime -decrypt -in <db_backup_filename>.sql.bz2.ssl -binary \
  -inform DEM -inkey rds_backup_key.pem -out <db_backup_filename>.sql.bz2
```

### Unzipping Decrypted Backup

```
$ bzip2 -dk <db_backup_filename>.sql.bz2
```
