#!/bin/bash
# usage:
# sh start.sh port=7000 pycache DocumentRoot=/home/zhoulizhi/solution
  
folder=$(dirname $(readlink -f $0))  
if [ -n "$pwd" ]; then	  
	pwd=$(dirname $(dirname $(dirname $(readlink -f $0))))
fi

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
                ;;
            DocumentRoot)
                DocumentRoot=$value
                ;;
            pycache)
                pycache=$value
                ;;
            *)
                echo illegal parameter: $key
        esac
    elif [ $array_length -eq 1 ]; then
        case $arg in
            pycache)
                pycache=1
                ;;
            *)
                echo illegal parameter: $key
        esac    
    fi
done

echo port = $port
echo DocumentRoot = $DocumentRoot
echo pycache = $pycache

if [ -n "$port" ]; then
    echo sed -i 's/Listen \d+/Listen $port/' $pwd/httpd/conf/httpd.conf
    sed -i 's/Listen \d+/Listen $port/' $pwd/httpd/conf/httpd.conf
    sed -i '/ServerName www.example.com:80/a\ServerName localhost:$(port)' $pwd/httpd/conf/httpd.conf
fi

if [ -n "$DocumentRoot" ]; then
    python $folder"/run.py" subs_document_root $DocumentRoot
fi
         
if [ -n "$pycache" ]; then
    python $folder"/run.py" alter_pycache_permission
fi

#start httpd server
echo $pwd/httpd/bin/apachectl -k restart
$pwd/httpd/bin/apachectl -k restart