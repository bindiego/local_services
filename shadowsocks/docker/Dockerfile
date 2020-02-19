FROM centos:8

USER root

# Enable bbr
RUN yum install git vim wget -y
RUN yum install epel-release -y
RUN yum install gcc \
    gettext autoconf libtool automake make pcre-devel \
    asciidoc xmlto c-ares-devel libev-devel libsodium-devel \
    mbedtls-devel -y

# install shaodowsocks-libev
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git \
    && cd shadowsocks-libev \
    && git submodule update --init --recursive \
    && ./autogen.sh && ./configure --prefix=/usr && make && make install

RUN mkdir -p /etc/shadowsocks-libev

# simple-obfs
RUN yum install zlib-devel openssl-devel -y
RUN git clone https://github.com/shadowsocks/simple-obfs.git \
    && cd simple-obfs && git submodule update --init --recursive \
    && ./autogen.sh && ./configure && make && make install

# VOLUME /etc/shadowsocks-libev

RUN mkdir -p /etc/shadowsocks-libev
ADD config.json /etc/shadowsocks-libev/config.json

# ADD shadowsocks.service /etc/systemd/system/shadowsocks.service

# USER nobody

ENTRYPOINT ["/usr/bin/ss-server", "-c", "/etc/shadowsocks-libev/config.json", "-u"]
