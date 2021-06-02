#!/bin/bash
# usage:
# sh start.sh
  
directory=$(dirname $0)

if [ "$directory" != "." ]; then
    echo directory = $directory
    echo current directory is not the default directory! setting pwd = $directory
    cd $directory && sh $(basename $0) $*
    exit
fi

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
            *)
                echo illegal parameter: $key
        esac
    elif [ $array_length -eq 1 ]; then
        case $arg in
            stop)
                stop=1
                ;;
            *)
                echo illegal parameter: $key
        esac    
    fi
done

#start httpd server
if [ -n "$stop" ]; then
    echo ps aux | grep redis | grep -v grep
    ps aux | grep redis | grep -v grep
    echo cd $pwd/redis/bin && ./redis-cli shutdown
    cd $pwd/redis/bin && ./redis-cli shutdown
else
    echo cd $pwd/redis && ./bin/redis-server redis.conf
    cd $pwd/redis && ./bin/redis-server redis.conf
fi