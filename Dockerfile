FROM debian:bullseye

RUN sed -i 's/main.*/main contrib non-free/' /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
  perl \
  libxerces-c3.2 \
  libxerces-c3-dev \
  sqlite3 \
  file \
  libalgorithm-diff-xs-perl \
  libany-moose-perl \
  libapache-session-perl \
  libarchive-zip-perl \
  libclass-accessor-perl \
  libclass-c3-perl \
  libclass-data-accessor-perl \
  libclass-data-inheritable-perl \
  libclass-errorhandler-perl \
  libclass-load-perl \
  libcommon-sense-perl \
  libcompress-raw-zlib-perl \
  libconfig-auto-perl \
  libconfig-inifiles-perl \
  libconfig-tiny-perl \
  libcrypt-openssl-random-perl \
  libcrypt-openssl-rsa-perl \
  libcrypt-ssleay-perl \
  libdata-optlist-perl \
  libdata-page-perl \
  libdate-calc-perl \
  libdate-manip-perl \
  libdbd-mock-perl \
  libdbd-mysql-perl \
  libdbd-sqlite3-perl \
  libdevel-globaldestruction-perl \
  libdigest-sha-perl \
  libemail-date-format-perl \
  libencode-locale-perl \
  liberror-perl \
  libeval-closure-perl \
  libexcel-writer-xlsx-perl \
  libfcgi-perl \
  libfcgi-procmanager-perl \
  libfile-listing-perl \
  libfile-slurp-perl \
  libfilesys-df-perl \
  libgeo-ip-perl \
  libhtml-parser-perl \
  libhtml-tree-perl \
  libhttp-browserdetect-perl \
  libhttp-cookies-perl \
  libhttp-daemon-perl \
  libhttp-date-perl \
  libhttp-dav-perl \
  libhttp-message-perl \
  libhttp-negotiate-perl \
  libimage-exiftool-perl \
  libimage-info-perl \
  libimage-size-perl \
  libinline-perl \
  libio-html-perl \
  libio-socket-ssl-perl \
  libio-string-perl \
  libipc-run-perl \
  libjson-perl \
  libjson-pp-perl \
  libjson-xs-perl \
  liblist-compare-perl \
  liblist-moreutils-perl \
  liblog-log4perl-perl \
  liblwp-authen-oauth2-perl \
  liblwp-mediatypes-perl \
  libmail-sendmail-perl \
  libmailtools-perl \
  libmime-lite-perl \
  libmime-types-perl \
  libmodule-implementation-perl \
  libmodule-runtime-perl \
  libmoose-perl \
  libmouse-perl \
  libmro-compat-perl \
  libnet-dns-perl \
  libnet-http-perl \
  libnet-libidn-perl \
  libnet-oauth-perl \
  libnet-ssleay-perl \
  libpackage-deprecationmanager-perl \
  libpackage-stash-perl \
  libparse-recdescent-perl \
  libplack-perl \
  libpod-simple-perl \
  libproc-processtable-perl \
  libreadonly-perl \
  libreadonly-xs-perl \
  libroman-perl \
  libsoap-lite-perl \
  libspreadsheet-writeexcel-perl \
  libsub-exporter-progressive-perl \
  libsub-name-perl \
  libtemplate-perl \
  libterm-readkey-perl \
  libterm-readline-gnu-perl \
  libtest-requiresinternet-perl \
  libtest-simple-perl \
  libtie-ixhash-perl \
  libtimedate-perl \
  libtry-tiny-perl \
  libuniversal-require-perl \
  liburi-encode-perl \
  libuuid-perl \
  libuuid-tiny-perl \
  libversion-perl \
  libwww-perl \
  libwww-robotrules-perl \
  libxml-dom-perl \
  libxml-libxml-perl \
  libxml-libxslt-perl \
  libxml-sax-perl \
  libxml-simple-perl \
  libxml-writer-perl \
  libyaml-appconfig-perl \
  libyaml-libyaml-perl \
  libyaml-perl \
  libmarc-record-perl \
  libmarc-xml-perl

RUN apt-get install -y \
  autoconf \
  bison \
  build-essential \
  git \
  libdevel-cover-perl \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  libreadline6-dev \
  libsqlite3-dev \
  libssl-dev \
  libyaml-dev \
  openssh-server \
  unzip \
  wget \
  zip \
  zlib1g-dev \
  netcat \
  libperl-critic-perl

RUN apt-get install -y libtest-class-perl libswitch-perl libtest-spec-perl libtest-mockobject-perl

RUN apt-get install -y apache2 apache2-utils vim

RUN cpan -T \
  File::Pairtree \
  URI::Escape \
  CGI::PSGI \
  IP::Geolocation::MMDB

WORKDIR htapps/babel/geoip
RUN wget https://github.com/maxmind/MaxMind-DB/blob/main/test-data/GeoIP2-Country-Test.mmdb?raw=true -O GeoIP2-Country.mmdb

RUN ln -s /tmp /ram

RUN mkdir -p /l/local/bin
RUN ln -s /usr/bin/unzip /l/local/bin/unzip
RUN ln -s /usr/bin/plackup /l/local/bin/plackup

WORKDIR /tmp
COPY ./imgsrv/vendor/KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827.zip /tmp
RUN unzip -j -d /tmp/kakadu KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827.zip
# RUN wget https://kakadusoftware.com/wp-content/uploads/2014/06/KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827.zip
# RUN unzip -j -d kakadu KDU7A2_Demo_Apps_for_Ubuntu-x86-64_170827.zip
RUN mv /tmp/kakadu/*.so /usr/local/lib
RUN mv /tmp/kakadu/kdu* /usr/local/bin
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/kakadu.conf
RUN ldconfig

RUN mkdir -p /l/local/bin
RUN ln -s /usr/bin/convert /l/local/bin/convert
RUN ln -s /usr/local/bin/kdu_expand /l/local/bin/kdu_expand
RUN ln -s /usr/local/bin/kdu_compress /l/local/bin/kdu_compress
RUN /bin/bash -c 'for cmd in pamflip jpegtopnm tifftopnm bmptopnm pngtopam ppmmake pamcomp pnmscalefixed pamscale pnmrotate pnmpad pamtotiff pnmtotiff pnmtojpeg pamrgbatopng ppmtopgm pnmtopng; do ln -s /usr/bin/$cmd /l/local/bin; done'

WORKDIR /htapps/babel/cache
RUN mkdir imgsrv
RUN chown -R www-data .
RUN chmod -R 4777 .

WORKDIR /htapps/babel/logs
RUN chown -R www-data .
RUN chmod -R 4777 .

COPY ./mdp-lib /htapps/babel/mdp-lib
COPY ./plack-lib /htapps/babel/plack-lib
COPY ./slip-lib /htapps/babel/slip-lib
COPY ./mdp-web /htapps/babel/mdp-web

WORKDIR /htapps/babel/pt
RUN ln -s /htapps/babel /htapps/test.babel

COPY ./pt /htapps/babel/pt
RUN echo -e "debug_local = 1\ndebug_enabled = 1\nmdpitem_use_cache=false\n" > lib/Config/local.conf
RUN chgrp -R www-data /htapps/babel/pt

WORKDIR /htapps/babel/imgsrv
COPY ./imgsrv /htapps/babel/imgsrv
RUN echo -e "debug_local=1\ndebug_enabled=1\nmdpitem_use_cache=false\n" > lib/Config/local.conf
RUN chgrp -R www-data /htapps/babel/imgsrv 

RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled
RUN ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled
RUN ln -s /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled
RUN ln -s /etc/apache2/mods-available/proxy_fcgi.load /etc/apache2/mods-enabled
RUN ln -s /etc/apache2/mods-available/proxy_http.load /etc/apache2/mods-enabled

COPY ./babel-local-dev/docker/000-default.conf /etc/apache2/sites-enabled/000-default.conf

# CMD  [ "/usr/sbin/apache2", "-D", "FOREGROUND"]
CMD [ "/usr/sbin/apache2ctl", "-D", "FOREGROUND" ]
