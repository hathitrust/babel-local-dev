FROM hathitrust-babel-base

RUN apt-get -y install apache2 libapache2-mod-fcgid

RUN a2dissite '*'
RUN a2disconf other-vhosts-access-log
RUN a2dismod 'mpm_*'
RUN a2enmod headers \ 
            mpm_prefork \
            rewrite \
            proxy \
            proxy_fcgi \
            proxy_http \
            cgi

COPY 000-default.conf /etc/apache2/sites-enabled
STOPSIGNAL SIGWINCH

COPY apache.sh /
RUN chmod +x /apache.sh
ENTRYPOINT ["/apache.sh"]
