#!/bin/bash

mkdir -p -m 0700 /root/.ssh

# Prevent config files from being filled to infinity by force of stop and restart the container
echo "" > /root/.ssh/config
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

if [[ "$GIT_USE_SSH" == "1" ]] ; then
  echo -e "Host *\n\tUser ${GIT_USERNAME}\n\n" >> /root/.ssh/config
fi

if [ ! -z "$SSH_KEY" ]; then
 echo $SSH_KEY > /root/.ssh/id_rsa.base64
 base64 -d /root/.ssh/id_rsa.base64 > /root/.ssh/id_rsa
 chmod 600 /root/.ssh/id_rsa
fi

# Setup git variables
if [ ! -z "$GIT_EMAIL" ]; then
 git config --global user.email "$GIT_EMAIL"
fi
if [ ! -z "$GIT_NAME" ]; then
 git config --global user.name "$GIT_NAME"
 git config --global push.default simple
fi

if [ ! -d "/var/www" ]; then
  mkdir -p -m 0755 /var/www/html
fi;

env | sed "s/\(.*\)=\(.*\)/env[\1]='\2'/" >> /etc/php/7.1/fpm/pool.d/www.conf
php-fpm7.1 -D
nginx -g 'daemon off;'
