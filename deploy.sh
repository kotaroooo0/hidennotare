#!/bin/bash
set -ex
ISUCON_HOME=/home/isucon/isuumo
GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
git push -u origin $GIT_BRANCH;

scripts_02=$(cat <<EOF
cd $ISUCON_HOME;
git fetch origin $GIT_BRANCH;
git checkout $GIT_BRANCH;
git pull origin $GIT_BRANCH;
make before;
make restart;
sudo systemctl stop isuumo.go.service;
sudo systemctl stop nginx;
exit;
EOF
)
echo $scripts_02 | ssh -t -t isucon-server-002;


scripts_01=$(cat <<EOF
cd $ISUCON_HOME;
git fetch origin $GIT_BRANCH;
git checkout $GIT_BRANCH;
git pull origin $GIT_BRANCH;
make before;
make restart;
sudo systemctl stop mysql;
exit;
EOF
)

#Deploy
echo $scripts_01 | ssh -t -t isucon-server-001;
