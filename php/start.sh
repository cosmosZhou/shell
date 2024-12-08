#!/bin/bash
# usage:
# sh start.sh port=8000 DocumentRoot=/mnt/data/yourName/gitlab
# sh start.sh port=80 DocumentRoot=/home/github
  
directory=$(dirname $0)

if [ "$directory" != "." ]; then
    echo directory = $directory
    echo current directory is not the default directory! setting pwd = $directory
    cd $directory && sh $(basename $0) $*
    exit
fi

# folder=$(dirname $(readlink -f $0))  
# if [ -z "$pwd" ]; then	  
	# pwd=$(dirname $(dirname $(dirname $(readlink -f $0))))
# fi
pwd=$HOME
echo pwd = $pwd    

for arg in $*; do
# for arg in "$@"; do
    array=(${arg//=/ })
    
    array_length=${#array[*]}

    if [ $array_length -eq 2 ]; then            
        key=${array[0]}
        value=${array[1]}
        echo key: $key
        echo value: $value
        case $key in
            port)
                port=$value
                echo port = $port                    			
    			sh update.sh $pwd "#Listen " "Listen $port"
    			sh insert.sh $pwd "ServerName www.example.com:80" "ServerName localhost:$port"    
                ;;
            DocumentRoot)
                DocumentRoot=$value
                echo DocumentRoot = $DocumentRoot
                
                echo sed -i "s#^DocumentRoot \".\+\"#DocumentRoot \"$DocumentRoot\"#g" $pwd/httpd/conf/httpd.conf
                sed -i "s#^DocumentRoot \".\+\"#DocumentRoot \"$DocumentRoot\"#g" $pwd/httpd/conf/httpd.conf
    			sh update.sh $pwd "^DocumentRoot \".\+\"" "<Directory \"$DocumentRoot\">"
    			
    			echo sed -i -E "s#(ScriptAlias /cgi-bin/) \".+\"#\1 \"$DocumentRoot\"#" $pwd/httpd/conf/httpd.conf
				sed -i -E "s#(ScriptAlias /cgi-bin/) \".+\"#\1 \"$DocumentRoot\"#" $pwd/httpd/conf/httpd.conf
				    			
                ;;
            *)
                echo illegal parameter: $key
        esac
    elif [ $array_length -eq 1 ]; then
        case $arg in
            stop)
                echo $pwd/httpd/bin/apachectl -k stop
				$pwd/httpd/bin/apachectl -k stop
                exit
                ;;
            *)
                echo illegal parameter: $key
        esac    
    fi
done


#start httpd server
echo kill -9 `ps aux |grep httpd/bin/httpd | grep -v grep | awk '{print $2}'`
kill -9 `ps aux |grep httpd/bin/httpd | grep -v grep | awk '{print $2}'` || true

echo $pwd/httpd/bin/apachectl -k start
$pwd/httpd/bin/apachectl -k start

#~/httpd/bin/apachectl -k restart