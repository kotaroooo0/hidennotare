set -ex

ISUCON_KEYPATH=~/.ssh/isucon3.pem
ISUCON_HOME=/home/isucon/isucari
ISUCON_HOST=isucon9

# sudo rm -f /tmp/mysql-slow.log /home/isucon/access_log;
# sudo cp $ISUCON_HOME/config/my.cnf /usr/my.cnf;
# sudo cp $ISUCON_HOME/config/nginx.conf /etc/nginx/conf/nginx.conf;
# TODO
# Go Restart
# sudo service mysql restart;
# sudo service httpd restart;

scripts=$(cat <<EOF
cd $ISUCON_HOME;
git pull origin master;
cd $ISUCON_HOME/webapp/go;
echo restart;
exit;
EOF
)


#Deploy
echo $scripts | ssh -t -t $ISUCON_HOST
