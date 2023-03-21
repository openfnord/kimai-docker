#!/bin/bash -x

KIMAI=$(cat /opt/kimai/version.txt)
echo $KIMAI

function config() {
  # set mem limits and copy in custom logger config
  if [ -z "$memory_limit" ]; then
    memory_limit=256
  fi

  echo "Wait for MySQL DB connection ..."
  until php /dbtest.php $DB_HOST $DB_BASE $DB_PORT $DB_USER $DB_PASS; do
    echo Checking DB: $?
    sleep 3
  done
  echo "Connection established"
}

function handleStartup() {
  set -x
  # set mem limits and copy in custom logger config
  if [ "${APP_ENV}" == "prod" ]; then
    sed "s/128M/${memory_limit}M/g" /usr/local/etc/php/php.ini-production > /usr/local/etc/php/php.ini
    if [ "${KIMAI:0:1}" -lt "2" ]; then
      cp /assets/monolog-prod.yaml /opt/kimai/config/packages/monolog.yaml
    else
      cp /assets/monolog.yaml /opt/kimai/config/packages/monolog.yaml
    fi
  else
    sed "s/128M/${memory_limit}M/g" /usr/local/etc/php/php.ini-development > /usr/local/etc/php/php.ini
    if [ "${KIMAI:0:1}" -lt "2" ]; then
      cp /assets/monolog-dev.yaml /opt/kimai/config/packages/monolog.yaml
    else
      cp /assets/monolog.yaml /opt/kimai/config/packages/monolog.yaml
    fi
  fi
  set +x

  tar -zx -C /opt/kimai -f /var/tmp/public.tgz 
  
  if [ -z "$USER_ID" ]; then
    USER_ID=$(id -u www-data)
  fi
  if [ -z "$GROUP_ID" ]; then
    GROUP_ID=$(id -g www-data)
  fi

  chown -R $USER_ID:$GROUP_ID /opt/kimai/var

  # if user doesn't exist
  if id $USER_ID &>/dev/null; then
    echo User already exists
  else
    echo www-kimai:x:$USER_ID:$GROUP_ID:www-kimai:/var/www:/usr/sbin/nologin >> /etc/passwd
    echo www-data:x:33: >> /etc/group
    pwconv
  fi

  if [ -e /use_apache ]; then         
    export APACHE_RUN_USER=$(id -nu 33)
    export APACHE_RUN_GROUP=$(id -ng 33)
  elif [ -e /use_fpm ]; then         
    sed -i "s/user = .*/user = $USER_ID/g" /usr/local/etc/php-fpm.d/www.conf
    sed -i "s/group = .*/group = $GROUP_ID/g" /usr/local/etc/php-fpm.d/www.conf
  else                                                        
    echo "Error, unknown server type"                         
  fi
}

config
/service.sh
exit
