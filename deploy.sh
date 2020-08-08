#!/bin/bash
set -ex
ISUCON_KEYPATH=~/.ssh/isucon3.pem
ISUCON_HOME=/home/isucon/webapp
ISUCON_HOST=isucon3

scripts=$(cat <<EOF
sudo rm -f /tmp/mysql-slow.log /home/isucon/access_log;
cd $ISUCON_HOME;
git pull origin master;
sudo cp $ISUCON_HOME/config/my.cnf /usr/my.cnf;
sudo cp $ISUCON_HOME/config/nginx.conf /etc/nginx/conf/nginx.conf;
cd ~/webapp/go;
# TODO
# Go Restart
sudo service mysql restart;
sudo service httpd restart;
exit;
EOF
)


#Deploy
echo $scripts | ssh -t -t $ISUCON_HOST -i $ISUCON_KEYPATH
