nullstring :=#end of the line
pwd =$(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))#pwd

whoami = $(shell whoami)
whoami_grep = $(shell echo $(whoami) | awk '{print substr($$0,1,7)}')

ifneq ($(shell echo $(whoami) | awk '{if(length >= 7) {print length;}}'), $(nullstring))
	whoami_grep :=$(whoami_grep)+
endif

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

cpu-count:
	cat /proc/cpuinfo | grep processor | wc -l
#	cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l
#   sudo mount /dev/md0  /mnt/data0