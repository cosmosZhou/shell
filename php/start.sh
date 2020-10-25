#!/bin/bash
# usage:
# sh start.sh port=7000 pycache dir_module DocumentRoot=/home/zhoulizhi/solution
  
folder=$(dirname $(readlink -f $0))  
if [ -z "$pwd" ]; then	  
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
            *)
                echo illegal parameter: $key
        esac
    elif [ $array_length -eq 1 ]; then
        case $arg in
            pycache)
                pycache=1
                ;;
            stop)
                stop=1
                ;;
            dir_module)
                dir_module=1
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
    sed -i "/ServerName www.example.com:80/a\ServerName localhost:$port" $pwd/httpd/conf/httpd.conf
fi

if [ -n "$DocumentRoot" ]; then
    python $folder"/run.py" subs_document_root $DocumentRoot
fi
         
if [ -n "$pycache" ]; then
    python $folder"/run.py" alter_pycache_permission
fi

if [ -n "$dir_module" ]; then
    python $folder"/run.py" subs_dir_module
fi

#start httpd server
if [ -n "$stop" ]; then
    echo $pwd/httpd/bin/apachectl -k stop
	$pwd/httpd/bin/apachectl -k stop
else
    echo $pwd/httpd/bin/apachectl -k restart
	$pwd/httpd/bin/apachectl -k restart
fi