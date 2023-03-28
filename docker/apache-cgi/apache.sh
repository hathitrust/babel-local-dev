#! /bin/bash

# Apache gets grumpy about PID files pre-existing
if [ ! -d /var/run/apache2 ]
then
  mkdir -p /var/run/apache2
fi

rm -f /var/run/apache2/apache2*.pid

source /etc/apache2/envvars

exec apache2 -DFOREGROUND 
