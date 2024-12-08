nullstring :=#end of the line
pwd =$(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))#pwd

pwd := $(shell dirname $(pwd))
pwd := $(shell dirname $(pwd))
$(info pwd = $(pwd))

redis_version =5.0.8#redis_version
redis:
ifeq ($(wildcard redis-$(redis_version).tar.gz), $(nullstring))
	wget http://download.redis.io/releases/redis-$(redis_version).tar.gz
endif

ifeq ($(wildcard redis-$(redis_version)), $(nullstring))
	tar -zxf redis-$(redis_version).tar.gz
endif

	mv redis-$(redis_version) redis
	cd redis && make 
	cd redis/src && make PREFIX=$(pwd)/redis install
	cp redis/redis.conf $(pwd)/redis/
	
conf:	
	sed -i 's/^daemonize no/daemonize yes/' $(pwd)/redis/redis.conf
	sed -i "s/^protected-mode yes/protected-mode no/" $(pwd)/redis/redis.conf
	sed -i "s/^bind 127.0.0.1/#bind 127.0.0.1/" $(pwd)/redis/redis.conf
	
	