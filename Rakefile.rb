namespace :backup do
  task :membership do
    # Capture and encrypt backup
    `pg_dump -d $MEMBERSHIP_DB_NAME -U $MEMBERSHIP_DB_USERNAME -h $MEMBERSHIP_DB_HOST --no-password | bzip2 | openssl smime -encrypt -aes256 -binary -outform DEM -out membership_dump.sql.bz2.ssl ~/.ssh/backup_key.pem.pub`
  end
end
