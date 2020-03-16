FROM debian:buster-slim

LABEL maintainer="Bin Wu <binwu@google.com>"

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y gnupg1 ca-certificates \
    && apt install -y software-properties-common ufw \
    && apt install -y build-essential git tree \
    && apt install -y perl libperl-dev libgd3 libgd-dev libgeoip1 libgeoip-dev \
        geoip-bin libxml2 libxml2-dev libxslt1.1 libxslt1-dev wget libpcre3-dev libssl-dev

RUN mkdir /builder

VOLUME builder /builder

WORKDIR /builder

ADD ver /builder/ver
