FROM xogroup/postgresql-rclone:latest

USER root

ENV HOME_DIR /root
ADD dummy_script.sh $HOME_DIR
ADD pg_dump.sh $HOME_DIR
ADD create_backup /etc/cron.d/
ADD entrypoint.sh $HOME_DIR

RUN /usr/bin/crontab /etc/cron.d/create_backup \
 && chmod +x $HOME_DIR/dummy_script.sh \
 && chmod +x $HOME_DIR/pg_dump.sh \
 && chmod +x $HOME_DIR/entrypoint.sh \
 && rm -rf /var/cache/apk/*

ENTRYPOINT ["/root/entrypoint.sh"]
CMD ["/usr/sbin/crond", "-f", "-d", "0"]
