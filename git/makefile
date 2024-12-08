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
	
update:
ifeq ($(shell uname)==Darwin)
	echo Darwin system
else 
ifeq ($(shell expr substr $(uname -s) 1 5)==Linux)
	echo Darwin system# GNU/Linux操作系统
else
	git update-git-for-windows	 
endif 

	