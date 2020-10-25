nullstring :=#end of the line
pwd =$(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))#pwd

whoami = $(shell whoami)
whoami_grep = $(shell echo $(whoami) | awk '{print substr($$0,1,7)}')

ifneq ($(shell echo $(whoami) | awk '{if(length >= 7) {print length;}}'), $(nullstring))
	whoami_grep :=$(whoami_grep)+
endif

git_version =2.7.0
git:
	@echo "installing git"
ifeq ($(shell which git), $(nullstring))
	yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker
	wget https://github.com/git/git/archive/v$(git_version).zip
	unzip v$(git_version).zip
	cd git-$(git_version);\
	make prefix=$(pwd)/git all;\
	make prefix=$(pwd)/git install;\
	cd ../
	ln -s $(pwd)/git/bin/git /usr/bin/git
else
	@echo "git already installed"
endif
	git --version

mvn_version =3.6.3
mvn:
ifeq ($(shell which mvn), $(nullstring))
	@echo "installing mvn"
	wget http://mirror.bit.edu.cn/apache/maven/maven-3/$(mvn_version)/binaries/apache-maven-$(mvn_version)-bin.tar.gz
	tar zvxf apache-maven-$(mvn_version)-bin.tar.gz
	
	mv apache-maven-$(mvn_version)/ maven
	make MAVEN_HOME=$(pwd)/maven path=$$MAVEN_HOME/bin
	
	@echo $MAVEN_HOME #this will output “$(pwd)/maven”	
else
	@echo "mvn already installed"
endif
	mvn --version
	
tomcat_version =8.5.55
tomcat:
	wget https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-8/v$(tomcat_version)/bin/apache-tomcat-$(tomcat_version).tar.gz
	tar -xzvf apache-tomcat-$(tomcat_version).tar.gz
	ln -s  $(pwd)/apache-tomcat-$(tomcat_version)/ $(pwd)/tomcat
ifdef port
	sed -i 's/<Connector port="8080" protocol/<Connector port="$(port)" protocol/' tomcat/conf/server.xml
	sed -i 's/<Connector port="8009" protocol/<Connector port="18009" protocol/' tomcat/conf/server.xml
	sed -i 's/<Server port="8005" shutdown="SHUTDOWN">/<Server port="18005" shutdown="SHUTDOWN">/' tomcat/conf/server.xml
endif	
	sh tomcat/bin/startup.sh
	sh tomcat/logs/catalina.out
	
jetty_vertion =9.4.30.v20200611
jetty:
ifeq ($(wildcard jetty-distribution-$(jetty_vertion).tar.gz), $(nullstring))
	wget http://maven.aliyun.com/nexus/content/groups/public/org/eclipse/jetty/jetty-distribution/$(jetty_vertion)/jetty-distribution-$(jetty_vertion).tar.gz
#	wget https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/$(jetty_vertion)/jetty-distribution-$(jetty_vertion).tar.gz
endif	
	tar -xzvf jetty-distribution-$(jetty_vertion).tar.gz
	mv jetty-distribution-$(jetty_vertion)/ jetty
	make JETTY_HOME=$(pwd)/jetty path=$(pwd)/jetty/bin
		
jdk:
	tar -xzvf jdk-8u65-linux-x64.tar.gz
	mv jdk-8u65-linux-x64 jdk
	make JAVA_HOME=$(pwd)/jdk path=$$JAVA_HOME/bin CLASSPATH=$JAVA_HOME/lib/dt.jar:$$JAVA_HOME/tools.jar:$$JAVA_HOME/jre/bin

	java -version

mysql_version =8.0.18#mysql_version
mysql_installation_file=mysql-$(mysql_version)-linux-glibc2.12-x86_64#mysql_installation_file
mysql_port :=$(if $(port),$(port),3306)#mysql_port
mysql_password :=$(if $(mysql_password),$(mysql_password),123456)#mysql_password
mysql: python	
ifeq ($(wildcard $(mysql_installation_file).tar), $(nullstring))
ifeq ($(wildcard $(mysql_installation_file).tar.xz), $(nullstring))
	wget https://dev.mysql.com/get/Downloads/MySQL-8.0/$(mysql_installation_file).tar.xz	
endif
	xz -d $(mysql_installation_file).tar.xz	
endif
ifeq ($(wildcard mysql), $(nullstring))
	tar xvf $(mysql_installation_file).tar
	mv $(mysql_installation_file) mysql
	chmod -R 777 $(pwd)/mysql
endif

ifeq ($(shell netstat -an | grep 3306), $(nullstring))
	echo "port 3306 is not public!"
endif	

ifeq ($(wildcard mysql/my.cnf), $(nullstring))
	touch mysql/my.cnf
	@echo "[client]" >> mysql/my.cnf
	@echo "port=$(mysql_port)" >> mysql/my.cnf
	@echo "socket=$(pwd)/mysql/mysql.sock" >> mysql/my.cnf
	@echo "[mysqld]" >> mysql/my.cnf
	#@echo "secure_file_priv=$(pwd)/mysql/tmp" >> mysql/my.cnf
	#@echo "skip-grant-tables" >> mysql/my.cnf
	@echo "tmp_table_size=134217728" >> mysql/my.cnf
	@echo "innodb_buffer_pool_size=1073741824" >> mysql/my.cnf	
	@echo "bind-address=0.0.0.0" >> mysql/my.cnf
	@echo "socket=$(pwd)/mysql/mysql.sock" >> mysql/my.cnf	
	@echo "lc-messages-dir=$(pwd)/mysql/share" >> mysql/my.cnf
	@echo "lc-messages=en_US" >> mysql/my.cnf
	@echo "port=$(mysql_port)" >> mysql/my.cnf
	@echo "basedir=$(pwd)/mysql" >> mysql/my.cnf
	@echo "datadir=$(pwd)/mysql/data" >> mysql/my.cnf
	@echo "pid-file=$(pwd)/mysql/mysql.pid" >> mysql/my.cnf
	@echo "log_error=$(pwd)/mysql/error.log" >> mysql/my.cnf
	@echo "server-id=100" >> mysql/my.cnf
	@echo "default_authentication_plugin=mysql_native_password" >> mysql/my.cnf
	@echo "tmpdir=$(pwd)/tmp" >> mysql/my.cnf
	cat mysql/my.cnf
	
endif

ifeq ($(wildcard mysql/data), $(nullstring))
	-mkdir $(pwd)/tmp
	chmod -R 777 $(pwd)/tmp
	
	mysql/bin/mysqld --defaults-file=$(pwd)/mysql/my.cnf --initialize --user=$(whoami)
	mysql/bin/mysqld_safe --defaults-file=$(pwd)/mysql/my.cnf --user=$(whoami) &
		
	-rm $(pwd)/tmp/mysql.sock
	ln -s $(pwd)/mysql/mysql.sock $(pwd)/tmp/mysql.sock
	cat mysql/error.log | grep 'A temporary password is generated for' | awk '{print $$NF}'
endif

ifeq ($(wildcard mysql/run.py), $(nullstring))
	touch mysql/run.py
	@echo "def sleep(seconds):" >> mysql/run.py
	@echo "	import time" >> mysql/run.py
	@echo "	seconds = int(seconds)" >> mysql/run.py	
	@echo "	print('sleep for %d seconds' % seconds)" >> mysql/run.py
	@echo "	time.sleep(seconds)" >> mysql/run.py
    
	@echo "def mysql_connector():" >> mysql/run.py
	@echo "	import mysql.connector" >> mysql/run.py
	@echo "	mydb = mysql.connector.connect(host='localhost', user='root', password='$(mysql_password)', port=$(mysql_port))" >> mysql/run.py
	@echo "	return mydb, mydb.cursor()" >> mysql/run.py

	@echo "def test():" >> mysql/run.py
	@echo "	mydb, mycursor = mysql_connector()" >> mysql/run.py
	@echo "	mycursor.execute('show databases')" >> mysql/run.py 
	@echo "	for x in mycursor:" >> mysql/run.py
	@echo "		print(x)" >> mysql/run.py
	
	@echo "def discard_tablespace(table):" >> mysql/run.py
	@echo "	sql = 'alter table %s discard tablespace' % table" >> mysql/run.py
	@echo "	print('executing:', sql)" >> mysql/run.py
	@echo "	mydb, mycursor = mysql_connector()" >> mysql/run.py
	@echo "	mycursor.execute('delete from ' + table)" >> mysql/run.py
	@echo "	mycursor.execute(sql)" >> mysql/run.py
	@echo "	sleep(5)" >> mysql/run.py
	
	@echo "def import_tablespace(table):" >> mysql/run.py
	@echo "	sql = 'alter table %s import tablespace' % table" >> mysql/run.py
	@echo "	print('executing:', sql)" >> mysql/run.py
	@echo "	mydb, mycursor = mysql_connector()" >> mysql/run.py
	@echo "	mycursor.execute(sql)" >> mysql/run.py
	
	@echo "if __name__ == '__main__':" >> mysql/run.py
	@echo "	import sys" >> mysql/run.py
	@echo "	cmd, *args = sys.argv[1:]" >> mysql/run.py
	@echo "	eval(cmd)(*args)" >> mysql/run.py
	
	cat mysql/run.py
endif

ifeq ($(wildcard mysql/init.sql), $(nullstring))
	touch mysql/init.sql
	@echo "alter user 'root'@'localhost' identified by '$(mysql_password)';" >> mysql/init.sql
	@echo "update user set host = '%' where user = 'root';" >> mysql/init.sql	
	@echo "flush privileges;" >> mysql/init.sql
	cat mysql/init.sql
endif

ifeq ($(wildcard mysql/makefile), $(nullstring))
	touch mysql/makefile
	@echo "password =\`cat error.log | grep 'A temporary password is generated for' | awk '{print \$$\$$NF}'\`" >> mysql/makefile
	
	@echo "all:" >> mysql/makefile
	@echo "	make try || make" >> mysql/makefile
	@echo >> mysql/makefile
	
	@echo "try:" >> mysql/makefile
	@echo "	python run.py sleep 1" >> mysql/makefile
	@echo "	cat error.log | grep 'A temporary password is generated for' | awk '{print \$$\$$NF}'" >> mysql/makefile
	@echo "	@echo \"password = \$$(password)\"" >> mysql/makefile		
	@echo "	bin/mysql --connect-expired-password -uroot -Dmysql -p\$$(password) < $(pwd)/mysql/init.sql" >> mysql/makefile
	@echo "	python run.py test" >> mysql/makefile	
	@echo >> mysql/makefile

	@echo "clean: stop" >> mysql/makefile
	@echo "	rm -rf $(pwd)/mysql" >> mysql/makefile
	
	@echo "load_data:" >> mysql/makefile
	@echo "	python run.py discard_tablespace \$$(table)" >> mysql/makefile	
	@echo "	make database=\`echo \$$(table) | awk -F'.' '{print \$$\$$1}'` table=`echo \$$(table) | awk -F'.' '{print \$$\$$2}'\` copy" >> mysql/makefile
	@echo "	python run.py import_tablespace \$$(table)" >> mysql/makefile
		
	@echo "copy:" >> mysql/makefile
	@echo "	for file in \`ls ../bypy/\$$(database)/\$$(table)*.ibd\`; do \\" >> mysql/makefile
	@echo "		filename=\`echo \$$(basename \$$file)\`;\\" >> mysql/makefile	
	@echo "		filename=\`echo \$${filename/\\#p\\#/\\#P\\#}\`;\\" >> mysql/makefile
	@echo "		cp \$$file data/\$$database/\$$filename;\\" >> mysql/makefile
	@echo "	done" >> mysql/makefile
		
	@echo "stop:" >> mysql/makefile
	@echo "	ps -ef | grep mysql | grep -v grep | egrep -v make.+clean | grep $(whoami)" >> mysql/makefile		
	@echo "	ps -ef | grep mysql | grep -v grep | egrep -v make.+clean | grep $(whoami) | awk '{print \$$\$$2}'" >> mysql/makefile	
	@echo "	-kill -9 \`ps -ef | grep mysql | grep -v grep | egrep -v make.+clean | grep $(whoami) | awk '{print \$$\$$2}'\`" >> mysql/makefile

	@echo "restart: stop" >> mysql/makefile
	@echo "	bin/mysqld_safe --defaults-file=$(pwd)/mysql/my.cnf --user=$(whoami) &" >> mysql/makefile		
	
	cat mysql/makefile
endif
	cd mysql && make
	make path=$(pwd)/mysql/bin

cpu-count:
	cat /proc/cpuinfo | grep processor | wc -l
#	cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l
	
redis_version =5.0.8#redis_version
redis:
ifeq ($(wildcard redis-$(redis_version).tar.gz), $(nullstring))
	wget http://download.redis.io/releases/redis-$(redis_version).tar.gz
	tar -zxf redis-$(redis_version).tar.gz
endif
	mv redis-$(redis_version) redis
	cd redis && make 
	cd redis/src && make PREFIX=$(pwd)/redis install
	