FROM restic/restic:0.12.1

RUN apk add --no-cache bash procps

COPY entrypoint.sh run.sh /

ENV CRON_SCHEDULE="0 3 * * *"

ENTRYPOINT [ "/entrypoint.sh" ]
