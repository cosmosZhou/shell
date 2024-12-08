#https://www.php.net/manual/en/install.unix.apache2.php

pwd := $(shell cd ~; pwd)
$(info pwd = ${pwd})

php_version=8.1.21
php: httpd mysql ${pwd}/php
	echo "${php_version} is installed at ${pwd}/php"

php-${php_version}.tar.gz:
#   wget http://cn2.php.net/distributions/php-${php_version}.tar.gz
	wget https://www.php.net/distributions/php-${php_version}.tar.gz

php-${php_version}: php-${php_version}.tar.gz
	tar -zxvf php-${php_version}.tar.gz

${pwd}/php: php-${php_version}
	mkdir -p ${pwd}/php/etc
	cp php-${php_version}/php.ini-production ${pwd}/php/etc/php.ini

	cd php-${php_version};\
    make clean; \
    ./configure --prefix=${pwd}/php \
                --with-zlib \
                --with-curl \
                --with-mysql-sock \
                --with-apxs2=${pwd}/httpd/bin/apxs          \
                --with-config-file-path=${pwd}/php/etc      \
                --with-mysqli=${pwd}/mysql/bin/mysql_config \
                --without-sqlite3    \
                --without-pdo_sqlite \
                --without-libxml     \
                --enable-sockets     \
                --disable-dom        \
                --disable-simplexml  \
                --disable-xml        \
                --disable-xmlreader  \
                --disable-xmlwriter; \
    make && make install;\
    cd ../

	sed -i -E 's/(post_max_size) = [0-9]M/\1 = 1G/' ${pwd}/php/etc/php.ini
	sed -i -E 's/;(mysqli.allow_local_infile = On)/\1/' ${pwd}/php/etc/php.ini
	sed -i -E 's/;(max_input_vars) = 1000/\1 = 1000000/' ${pwd}/php/etc/php.ini
	sed -i -E 's/(memory_limit) = 128M/\1 = 10G/' ${pwd}/php/etc/php.ini
	sed -i -E 's/(upload_max_filesize) = [0-9]M/\1 = 2G/' ${pwd}/php/etc/php.ini
	sed -i -E 's/(max_execution_time) = 30/\1 = 3000/' ${pwd}/php/etc/php.ini


mysql_version=8.0.33
sys_bit=x86_64
mysql_filename="mysql-${mysql_version}-linux-glibc2.12-${sys_bit}"
mysql_filename_url=https://downloads.mysql.com/archives/get/p/23/file/${mysql_filename}.tar.xz
# mysql_filename_url=https://cdn.mysql.com/Downloads/MySQL-8.0/${mysql_filename}.tar.xz
mysql_location=${pwd}/mysql
mysql: ${pwd}/mysql
	echo "mysql-${mysql_version} is installed at ${pwd}/mysql"

${mysql_filename}.tar.xz:
	wget --no-check-certificate --progress=bar:force -cv -t3 -T10 -O ${mysql_filename}.tar.xz ${mysql_filename_url}

${mysql_filename}: ${mysql_filename}.tar.xz
	tar Jxf ${mysql_filename}.tar.xz

${pwd}/mysql: ${mysql_filename}
	mkdir -p ${pwd}/mysql
	mv ${mysql_filename}/* ${pwd}/mysql
	bash mysql.sh

apr_version=1.7.0
apr: ${pwd}/apr
	echo "${apr_version} is installed at ${pwd}/apr"

apr-${apr_version}.tar.gz:
	wget https://archive.apache.org/dist/apr/apr-${apr_version}.tar.gz
#   wget https://mirror.bit.edu.cn/apache//apr/apr-${apr_version}.tar.gz

apr-${apr_version}: apr-${apr_version}.tar.gz
	tar -zxvf apr-${apr_version}.tar.gz

${pwd}/apr: apr-${apr_version}
	cd apr-${apr_version};\
    ./configure --prefix=${pwd}/apr;\
    make && make install;\
    cd ../


expat_version=2.0.1
expat: ${pwd}/expat
	echo "${expat_version} is installed at ${pwd}/expat"

expat_${expat_version}.orig.tar.gz:
	wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/expat/${expat_version}-7.2ubuntu1.4/expat_${expat_version}.orig.tar.gz

expat-${expat_version}: expat_${expat_version}.orig.tar.gz
	tar -zxvf expat_${expat_version}.orig.tar.gz

${pwd}/expat: expat-${expat_version}
	cd expat-${expat_version};\
    ./configure --prefix=${pwd}/expat;\
    make && make install;\
    cd ../


apr_util_version=1.6.1
apr-util: apr expat ${pwd}/apr-util
	echo "${apr_util_version} is installed at ${pwd}/apr-util"

apr-util-${apr_util_version}.tar.gz:
	wget http://archive.apache.org/dist/apr/apr-util-${apr_util_version}.tar.gz
#   wget http://mirrors.gigenet.com/apache//apr/apr-util-${apr_util_version}.tar.gz

apr-util-${apr_util_version}: apr-util-${apr_util_version}.tar.gz
	tar -zxvf apr-util-${apr_util_version}.tar.gz

${pwd}/apr-util: apr-util-${apr_util_version}
	cd apr-util-${apr_util_version};\
    ./configure --prefix=${pwd}/apr-util --with-apr=${pwd}/apr --with-expat=${pwd}/expat;\
    make && make install;\
    cd ../

pcre_version=8.45
pcre: ${pwd}/pcre
	echo "${pcre_version} is installed at ${pwd}/pcre"

pcre-${pcre_version}.tar.gz:
	wget https://dl.lamp.sh/files/pcre-${pcre_version}.tar.gz
#   wget https://netix.dl.sourceforge.net/project/pcre/pcre/${pcre_version}/pcre-${pcre_version}.tar.gz

pcre-${pcre_version}: pcre-${pcre_version}.tar.gz
	tar -zxvf pcre-${pcre_version}.tar.gz

${pwd}/pcre: pcre-${pcre_version}
	cd pcre-${pcre_version};\
    ./configure --prefix=${pwd}/pcre;\
    make && make install;\
    cd ../


httpd_version=2.4.46
httpd: apr apr-util pcre ${pwd}/httpd #openssl
	echo "${httpd_version} is installed at ${pwd}/httpd"

httpd-${httpd_version}.tar.gz:
	wget https://dl.lamp.sh/files/httpd-${httpd_version}.tar.gz
#   wget https://downloads.apache.org/httpd/httpd-${httpd_version}.tar.gz
#   wget https://mirror.bit.edu.cn/apache/httpd/httpd-${httpd_version}.tar.gz
#   wget https://mirrors.bfsu.edu.cn/apache/httpd/httpd-${httpd_version}.tar.gz
#   wget https://mirrors.tuna.tsinghua.edu.cn/apache/httpd/httpd-${httpd_version}.tar.gz

httpd-${httpd_version}: httpd-${httpd_version}.tar.gz
	tar -zxvf httpd-${httpd_version}.tar.gz

${pwd}/httpd: httpd-${httpd_version}
	cd httpd-${httpd_version};\
    make clean; \
    ./configure --prefix=${pwd}/httpd \
                --enable-so \
                --enable-ssl \
                --with-mpm=event \
                --with-apr=${pwd}/apr \
                --with-apr-util=${pwd}/apr-util \
                --with-pcre=${pwd}/pcre \
                --with-expat=${pwd}/expat;\
    make && make install;\
    cd ../

	sh insert.sh ${pwd} "<IfModule mime_module>" "    AddType application/x-httpd-php .php"
	sh insert.sh ${pwd} "<IfModule dir_module>" "    DirectoryIndex index.php index.html"

	sed -i -E 's/^\#(LoadModule cgid_module modules\/mod_cgid.so)/\1/' ${pwd}/httpd/conf/httpd.conf
	sed -i -E 's/(Options Indexes .+)/\1 ExecCGI/' ${pwd}/httpd/conf/httpd.conf
	sed -i -E 's/\#(AddHandler cgi-script .cgi)/\1 .py/' ${pwd}/httpd/conf/httpd.conf   


clean.php:
	rm -rf ${pwd}/php php-${php_version}

clean: clean.php
	rm -rf ${pwd}/httpd httpd-${httpd_version}

libzip_version=1.2.0
libzip: ${pwd}/libzip
	echo "${libzip_version} is installed at ${pwd}/libzip"

libzip-${libzip_version}.tar.gz:
	wget --no-check-certificate https://libzip.org/download/libzip-${libzip_version}.tar.gz

libzip-${libzip_version}: libzip-${libzip_version}.tar.gz
	tar -zxvf libzip-${libzip_version}.tar.gz

${pwd}/libzip: libzip-${libzip_version}
	cd libzip-${libzip_version};\
    ./configure --prefix=${pwd}/libzip;\
    make && make install
	cp ${pwd}/libzip/lib/libzip/include/zipconf.h ${pwd}/libzip/include/zipconf.h


zip_version=1.16.0
zip: libzip ${pwd}/zip
	echo "${zip_version} is installed at ${pwd}/zip"

zip-${zip_version}.tgz:
	wget http://pecl.php.net/get/zip-${zip_version}.tgz

zip-${zip_version}: zip-${zip_version}.tgz
	tar -zxvf zip-${zip_version}.tgz

${pwd}/zip: zip-${zip_version}
	cd zip-${zip_version};\
    ${pwd}/php/bin/phpize;\
    ./configure --with-libzip=${pwd}/libzip \
    --with-php-config=${pwd}/php/bin/php-config;\
    make && make install

	bash ../insert.sh ${pwd}/php/etc/php.ini "Module Settings ;" "[zip]\nextension=zip.so"
	bash ../update.sh ${pwd}/php/etc/php.ini "http://php.net/zlib.output-compression" "zlib.output_compression = On"


oniguruma_version=6.9.4
oniguruma: ${pwd}/oniguruma
	echo "${oniguruma_version} is installed at ${pwd}/oniguruma"

oniguruma-${oniguruma_version}.tar.gz:
	wget https://github.com/kkos/oniguruma/archive/refs/tags/v${oniguruma_version}.tar.gz -O oniguruma-${oniguruma_version}.tar.gz

oniguruma-${oniguruma_version}: oniguruma-${oniguruma_version}.tar.gz
	tar -zxvf oniguruma-${oniguruma_version}.tar.gz

${pwd}/oniguruma: oniguruma-${oniguruma_version}
	cd oniguruma-${oniguruma_version};\
    ./autogen.sh && ./configure --prefix=${pwd}/oniguruma;\
    make && make install

	bash ../bash_profile.sh PKG_CONFIG_PATH=${pwd}/oniguruma/lib/pkgconfig
	bash ../bash_profile.sh LD_LIBRARY_PATH=${pwd}/oniguruma/lib/
	bash ../bash_profile.sh LD_RUN_PATH=${pwd}/oniguruma/lib

# PHP Fatal error: Uncaught Error: Call to undefined function mb_strlen()
mbstring: oniguruma
	cd ${pwd}/shell/php/php-$(shell echo `php -v` | sed -E 's/.*PHP ([0-9.]+) \(cli\).*/\1/')/ext/mbstring;\
    ${pwd}/php/bin/phpize;\
    ./configure --with-php-config=${pwd}/php/bin/php-config;\
    make && make install

test:
	echo pwd = ${pwd}


xdebug_version=3.4.0
xdebug: xdebug-${xdebug_version}/modules/xdebug.so
	bash xdebug.sh

xdebug-${xdebug_version}/modules/xdebug.so: xdebug-${xdebug_version}
	cd xdebug-${xdebug_version};\
    ${pwd}/php/bin/phpize;\
    ./configure --enable-xdebug --with-php-config=${pwd}/php/bin/php-config;\
    make && make install

xdebug-${xdebug_version}: xdebug-${xdebug_version}.tgz
	tar -zxvf xdebug-${xdebug_version}.tgz

xdebug-${xdebug_version}.tgz:
	wget https://xdebug.org/files/xdebug-${xdebug_version}.tgz
