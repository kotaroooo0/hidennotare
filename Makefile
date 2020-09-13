DB_HOST:=127.0.0.1
DB_PORT:=3306
DB_USER:=isucon
DB_PASS:=isucon
DB_NAME:=isuumo

MYSQL_CMD:=mysql -h$(DB_HOST) -P$(DB_PORT) -u$(DB_USER) -p$(DB_PASS) $(DB_NAME)

NGX_LOG:=/var/log/nginx/access.log
MYSQL_LOG:=/tmp/slow-query.log

KATARU_CFG:=./kataribe.toml

SLACKCAT:=slackcat --tee
SLACKRAW:=slackcat

PPROF:=go tool pprof -png -output pprof.png http://localhost:6060/debug/pprof/profile

PROJECT_ROOT:=/home/isucon/isuumo
BUILD_DIR:=/home/isucon/isuumo/webapp/go
BIN_NAME:=isuumo


.PHONY: restart
restart:
	sh /home/isucon/env.sh;
	cd $(BUILD_DIR); go build -o $(BIN_NAME)
	sudo systemctl restart isuumo.go.service

.PHONY: before
before:
	git pull
	sudo rm -f $(NGX_LOG)
	sudo rm -f $(MYSQL_LOG)
	sudo cp nginx.conf /etc/nginx/nginx.conf
	sudo cp isuumo.conf /etc/nginx/sites-enabled/isuumo.conf
	sudo cp my.cnf /etc/mysql/my.cnf
	sudo cp mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
	sudo cp env.sh /home/isucon/env.sh
	sudo systemctl restart nginx
	sudo systemctl restart mysql

.PHONY: slow
slow:
	sudo pt-query-digest $(MYSQL_LOG) | $(SLACKCAT)

.PHONY: kataru
kataru:
	sudo cat $(NGX_LOG) | kataribe -f ./kataribe.toml | $(SLACKCAT)

.PHONY: pprof
pprof:
	$(PPROF)
	$(SLACKRAW) -n pprof.png ./pprof.png

.PHONY: setup
setup:
	wget https://github.com/matsuu/kataribe/releases/download/v0.4.1/kataribe-v0.4.1_linux_amd64.zip -O kataribe.zip
	unzip -o kataribe.zip
	sudo mv kataribe /usr/local/bin/
	sudo chmod +x /usr/local/bin/kataribe
	rm kataribe.zip
	kataribe -generate
	wget https://github.com/KLab/myprofiler/releases/download/0.2/myprofiler.linux_amd64.tar.gz
	tar xf myprofiler.linux_amd64.tar.gz
	rm myprofiler.linux_amd64.tar.gz
	sudo mv myprofiler /usr/local/bin/
	sudo chmod +x /usr/local/bin/myprofiler
	wget https://github.com/bcicen/slackcat/releases/download/v1.5/slackcat-1.5-linux-amd64 -O slackcat
	sudo mv slackcat /usr/local/bin/
	sudo chmod +x /usr/local/bin/slackcat
	slackcat --configure
	sudo apt-get install percona-toolkit
