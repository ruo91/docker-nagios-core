#
# Title: Dockerfile for Nagios Core
#
# Maintainer: Yongbok Kim (ruo91@yongbok.net)
#
# - Build
# docker build --rm -t nagios:core .
#
# - Run
# docker run -d --name="nagios-core" -h "nagios-core" -p 80:80 -p 443:443 nagios:core

# Base images
FROM     centos:centos6
MAINTAINER Yongbok Kim <ruo91@yongbok.net>

# WorkDIR
ENV SRC_DIR /opt
WORKDIR $SRC_DIR

# EPEL Repository
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm

# Nagios Core: Package
RUN yum install -y httpd php php-cli gcc glibc glibc-common gd gd-devel net-snmp openssl-devel wget unzip

# Nagios Core: User & Group
RUN useradd nagios && groupadd nagcmd \
 && usermod -a -G nagcmd nagios \
 && usermod -a -G nagcmd apache

# Nagios Core: Compile
# https://www.nagios.org/downloads/nagios-core/
ENV NAGIOS_CORE_VER 4.2.2
RUN curl -LO "https://assets.nagios.com/downloads/nagioscore/releases/nagios-$NAGIOS_CORE_VER.tar.gz" \
 && tar xzvf nagios-$NAGIOS_CORE_VER.tar.gz \
 && cd nagios-$NAGIOS_CORE_VER \
 && ./configure --with-command-group=nagcmd \
 && make all \
 && make install \
 && make install-init \
 && make install-config \
 && make install-commandmode \
 && make install-webconf

# Nagios Core: Plugin Compile
# https://nagios-plugins.org/downloads
ENV NAGIOS_CORE_PLUGIN_VER 2.1.3
ENV NAGIOS_CORE_USER  nagios
ENV NAGIOS_CORE_GROUP nagios
RUN curl -LO "http://www.nagios-plugins.org/download/nagios-plugins-$NAGIOS_CORE_PLUGIN_VER.tar.gz" \
 && tar xzvf nagios-plugins-$NAGIOS_CORE_PLUGIN_VER.tar.gz \
 && cd nagios-plugins-$NAGIOS_CORE_PLUGIN_VER \
 && ./configure --with-nagios-user=$NAGIOS_CORE_USER --with-nagios-group=$NAGIOS_CORE_GROUP --with-openssl \
 && make all && make install

# Nagios Web UI: Account
ENV NAGIOS_WEB_UI_USER nagiosadmin
ENV NAGIOS_WEB_UI_PASS rplinux
RUN htpasswd -cb /usr/local/nagios/etc/htpasswd.users $NAGIOS_WEB_UI_USER $NAGIOS_WEB_UI_PASS

# Supervisor
RUN yum install -y python-setuptools python-meld3 \
 && easy_install pip \
 && pip install --upgrade pip \
 && pip install supervisor \
 && mkdir /etc/supervisord.d
ADD conf/supervisord.conf /etc/supervisord.d/supervisord.conf

# Ports
EXPOSE 80 443

# Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.d/supervisord.conf"]
