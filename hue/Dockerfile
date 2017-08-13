FROM centos:7

MAINTAINER Bindiego <bindiego@outlook.com>

USER root

# set jdk version
ENV JDK_FILE jdk-8u144-linux-x64.tar.gz

# download jdk
RUN mkdir -p /opt/tools
RUN cd \
  && curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" \
    http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/$JDK_FILE \
    > $JDK_FILE \
  && tar -xzf "$JDK_FILE" -C /opt/tools/ \
  && rm "$JDK_FILE" \
  && ln -s /opt/tools/jdk1.8.0_144 /opt/tools/jdk

# set maven version
ENV MAVEN_VERSION 3.5.0
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /opt/tools \
  && ln -s /opt/tools/apache-maven-$MAVEN_VERSION /opt/tools/mvn

# set path for java realated commands
ENV JAVA_HOME /opt/tools/jdk
ENV M2_HOME /opt/tools/mvn
ENV PATH $PATH:/opt/tools/jdk/bin:/opt/tools/mvn/bin

# since the user is root, simply set the local cache and you can mount extrals
VOLUME /root/.m2

# installing Hue
ENV HUE_VER 4.0.1
ENV HUE_HOME /opt/hue
ENV PATH $HUE_HOME/build/env/bin:$PATH

# Install needed packages
RUN yum update -y; \
    yum upgrade -y
RUN yum install -y \
    ant \
    asciidoc \
    cyrus-sasl-devel \
    cyrus-sasl-gssapi \
    cyrus-sasl-plain \
    gcc \
    gcc-c++ \
    krb5-devel \
    libffi-devel \
    libxml2-devel \
    libxslt-devel \
    make \
    maven \
    mysql \
    mysql-devel \
    openldap-devel \
    python-devel \
    python-pip \
    sqlite-devel \
    openssl-devel \
    gmp-devel \
    rsynch \
    snappy \
    snappy-devel \
    libtidy \
    libtidy-devel \
    openssl \
    postgresql \
    postgresql-devel \
    wget \
    epel-release
RUN yum install -y python-pip
RUN pip install --upgrade pip
RUN pip install setuptools psycopg2
RUN yum clean all

WORKDIR /opt/docker

# Cloudera Hue
RUN wget https://github.com/cloudera/hue/archive/release-$HUE_VER.tar.gz
RUN tar -xvf release-$HUE_VER.tar.gz
RUN mv hue-release-$HUE_VER $HUE_HOME

ADD supervisord.conf /etc/

RUN useradd -p $(echo "hue" | openssl passwd -1 -stdin) hue; \
    useradd -p $(echo "hdfs" | openssl passwd -1 -stdin) hdfs; \
    groupadd supergroup; \
    usermod -a -G supergroup hue; \
    usermod -a -G hdfs hue

RUN cd $HUE_HOME; \
    make apps

RUN rm -rf $HUE_HOME/desktop/conf.dist

ADD pseudo-distributed.ini $HUE_HOME/desktop/conf/
ADD supervisord-bootstrap.sh $HUE_HOME/build/env/bin/
ADD wait-for-it.sh $HUE_HOME/build/env/bin/

RUN chmod +x $HUE_HOME/build/env/bin/*.sh

VOLUME [ "/opt/hue/conf", "/opt/hue/logs" ]

EXPOSE 8000

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
