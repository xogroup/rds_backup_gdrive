FROM xogroup/postgresql-rclone:latest

USER root

ENV HOME_DIR /root
ADD pg_dump.sh $HOME_DIR
ADD entrypoint.sh $HOME_DIR
ADD rds_backup_key.pem.pub $HOME_DIR

RUN apk update \
 && apk add --no-cache \
    openssl \
    bzip2 \
 && chmod +x $HOME_DIR/pg_dump.sh \
 && chmod +x $HOME_DIR/entrypoint.sh \
 && chmod +x $HOME_DIR/rds_backup_key.pem.pub \
 && rm -rf /var/cache/apk/*

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["pg_dump.sh"]
