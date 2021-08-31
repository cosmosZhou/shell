#usage: make
#https://www.php.net/manual/en/install.unix.apache2.php

nullstring :=#end of the line
pwd =$(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))#pwd

pwd := $(shell dirname $(pwd))
pwd := $(shell dirname $(pwd))
$(info pwd = $(pwd))

php_version =7.4.21
openssl: php
ifeq ($(wildcard $(pwd)/php/lib/php/extensions/*/openssl.so), $(nullstring))
	sed -i 's/^;extension=openssl/extension=openssl/g' $(pwd)/php/etc/php.ini
	sed -i 's/^allow_url_include = Off/allow_url_include = On/' $(pwd)/php/etc/php.ini
	
	cd php-$(php_version)/ext/openssl;\
    make clean; \
    $(pwd)/php/bin/phpize; \
    ./configure --with-openssl --with-php-config=$(pwd)/php/bin/php-config; \
 	make && make install; \
 	cd ../../../
endif	


php: httpd
ifeq ($(wildcard php-$(php_version).tar.gz), $(nullstring))
	#wget http://cn2.php.net/distributions/php-$(php_version).tar.gz
	wget https://www.php.net/distributions/php-$(php_version).tar.gz
endif

ifeq ($(wildcard php-$(php_version)), $(nullstring))
	tar -zxvf php-$(php_version).tar.gz
endif
#skip compiling
ifeq ($(wildcard $(pwd)/php), $(nullstring))
	mkdir -p $(pwd)/php/etc
	cp php-$(php_version)/php.ini-production $(pwd)/php/etc/php.ini
	
	cd php-$(php_version);\
	make clean; \
    ./configure --prefix=$(pwd)/php \
                --with-zlib \
                --with-curl \
                --with-apxs2=$(pwd)/httpd/bin/apxs \
                --with-config-file-path=$(pwd)/php/etc \
                --with-mysql-sock \
                --with-mysqli=$(pwd)/mysql/bin/mysql_config \
                --enable-sockets \
                --without-sqlite3 \
                --without-pdo_sqlite;\
    make && make install;\
    cd ../
endif


apr_version =1.7.0
apr:
#skip wget
ifeq ($(wildcard apr-$(apr_version).tar.gz), $(nullstring))
	wget https://mirror.bit.edu.cn/apache//apr/apr-$(apr_version).tar.gz
endif
#skip untar
ifeq ($(wildcard apr-$(apr_version)), $(nullstring))
	tar -zxvf apr-$(apr_version).tar.gz
endif
#skip compiling
ifeq ($(wildcard $(pwd)/apr), $(nullstring))
	cd apr-$(apr_version);\
    ./configure --prefix=$(pwd)/apr;\
    make && make install;\
    cd ../
endif

expat_version =2.0.1
expat:
#https://launchpad.net/ubuntu/+source/expat/$(expat_version)-7.2ubuntu1.4
ifeq ($(wildcard expat_$(expat_version).orig.tar.gz), $(nullstring))
	wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/expat/$(expat_version)-7.2ubuntu1.4/expat_$(expat_version).orig.tar.gz
endif
ifeq ($(wildcard expat-$(expat_version)), $(nullstring))
	tar -zxvf expat_$(expat_version).orig.tar.gz
endif
#skip compiling
ifeq ($(wildcard $(pwd)/expat), $(nullstring))
	cd expat-$(expat_version);\
    ./configure --prefix=$(pwd)/expat;\
    make && make install;\
    cd ../
endif
	
apr_util_version =1.6.1
apr-util: apr expat
ifeq ($(wildcard apr-util-$(apr_util_version).tar.gz), $(nullstring))
	wget http://mirrors.gigenet.com/apache//apr/apr-util-$(apr_util_version).tar.gz
endif
ifeq ($(wildcard apr-util-$(apr_util_version)), $(nullstring))
	tar -zxvf apr-util-$(apr_util_version).tar.gz
endif
#skip compiling
ifeq ($(wildcard $(pwd)/apr-util), $(nullstring))
	cd apr-util-$(apr_util_version);\
    ./configure --prefix=$(pwd)/apr-util --with-apr=$(pwd)/apr --with-expat=$(pwd)/expat;\
    make && make install;\
    cd ../
endif
	
pcre_version =8.40
pcre:
ifeq ($(wildcard pcre-$(pcre_version).tar.gz), $(nullstring))
	wget https://netix.dl.sourceforge.net/project/pcre/pcre/$(pcre_version)/pcre-$(pcre_version).tar.gz
endif
ifeq ($(wildcard pcre-$(pcre_version)), $(nullstring))
	tar -zxvf pcre-$(pcre_version).tar.gz
endif
#skip compiling
ifeq ($(wildcard $(pwd)/pcre), $(nullstring))
	cd pcre-$(pcre_version);\
    ./configure --prefix=$(pwd)/pcre;\
    make && make install;\
    cd ../
endif


httpd_version =2.4.46
httpd: apr apr-util pcre #openssl
ifeq ($(wildcard httpd-$(httpd_version).tar.gz), $(nullstring))
	wget https://downloads.apache.org/httpd/httpd-$(httpd_version).tar.gz
#	wget https://mirror.bit.edu.cn/apache/httpd/httpd-$(httpd_version).tar.gz
#	wget https://mirrors.bfsu.edu.cn/apache/httpd/httpd-$(httpd_version).tar.gz
#	wget https://mirrors.tuna.tsinghua.edu.cn/apache/httpd/httpd-$(httpd_version).tar.gz
endif
ifeq ($(wildcard httpd-$(httpd_version)), $(nullstring))
	tar -zxvf httpd-$(httpd_version).tar.gz
endif
#skip compiling
ifeq ($(wildcard $(pwd)/httpd), $(nullstring))
	cd httpd-$(httpd_version);\
	make clean; \
    ./configure --prefix=$(pwd)/httpd \
                --enable-so \
                --enable-ssl \
                --with-mpm=event \
                --with-apr=$(pwd)/apr \
                --with-apr-util=$(pwd)/apr-util \
                --with-pcre=$(pwd)/pcre \
                --with-expat=$(pwd)/expat;\
    make && make install;\
    cd ../
endif
	sh insert.sh $(pwd) "<IfModule mime_module>" "    AddType application/x-httpd-php .php"
	sh insert.sh $(pwd) "<IfModule dir_module>" "    DirectoryIndex index.php index.html"
	
	sed -i -E 's/^\#(LoadModule cgid_module modules\/mod_cgid.so)/\1/' $(pwd)/httpd/conf/httpd.conf
	sed -i -E 's/(Options Indexes .+)/\1 ExecCGI/' $(pwd)/httpd/conf/httpd.conf
	sed -i -E 's/\#(AddHandler cgi-script .cgi)/\1 .py/' $(pwd)/httpd/conf/httpd.conf	   
#--with-ssl=$(pwd)/openssl

clean:
	rm -rf $(pwd)/php -rf $(pwd)/httpd	
	