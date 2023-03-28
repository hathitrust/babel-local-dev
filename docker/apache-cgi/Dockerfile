FROM hathitrust-babel-base

RUN apt-get -y install apache2 libapache2-mod-fcgid
RUN rm /etc/apache2/sites-available/*

RUN /usr/sbin/a2dismod 'mpm_*'
RUN a2enmod headers
RUN a2enmod env
RUN a2enmod mpm_prefork
RUN a2enmod rewrite
RUN a2enmod proxy
RUN a2enmod proxy_fcgi
RUN a2enmod proxy_http
RUN a2enmod cgi

COPY 000-default.conf /etc/apache2/sites-enabled
STOPSIGNAL SIGWINCH

COPY apache.sh /
RUN chmod +x /apache.sh
ENTRYPOINT ["/apache.sh"]
