#!/usr/bin/env bash

# Bash Helper Script For Kimai Docker Management
# https://www.kimai.org/documentation/docker.html
# taken from: https://gist.github.com/ArtBIT/364fd43a75d2ec38a09fb070d597bd71

kimai_install() {
    docker run --name kimai-mysql \
             -e MYSQL_DATABASE=kimai \
             -e MYSQL_USER=kimai \
             -e MYSQL_PASSWORD=kimai \
             -e MYSQL_ROOT_PASSWORD=kimai \
             -p 3399:3306 -d mysql

    docker run --name kimai \
             -tid \
             -p 8001:8001 \
             -e DATABASE_URL=mysql://kimai:kimai@${HOSTNAME}:3399/kimai \
             kimai/kimai2:apache

    docker exec -ti kimai \
             /opt/kimai/bin/console kimai:create-user artbit artbit@example.com ROLE_SUPER_ADMIN

}

kimai_uninstall() {
    docker rm kimai
    docker rm kimai-mysql
}

kimai_backup() {
    mysqldump -u kimai –p kimai -h 127.0.0.1 -P 3399 kimai > kimai.$(date +"%Y-%m-%dT%H:%M:%S").sql
}

kimai_check() {
    if docker container ls -a -f name=kimai | grep -q kimai; then 
        # kimai docker exists
        return 0
    else 
        # kimai docker does not exist
        return 1
    fi
}

kimai_start() {
    if ! kimai_check; then
        kimai_install
    fi
    docker start kimai-mysql kimai
    echo ""
    echo "point a webbrowser to your server IP:8001"
    echo "you can now call manage-kimai-docker.sh web"
    echo "or just call"
    echo "xdg-open http://localhost:8001"
    echo ""
    echo "for management call: docker exec -ti kimai /opt/kimai/bin/console <some kimai command>"
}

kimai_web() {
    xdg-open http://localhost:8001
}
kimai_stop() {
    docker stop kimai-mysql kimai
}


case "$1" in
    install)
        kimai_install
        ;;
    uninstall)
        kimai_uninstall
        ;;
    stop)
        kimai_stop
        ;;
    web)
        kimai_web
        ;;
    backup)
        kimai_backup
        ;;
    *)
        kimai_start
esac
