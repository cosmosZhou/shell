whoami=$(whoami)
whoami_grep=$(echo $(whoami) | awk '{print substr($$0,1,7)}')

if [ -n "$(echo $(whoami) | awk '{if(length >= 7) {print length;}}')" ]; then
    whoami_grep="$whoami_grep+"
fi

echo whoami_grep = $whoami_grep

echo PID of this script: $(echo $$)
echo PPID of this script: $(echo $PPID)

echo whoami = $whoami
echo whoami_grep = $whoami_grep

echo $1 | awk '{for(i=1;i<=NF;i++){if ($i ~ /=/)print $i;}}' | awk -F'=' '{print $1, $2}'

for assignment in `echo $1 | awk '{for(i=1;i<=NF;i++){if ($i ~ /=/)print $i;}}'`; do \
	symbol=`echo "$assignment" | awk -F'=' '{print $1}'`;
	symbol=`echo ${symbol^^}`;
	expression=`echo "$assignment" | awk -F'=' '{print $2}'`;
	if [[ "$symbol" == "PATH" || "$symbol" == "LD_LIBRARY_PATH" ]];then 
		expression=$expression":$"$symbol;
	fi;
	echo $symbol=$expression;
	if [ `grep -c "$symbol=$expression" ~/.bash_profile` -ne '0' ];then 
		echo "duplicate assignment found in ~/.bash_profile!";
	else 
		echo "export $symbol=$expression" >> ~/.bash_profile;
	fi;
done

source ~/.bash_profile
