FROM python:3.9-slim-buster as Builder

ENV DISABLE_LOOP=false
ENV HEARTBEAT_TIMEOUT=60
ENV RDY_MESSAGE=false
ENV AWS=false

RUN set -xe; \
    apt-get update; \
    apt-get -y install git build-essential; \
    git clone https://github.com/gregzaal/Auto-Voice-Channels.git; \
    pip install -r /Auto-Voice-Channels/requirements.txt

FROM python:3.9-slim-buster

WORKDIR /Auto-Voice-Channels

ENV DISABLE_LOOP=false \
    HEARTBEAT_TIMEOUT=60 \
    RDY_MESSAGE=false \
    AWS=false

COPY --from=Builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=Builder /Auto-Voice-Channels /Auto-Voice-Channels
COPY startAVC.sh startAVC.sh

LABEL org.opencontainers.image.source https://github.com/xMikux/Miku-Collection

CMD [ "bash", "startAVC.sh" ]
