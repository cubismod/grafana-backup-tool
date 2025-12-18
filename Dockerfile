FROM alpine:latest@sha256:be171b562d67532ea8b3c9d1fc0904288818bb36fc8359f954a7b7f1f9130fb2

LABEL maintainer="ysde108@gmail.com"

ENV RESTORE=false
ENV ARCHIVE_FILE=""

RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk --no-cache add python3-dev libffi-dev gcc libc-dev py3-pip py3-cffi py3-cryptography ca-certificates bash py3-virtualenv

WORKDIR /opt/grafana-backup-tool
ADD . /opt/grafana-backup-tool

RUN chmod -R a+r /opt/grafana-backup-tool \
 && find /opt/grafana-backup-tool -type d -print0 | xargs -0 chmod a+rx

RUN virtualenv -p $(which python3) venv && ./venv/bin/pip3 --no-cache-dir install .

CMD sh -c 'export BACKUP_BIN=/opt/grafana-backup-tool/venv/bin/grafana-backup; if [ "$RESTORE" = true ]; then if [ ! -z "$AWS_S3_BUCKET_NAME" ] || [ ! -z "$AZURE_STORAGE_CONTAINER_NAME" ] || [ ! -z "$GCS_BUCKET_NAME" ]; then $BACKUP_BIN restore $ARCHIVE_FILE; else $BACKUP_BIN restore _OUTPUT_/$ARCHIVE_FILE; fi else $BACKUP_BIN save; fi'
