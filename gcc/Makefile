

nullstring :=#end of the line
pwd =$(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))#pwd

pwd := $(shell dirname $(pwd))
pwd := $(shell dirname $(pwd))
$(info pwd = $(pwd))


#https://mirrors.tuna.tsinghua.edu.cn/gnu/m4/m4-1.4.17.tar.gz
m4_version =1.4.18
m4: 
ifeq ($(wildcard m4-$(m4_version).tar.gz), $(nullstring))
	wget http://mirrors.kernel.org/gnu/m4/m4-$(m4_version).tar.gz	
endif

ifeq ($(wildcard m4-$(m4_version)), $(nullstring))
	tar -xzvf m4-$(m4_version).tar.gz
endif

#skip compiling
ifeq ($(wildcard $(pwd)/m4), $(nullstring))
	cd m4-$(m4_version) && ./configure --prefix=${pwd}/m4 && make -j8 && make install
	bash ../bash_profile.sh PATH=$(pwd)/m4/bin
endif

#https://mirrors.tuna.tsinghua.edu.cn/gnu/gmp/gmp-4.3.2.tar.gz
gmp_version =4.3.2
gmp: 
ifeq ($(wildcard gmp-$(gmp_version).tar.gz), $(nullstring))
	wget --no-check-certificate https://mirrors.tuna.tsinghua.edu.cn/gnu/gmp/gmp-$(gmp_version).tar.gz	
endif

ifeq ($(wildcard gmp-$(gmp_version)), $(nullstring))
	tar -xzvf gmp-$(gmp_version).tar.gz
endif

#skip compiling
ifeq ($(wildcard $(pwd)/gmp), $(nullstring))
	cd gmp-$(gmp_version) && ./configure --prefix=$(pwd)/gmp && make -j4 && make install
	bash ../bash_profile.sh PATH=$(pwd)/gmp/bin
	bash ../bash_profile.sh LD_LIBRARY_PATH=$(pwd)/gmp/lib
endif


mpfr_version =2.4.2
mpfr: gmp
ifeq ($(wildcard mpfr-$(mpfr_version).tar.gz), $(nullstring))
	wget --no-check-certificate https://mirrors.tuna.tsinghua.edu.cn/gnu/mpfr/mpfr-$(mpfr_version).tar.gz	
endif

ifeq ($(wildcard mpfr-$(mpfr_version)), $(nullstring))
	tar -xzvf mpfr-$(mpfr_version).tar.gz
endif

#skip compiling
ifeq ($(wildcard $(pwd)/mpfr), $(nullstring))
	cd mpfr-$(mpfr_version) && ./configure --prefix=$(pwd)/mpfr --with-gmp-include=$(pwd)/gmp/include --with-gmp-lib=$(pwd)/gmp/lib && make -j4 && make install
	bash ../bash_profile.sh LD_RUN_PATH=$(pwd)/mpfr/lib
	bash ../bash_profile.sh LD_LIBRARY_PATH=$(pwd)/mpfr/lib
endif


mpc_version =0.8.1
mpc: gmp mpfr
ifeq ($(wildcard mpc-$(mpc_version).tar.gz), $(nullstring))
	wget --no-check-certificate https://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz	
endif

ifeq ($(wildcard mpc-$(mpc_version)), $(nullstring))
	tar -xzvf mpc-$(mpc_version).tar.gz
endif

#skip compiling
ifeq ($(wildcard $(pwd)/mpc), $(nullstring))
	cd mpc-$(mpc_version) && \
	./configure --prefix=$(pwd)/mpc --with-gmp-include=$(pwd)/gmp/include --with-gmp-lib=$(pwd)/gmp/lib --with-mpfr-include=$(pwd)/mpfr/include --with-mpfr-lib=$(pwd)/mpfr/lib && \
	make -j4 && make install
	bash ../bash_profile.sh LD_LIBRARY_PATH=$(pwd)/mpc/lib
endif



gcc_version =7.1.0
gcc: gmp mpfr mpc
ifeq ($(wildcard gcc-$(gcc_version).tar.gz), $(nullstring))
	wget --no-check-certificate https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-$(gcc_version)/gcc-$(gcc_version).tar.gz	
endif

ifeq ($(wildcard gcc-$(gcc_version)), $(nullstring))
	tar -xzvf gcc-$(gcc_version).tar.gz
endif

#skip compiling
ifeq ($(wildcard $(pwd)/gcc), $(nullstring))
	unset LIBRARY_PATH CPATH C_INCLUDE_PATH PKG_CONFIG_PATH CPLUS_INCLUDE_PATH INCLUDE && \
	cd gcc-$(gcc_version) && \
	./configure --prefix=$(pwd)/gcc \
	--with-gmp-include=$(pwd)/gmp/include \
	--with-gmp-lib=$(pwd)/gmp/lib \
	--with-mpfr-include=$(pwd)/mpfr/include \
	--with-mpfr-lib=$(pwd)/mpfr/lib \
	--with-mpc-include=$(pwd)/mpc/include \
	--with-mpc-lib=$(pwd)/mpc/lib \
	-enable-languages=c,c++ -disable-multilib && \
	make -j8 && make install
	bash ../bash_profile.sh LD_LIBRARY_PATH=$(pwd)/gcc/lib64
	bash ../bash_profile.sh PATH=$(pwd)/gcc/bin
endif

#note: 
#configure: error: cannot compute suffix of object files: cannot compile
#close the shell window and start a new one!


# https://blog.csdn.net/Bessenn/article/details/120684864
# upgrade to gcc7 in centos system: 
# yum -y install centos-release-scl 
# yum -y install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils
# echo "source /opt/rh/devtoolset-7/enable" >>/etc/profile.d/gcc7.sh 