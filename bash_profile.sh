whoami = $(shell whoami)
whoami_grep = $(shell echo $(whoami) | awk '{print substr($$0,1,7)}')

ifneq ($(shell echo $(whoami) | awk '{if(length >= 7) {print length;}}'), $(nullstring))
	whoami_grep :=$(whoami_grep)+
endif

echo PID of this script: $(shell echo "$$$$")
echo PPID of this script: $(shell echo "$$PPID")

echo whoami = $(whoami)	
echo whoami_grep = $(whoami_grep)

ps -ef | grep make | grep -v grep | grep $(whoami_grep) | awk '{if ($$2==$(shell echo "$$PPID")) print}' | awk '{for(i=1;i<=NF;i++){if ($$i ~ /=/)print $$i;}}' | awk -F'=' '{print $$1, $$2}'

for assignment in `ps -ef | grep make | grep -v grep | grep $(whoami_grep) | awk '{if ($$2==$(shell echo "$$PPID")) print}' | awk '{for(i=1;i<=NF;i++){if ($$i ~ /=/)print $$i;}}'`; do \
	symbol=`echo "$$assignment" | awk -F'=' '{print $$1}'`;
	symbol=`echo $${symbol^^}`;
	expression=`echo "$$assignment" | awk -F'=' '{print $$2}'`;
	if [[ "$$symbol" == "PATH" || "$$symbol" == "LD_LIBRARY_PATH" ]];then 
		expression=$$expression":$$"$$symbol;
	fi;
	echo $$symbol=$$expression;
	if [ `grep -c "$$symbol=$$expression" ~/.bash_profile` -ne '0' ];then 
		echo "duplicate assignment found in ~/.bash_profile!";
	else 
		echo "export $$symbol=$$expression" >> ~/.bash_profile;
	fi;
done

source ~/.bash_profile
