nullstring :=#end of the line
pwd =$(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))#pwd

whoami = $(shell whoami)
whoami_grep = $(shell echo $(whoami) | awk '{print substr($$0,1,7)}')

ifneq ($(shell echo $(whoami) | awk '{if(length >= 7) {print length;}}'), $(nullstring))
	whoami_grep :=$(whoami_grep)+
endif

python_version =3.6.10
python:
ifeq ($(wildcard Python-$(python_version).tgz), $(nullstring))
	wget https://www.python.org/ftp/python/$(python_version)/Python-$(python_version).tgz
endif
ifeq ($(wildcard Python-$(python_version)), $(nullstring))
	tar -zxvf Python-$(python_version).tgz
endif
	cd Python-$(python_version);\
	./configure --prefix=$(pwd)/python --enable-loadable-sqlite-extensions --enable-optimizations;\
	make && make install;\
	cd ../	
	make path=$(pwd)/python/bin
	
	ln -s $(pwd)/python/bin/python3 $(pwd)/python/bin/python
	-ln -s $(pwd)/python/bin/pip3 $(pwd)/python/bin/pip
	
	mkdir ~/.pip
	touch ~/.pip/pip.conf
	@echo "[global]" >> ~/.pip/pip.conf
	@echo "timeout = 60" >> ~/.pip/pip.conf
	@echo "index-url = http://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf
	@echo "extra-index-url= http://pypi.douban.com/simple/" >> ~/.pip/pip.conf
	@echo "[install]" >> ~/.pip/pip.conf
	@echo "trusted-host = mirrors.aliyun.com pypi.douban.com" >> ~/.pip/pip.conf
	
	$(pwd)/python/bin/pip install mysql-connector

sqlite3:
ifeq ($(wildcard sqlite-autoconf-3250200.tar.gz), $(nullstring))
	wget https://www.sqlite.org/2018/sqlite-autoconf-3250200.tar.gz
endif
ifeq ($(wildcard sqlite-autoconf-3250200), $(nullstring))
	tar -zxvf sqlite-autoconf-3250200.tar.gz
endif
	cd sqlite-autoconf-3250200;\
	./configure --prefix=$(pwd)/sqlite3;\
	make && make install;\
	cd ../
	
	sh bash_profile.sh LD_LIBRARY_PATH=$(pwd)/sqlite3/lib
	#find / -name _sqlite*.so
	#cp /usr/lib/python3.6/lib-dynload/_sqlite3.cpython-36m-x86_64-linux-gnu.so $(pwd)/python3/lib/python3.6/lib-dynload/_sqlite3.so
	