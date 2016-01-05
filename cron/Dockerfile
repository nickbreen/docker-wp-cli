#FROM nickbreen/wp-cli:wp-api
FROM debian:stable

RUN apt-get update -q && apt-get install -qy cron && apt-get clean -q

COPY entrypoint.sh /

ENV CRON_TAB="" CRON_OWNER="" CRON_ENV_FILE=""

ENTRYPOINT [ "/entrypoint.sh" ]
# Start cron in the foreground, enable all logging
CMD [ "cron", "-f", "-L15" ]
