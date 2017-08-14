namespace :backup do
  task :membership do
    `pg_dump -d $MEMBERSHIP_DB_NAME -U $MEMBERSHIP_DB_USERNAME -h $MEMBERSHIP_DB_HOST --no-password > membership_dump.sql`
  end
end
