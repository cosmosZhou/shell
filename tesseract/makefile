

nullstring :=#end of the line
pwd =$(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))#pwd

pwd := $(shell dirname $(pwd))
pwd := $(shell dirname $(pwd))
$(info pwd = $(pwd))


libtool_version =2.4.6
libtool: 
ifeq ($(wildcard libtool-$(libtool_version).tar.gz), $(nullstring))
	wget http://ftpmirror.gnu.org/libtool/libtool-$(libtool_version).tar.gz	
endif

ifeq ($(wildcard libtool-$(libtool_version)), $(nullstring))
	tar xzvf libtool-$(libtool_version).tar.gz
endif

#skip compiling
ifeq ($(wildcard $(pwd)/libtool), $(nullstring))
	cd libtool-$(libtool_version) && ./configure --prefix=${pwd}/libtool && make && make install
	bash ../bash_profile.sh PATH=$(pwd)/libtool/bin
endif

	
autoconf_version =2.69
autoconf: m4
ifeq ($(wildcard autoconf-$(autoconf_version).tar.gz), $(nullstring))
	wget http://mirrors.kernel.org/gnu/autoconf/autoconf-$(autoconf_version).tar.gz	
endif

ifeq ($(wildcard autoconf-$(autoconf_version)), $(nullstring))
	tar -zxvf autoconf-$(autoconf_version).tar.gz
endif

#skip compiling
ifeq ($(wildcard $(pwd)/autoconf), $(nullstring))
	tar -xzvf autoconf-$(autoconf_version).tar.gz
	cd autoconf-$(autoconf_version) && ./configure --prefix=${pwd}/autoconf && make -j8 && make install
	bash ../bash_profile.sh PATH=$(pwd)/autoconf/bin
endif


automake_version =1.16.1
automake: autoconf
ifeq ($(wildcard leptonica-$(leptonica_version).tar.gz), $(nullstring))
	wget -c --no-check-certificate https://ftp.gnu.org/gnu/automake/automake-$(automake_version).tar.gz	
endif
	
ifeq ($(wildcard leptonica-$(leptonica_version)), $(nullstring))
	tar -zxvf automake-$(automake_version).tar.gz
endif
#skip compiling
ifeq ($(wildcard $(pwd)/automake), $(nullstring))
	cd automake-$(automake_version) && ./configure --prefix=${pwd}/automake && make -j8 && make install
	bash ../bash_profile.sh PATH=$(pwd)/automake/bin
endif	

#check from http://www.leptonica.org/download.html
leptonica_version =1.78.0#leptonica_version
leptonica:
ifeq ($(wildcard leptonica-$(leptonica_version).tar.gz), $(nullstring))
	wget http://www.leptonica.org/source/leptonica-$(leptonica_version).tar.gz	
endif

ifeq ($(wildcard leptonica-$(leptonica_version)), $(nullstring))
	tar -zxvf leptonica-$(leptonica_version).tar.gz
endif
#skip compiling
ifeq ($(wildcard $(pwd)/leptonica), $(nullstring))
	cd leptonica-$(leptonica_version) && ./configure --prefix=$(pwd)/leptonica && make && make install
	bash ../bash_profile.sh PKG_CONFIG_PATH=$(pwd)/leptonica/lib/pkgconfig
	bash ../bash_profile.sh CPLUS_INCLUDE_PATH=$(pwd)/leptonica/include
	bash ../bash_profile.sh C_INCLUDE_PATH=$(pwd)/leptonica/include
	bash ../bash_profile.sh LD_LIBRARY_PATH=$(pwd)/leptonica/lib
	bash ../bash_profile.sh LIBRARY_PATH=$(pwd)/leptonica/lib
	bash ../bash_profile.sh LIBLEPT_HEADERSDIR=$(pwd)/leptonica/include/leptonica
endif


tesseract_version =4.1.3#tesseract_version
tesseract: leptonica
ifeq ($(wildcard tesseract-$(tesseract_version).tar.gz), $(nullstring))	
	wget --no-check-certificate https://github.com/tesseract-ocr/tesseract/archive/refs/tags/$(tesseract_version).tar.gz -O tesseract-$(tesseract_version).tar.gz
	#wget http://tesseract-ocr.googlecode.com/files/tesseract-$(tesseract_version).tar.gz
endif

ifeq ($(wildcard tesseract-$(tesseract_version)), $(nullstring))
	tar -zxvf tesseract-$(tesseract_version).tar.gz
endif

	cd tesseract-$(tesseract_version) && ./autogen.sh && ./configure --prefix=$(pwd)/tesseract && make && make install
	bash ../bash_profile.sh PATH=$(pwd)/tesseract/bin
	bash ../bash_profile.sh PKG_CONFIG_PATH=$(pwd)/tesseract/lib/pkgconfig
	bash ../bash_profile.sh LD_LIBRARY_PATH=$(pwd)/tesseract/lib
	#tesseract --tessdata-dir $(pwd)/tesseract/tessdata
	#pip install tesserocr==2.5.1
#https://github.com/tesseract-ocr/tesseract/releases?page=2
#https://codeload.github.com/tesseract-ocr/tessdata/tar.gz/refs/tags/4.0.0.tar.gz
#https://codeload.github.com/tesseract-ocr/tessdata/tar.gz/refs/tags/4.0.0

#windowns version:
#http://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-setup-4.00.00dev.exe
#http://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-v4.1.0.20190314.exe