FROM alpine:latest@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c

LABEL maintainer="ysde108@gmail.com"

ENV RESTORE=false
ENV ARCHIVE_FILE=""

ARG BACKUP_BIN=/opt/grafana-backup-tool/venv/bin/grafana-backup

RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && apk --no-cache add python3-dev libffi-dev gcc libc-dev py3-pip py3-cffi py3-cryptography ca-certificates bash py3-virtualenv

WORKDIR /opt/grafana-backup-tool
ADD . /opt/grafana-backup-tool

RUN chmod -R a+r /opt/grafana-backup-tool \
 && find /opt/grafana-backup-tool -type d -print0 | xargs -0 chmod a+rx

RUN virtualenv -p $(which python3) venv && ./venv/bin/pip3 --no-cache-dir install .

RUN chown -R 1337:1337 /opt/grafana-backup-tool
USER 1337
CMD sh -c 'if [ "$RESTORE" = true ]; then if [ ! -z "$AWS_S3_BUCKET_NAME" ] || [ ! -z "$AZURE_STORAGE_CONTAINER_NAME" ] || [ ! -z "$GCS_BUCKET_NAME" ]; then $BACKUP_BIN restore $ARCHIVE_FILE; else $BACKUP_BIN restore _OUTPUT_/$ARCHIVE_FILE; fi else $BACKUP_BIN save; fi'
