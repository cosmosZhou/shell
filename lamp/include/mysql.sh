# Copyright (C) 2013 - 2023 Teddysun <i@teddysun.com>
# 
# This file is part of the LAMP script.
#
# LAMP is a powerful bash script for the installation of 
# Apache + PHP + MySQL/MariaDB and so on.
# You can install Apache + PHP + MySQL/MariaDB in an very easy way.
# Just need to input numbers to choose what you want to install before installation.
# And all things will be done in a few minutes.
#
# Website:  https://lamp.sh
# Github:   https://github.com/teddysun/lamp

#Pre-installation mysql or mariadb

whoami_grep() {
    short_username=$(echo $(whoami) | awk '{print substr($$0,1,7)}')

    if [ -n "$(echo $(whoami) | awk '{if(length >= 7) {print length;}}')" ]; then
        short_username="$short_username+"
    fi
    echo $short_username
}

mysql_preinstall_settings(){

    if version_lt $(get_libc_version) 2.14; then
        mysql_arr=(${mysql_arr[@]#${mariadb10_3_filename}})
        mysql_arr=(${mysql_arr[@]#${mariadb10_4_filename}})
        mysql_arr=(${mysql_arr[@]#${mariadb10_5_filename}})
        mysql_arr=(${mysql_arr[@]#${mariadb10_6_filename}})
        mysql_arr=(${mysql_arr[@]#${mariadb10_11_filename}})
    fi
    # mariadb 10.6, 10.11 not support 32 bit
    is_64bit || mysql_arr=(${mysql_arr[@]#${mariadb10_6_filename}})
    is_64bit || mysql_arr=(${mysql_arr[@]#${mariadb10_11_filename}})
    display_menu mysql 2

    if [ "${mysql}" != "do_not_install" ];then
        if echo "${mysql}" | grep -qi "mysql"; then
            #mysql data
            echo
            read -p "mysql data location(default:${mysql_location}/data, leave blank for default): " mysql_data_location
            mysql_data_location=${mysql_data_location:=${mysql_location}/data}
            mysql_data_location=$(filter_location "${mysql_data_location}")
            echo
            echo "mysql data location: ${mysql_data_location}"

            #set mysql server root password
            echo
            read -p "mysql server root password (default:lamp.sh, leave blank for default): " mysql_root_pass
            mysql_root_pass=${mysql_root_pass:=lamp.sh}
            echo
            echo "mysql server root password: ${mysql_root_pass}"

        elif echo "${mysql}" | grep -qi "mariadb"; then
            #mariadb data
            echo
            read -p "mariadb data location(default:${mariadb_location}/data, leave blank for default): " mariadb_data_location
            mariadb_data_location=${mariadb_data_location:=${mariadb_location}/data}
            mariadb_data_location=$(filter_location "${mariadb_data_location}")
            echo
            echo "mariadb data location: ${mariadb_data_location}"

            #set mariadb server root password
            echo
            read -p "mariadb server root password (default:lamp.sh, leave blank for default): " mariadb_root_pass
            mariadb_root_pass=${mariadb_root_pass:=lamp.sh}
            echo
            echo "mariadb server root password: $mariadb_root_pass"

        fi
    fi
}

#Install Database common
common_install(){
    local apt_list=(libncurses5 libncurses5-dev cmake m4 bison libaio1 libaio-dev numactl)
    local yum_list=(ncurses-devel cmake m4 bison libaio libaio-devel numactl-devel libevent perl-Data-Dumper)
    _info "Installing dependencies for Database..."
    if check_sys packageManager apt; then
        for depend in ${apt_list[@]}; do
            error_detect_depends "apt-get -y install ${depend}"
        done
    elif check_sys packageManager yum; then
        for depend in ${yum_list[@]}; do
            error_detect_depends "yum -y install ${depend}"
        done
        if centosversion 8 || echo ${opsy} | grep -Eqi "fedora" || echo ${opsy} | grep -Eqi "amazon"; then
            error_detect_depends "yum -y install ncurses-compat-libs"
        fi
        # Fixed libncurses.so.5: cannot open shared object file: No such file or directory
        if is_64bit; then
            if [ ! -e "/usr/lib64/libncurses.so.5" ] && [ -e "/usr/lib64/libncurses.so.6" ]; then
                ln -sf /usr/lib64/libncurses.so.6 /usr/lib64/libncurses.so.5
            fi
            if [ ! -e "/usr/lib64/libtinfo.so.5" ] && [ -e "/usr/lib64/libtinfo.so.6" ]; then
                ln -sf /usr/lib64/libtinfo.so.6 /usr/lib64/libtinfo.so.5
            fi
        else
            if [ ! -e "/usr/lib/libncurses.so.5" ] && [ -e "/usr/lib/libncurses.so.6" ]; then
                ln -sf /usr/lib/libncurses.so.6 /usr/lib/libncurses.so.5
            fi
            if [ ! -e "/usr/lib/libtinfo.so.5" ] && [ -e "/usr/lib/libtinfo.so.6" ]; then
                ln -sf /usr/lib/libtinfo.so.6 /usr/lib/libtinfo.so.5
            fi
        fi
    fi
    _info "Install dependencies for Database completed..."
    id -u mysql >/dev/null 2>&1
    [ $? -ne 0 ] && useradd -M -s /sbin/nologin mysql
    if echo "${mysql}" | grep -qi "mysql"; then
        mkdir -p ${mysql_location} ${mysql_data_location}
    elif echo "${mysql}" | grep -qi "mariadb"; then
        mkdir -p ${mariadb_location} ${mariadb_data_location}
    fi
}

#create mysql cnf
create_mysql_my_cnf(){

    local mysqlDataLocation=${1}
    local binlog=${2}
    local replica=${3}
    local my_cnf_location=${4}

    local memory=512M
    local storage=InnoDB
    local totalMemory=$(awk 'NR==1{print $2}' /proc/meminfo)
    if [[ ${totalMemory} -lt 393216 ]]; then
        memory=256M
    elif [[ ${totalMemory} -lt 786432 ]]; then
        memory=512M
    elif [[ ${totalMemory} -lt 1572864 ]]; then
        memory=1G
    elif [[ ${totalMemory} -lt 3145728 ]]; then
        memory=2G
    elif [[ ${totalMemory} -lt 6291456 ]]; then
        memory=4G
    elif [[ ${totalMemory} -lt 12582912 ]]; then
        memory=8G
    elif [[ ${totalMemory} -lt 25165824 ]]; then
        memory=16G
    else
        memory=32G
    fi

    case ${memory} in
        256M)innodb_log_file_size=32M;innodb_buffer_pool_size=64M;open_files_limit=512;table_open_cache=200;max_connections=64;;
        512M)innodb_log_file_size=32M;innodb_buffer_pool_size=128M;open_files_limit=512;table_open_cache=200;max_connections=128;;
        1G)innodb_log_file_size=64M;innodb_buffer_pool_size=256M;open_files_limit=1024;table_open_cache=400;max_connections=256;;
        2G)innodb_log_file_size=64M;innodb_buffer_pool_size=512M;open_files_limit=1024;table_open_cache=400;max_connections=300;;
        4G)innodb_log_file_size=128M;innodb_buffer_pool_size=1G;open_files_limit=2048;table_open_cache=800;max_connections=400;;
        8G)innodb_log_file_size=256M;innodb_buffer_pool_size=2G;open_files_limit=4096;table_open_cache=1600;max_connections=400;;
        16G)innodb_log_file_size=512M;innodb_buffer_pool_size=4G;open_files_limit=8192;table_open_cache=2000;max_connections=512;;
        32G)innodb_log_file_size=512M;innodb_buffer_pool_size=8G;open_files_limit=65535;table_open_cache=2048;max_connections=1024;;
        *) echo "input error, please input a number";;
    esac

    if ${binlog}; then
        binlog="# BINARY LOGGING #\nlog-bin = ${mysqlDataLocation}/mysql-bin\nserver-id = 1\nexpire-logs-days = 14\nsync-binlog = 1"
        binlog=$(echo -e $binlog)
    else
        binlog="server-id                      = 100"
    fi

    if ${replica}; then
        replica="# REPLICATION #\nrelay-log = ${mysqlDataLocation}/relay-bin\nslave-net-timeout = 60"
        replica=$(echo -e $replica)
    else
        replica=""
    fi

    _info "create my.cnf file..."
    if [[ $(is_root) ]]; then
        socket=/tmp/mysql.sock
        user=mysql
        base=/usr/local
    else
        base=$(get_base)
        socket=$mysql_location/mysql.sock
        user=$(whoami)
    fi


    port=3306
    while true; do
        if ! netstat -an | grep ":$port" > /dev/null; then
            break
        fi
        echo "there exists some pid running on $port!"
        echo $(netstat -nlp | grep ":$port")
        ((port++))
    done

    echo "Available port: $port"

    cat >${my_cnf_location} <<EOF
[client]
# CLIENT #
port                           = ${port}
socket                         = ${socket}
#used in: load data local infile '/tmp/database.table.csv' ignore into table database.table character set utf8mb4;
local-infile                   = ON
default-character-set          = utf8mb4

[mysql]
# command line tool(cli): mysql -hlocalhost -uroot -p
port                           = ${port}
socket                         = ${socket}
local-infile                   = ON
default-character-set          = utf8mb4

[mysqld]
# GENERAL #
port                           = ${port}
user                           = ${user}
default-storage-engine         = ${storage}
socket                         = ${socket}
pid-file                       = $mysql_location/mysql.pid
bind-address                   = 0.0.0.0
character-set-server           = utf8mb4
collation-server               = utf8mb4_unicode_ci

skip-name-resolve
skip-external-locking

# INNODB #
innodb-log-files-in-group      = 2
innodb-log-file-size           = ${innodb_log_file_size}
innodb-flush-log-at-trx-commit = 2
innodb-file-per-table          = 1
innodb-buffer-pool-size        = ${innodb_buffer_pool_size}

# CACHES AND LIMITS #
tmp-table-size                 = 64M
max-heap-table-size            = 32M
max-connections                = ${max_connections}
thread-cache-size              = 50
open-files-limit               = ${open_files_limit}
table-open-cache               = ${table_open_cache}
max_allowed_packet             = 1G
net_read_timeout               = 3000
connect_timeout                = 1000
group_concat_max_len           = 65535


# SAFETY #
max-allowed-packet             = 16M
max-connect-errors             = 1000000
default_authentication_plugin  = mysql_native_password
local-infile                   = ON
# enable federated storage engine
federated
#used in select * from table where some_condition limit 100 into outfile '/tmp/table.csv'
secure_file_priv               = /tmp

# DATA STORAGE #
basedir                        = $mysql_location
datadir                        = ${mysqlDataLocation}
tmpdir                         = ${base}/tmp

# LOGGING #
log-error                      = $mysql_location/error.log
lc-messages-dir                = $mysql_location/share
lc-messages                    = en_US

${binlog}

${replica}

EOF

    _info "create my.cnf file at ${my_cnf_location} completed."
    #my_print_defaults: [Warning] World-writable config file '$mysql_location/my.cnf' is ignored.
    chmod 644 $mysql_location/my.cnf
    cat $mysql_location/my.cnf
}


common_setup(){
    if [[ $(is_root) ]]; then
        rm -f /usr/bin/mysql /usr/bin/mysqldump /usr/bin/mysqladmin
        rm -f /etc/ld.so.conf.d/mysql.conf
    fi

    if [ -d "${mysql_location}" ]; then
        local db_name="MySQL"
        local db_pass="${mysql_root_pass}"
        if [[ $(is_root) ]]; then
            ln -s ${mysql_location}/bin/mysql /usr/bin/mysql
            ln -s ${mysql_location}/bin/mysqldump /usr/bin/mysqldump
            ln -s ${mysql_location}/bin/mysqladmin /usr/bin/mysqladmin
            cp -f ${mysql_location}/support-files/mysql.server /etc/init.d/mysqld
            sed -i "s:^basedir=.*:basedir=${mysql_location}:g" /etc/init.d/mysqld
            sed -i "s:^datadir=.*:datadir=${mysql_data_location}:g" /etc/init.d/mysqld
            create_lib64_dir "${mysql_location}"
            echo "${mysql_location}/lib" >> /etc/ld.so.conf.d/mysql.conf
            echo "${mysql_location}/lib64" >> /etc/ld.so.conf.d/mysql.conf
        fi
    elif [ -d "${mariadb_location}" ]; then
        local db_name="MariaDB"
        local db_pass="${mariadb_root_pass}"
        ln -s ${mariadb_location}/bin/mysql /usr/bin/mysql
        ln -s ${mariadb_location}/bin/mysqldump /usr/bin/mysqldump
        ln -s ${mariadb_location}/bin/mysqladmin /usr/bin/mysqladmin
        cp -f ${mariadb_location}/support-files/mysql.server /etc/init.d/mysqld
        sed -i "s:^basedir=.*:basedir=${mariadb_location}:g" /etc/init.d/mysqld
        sed -i "s:^datadir=.*:datadir=${mariadb_data_location}:g" /etc/init.d/mysqld
        create_lib64_dir "${mariadb_location}"
        echo "${mariadb_location}/lib" >> /etc/ld.so.conf.d/mysql.conf
        echo "${mariadb_location}/lib64" >> /etc/ld.so.conf.d/mysql.conf
    fi

    if [[ $(is_root) ]]; then
        ldconfig
        chmod +x /etc/init.d/mysqld
        boot_start mysqld

        _info "Starting ${db_name}..."
        /etc/init.d/mysqld start > /dev/null 2>&1
        sleep 1
        if [ $? -eq 0 ]; then
            if [ "${mysql}" == "${mysql8_0_filename}" ]; then
                /usr/bin/mysql -uroot -hlocalhost -e "create user root@'127.0.0.1' identified by \"${db_pass}\";"
                /usr/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'127.0.0.1' with grant option;"
                /usr/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'localhost' with grant option;"
                /usr/bin/mysql -uroot -hlocalhost -e "alter user root@'localhost' identified by \"${db_pass}\";"
            else
                /usr/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${db_pass}\" with grant option;"
                /usr/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${db_pass}\" with grant option;"
                /usr/bin/mysql -uroot -p${db_pass} 2>/dev/null <<EOF
drop database if exists test;
delete from mysql.db where user='';
delete from mysql.user where user='';
delete from mysql.user where user='mysql';
flush privileges;
exit
EOF
            fi
        else
            _warn "${mysql} looks like not running, please manually grant privileges for root user if necessary."
        fi

        _info "Shutting down ${db_name}..."
        /etc/init.d/mysqld stop > /dev/null 2>&1
    else
        ${mysql_location}/bin/mysqld_safe --defaults-file=$my_cnf_location &
        _info "Starting ${db_name}..."

        rm $(get_base)/tmp/mysql.sock || true
        ln -s ${mysql_location}/mysql.sock $(get_base)/tmp/mysql.sock
        rm /tmp/mysql.sock || true
        ln -s ${mysql_location}/mysql.sock /tmp/mysql.sock

        while true; do
            echo sleep for 4 seconds
            sleep 4
            echo ${mysql_location}/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'localhost' with grant option;"
            ${mysql_location}/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'localhost' with grant option;" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                break
        fi
        done

        echo ${mysql_location}/bin/mysql -uroot -hlocalhost -e "create database test;"
        ${mysql_location}/bin/mysql -uroot -hlocalhost -e "create database test;"

        echo ${mysql_location}/bin/mysql -uroot -hlocalhost -e "create user test identified by 'test';"
        ${mysql_location}/bin/mysql -uroot -hlocalhost -e "create user test identified by 'test';"
 
        echo ${mysql_location}/bin/mysql -uroot -hlocalhost -e "grant all privileges on test.* to test;"
        ${mysql_location}/bin/mysql -uroot -hlocalhost -e "grant all privileges on test.* to test;"

        echo ${mysql_location}/bin/mysql -uroot -hlocalhost -e "alter user root@'localhost' identified by \"${db_pass}\";"
        ${mysql_location}/bin/mysql -uroot -hlocalhost -e "alter user root@'localhost' identified by \"${db_pass}\";"

        #allow remote connection
        echo ${mysql_location}/bin/mysql -uroot -hlocalhost -p${db_pass} -e "update mysql.user set host = '%' where user = 'root';"
        ${mysql_location}/bin/mysql -uroot -hlocalhost -p${db_pass} -e "update mysql.user set host = '%' where user = 'root';"
        
	    _info "Shutting down ${db_name}..."
	    egrep="^$(whoami_grep)"

        ps -ef | grep mysqld | grep ${mysql_location} | grep -v grep | egrep $egrep
	    ps -ef | grep mysqld | grep ${mysql_location} | grep -v grep | egrep $egrep | awk '{print $2}'
	    echo kill -9 $(ps -ef | grep mysqld | grep ${mysql_location} | grep -v grep | egrep $egrep | awk '{print $2}')
        kill -9 $(ps -ef | grep mysqld | grep ${mysql_location} | grep -v grep | egrep $egrep | awk '{print $2}') || true
    fi

}

#Install mysql server
install_mysqld(){

    common_install

    is_64bit && sys_bit=x86_64 || sys_bit=i686
    mysql_ver=$(echo ${mysql} | sed 's/[^0-9.]//g' | cut -d. -f1-2)
    cd ${cur_dir}/software/
    _info "Downloading and Extracting MySQL files..."

    mysql_filename="${mysql}-linux-glibc2.12-${sys_bit}"
    if [ "${mysql_ver}" == "8.0" ]; then
        # https://downloads.mysql.com/archives/community/
        mysql_filename_url="https://downloads.mysql.com/archives/get/p/23/file/${mysql_filename}.tar.xz"
        # mysql_filename_url="https://cdn.mysql.com/Downloads/MySQL-${mysql_ver}/${mysql_filename}.tar.xz"
        download_file "${mysql_filename}.tar.xz" "${mysql_filename_url}"
        tar Jxf ${mysql_filename}.tar.xz
    else
        mysql_filename_url="https://cdn.mysql.com/Downloads/MySQL-${mysql_ver}/${mysql_filename}.tar.gz"
        download_file "${mysql_filename}.tar.gz" "${mysql_filename_url}"
        tar zxf ${mysql_filename}.tar.gz
    fi

    _info "Moving MySQL files..."
    mv ${mysql_filename}/* ${mysql_location}

    config_mysql ${mysql_ver}
	
	if [[ $(is_root) ]]; then
        add_to_env "${mysql_location}"
    else
        base=$(cd $(dirname $0); pwd)
        base=$(dirname $base)
        base=$(dirname $base)
        echo base = $base
        bash $base/bash_profile.sh PATH=$mysql_location/bin

        cat >${mysql_location}/start.sh <<EOF
#!/usr/bin/env bash
${mysql_location}/bin/mysqld_safe --defaults-file=${my_cnf_location} &
EOF
        egrep=^$(whoami_grep)
        cat >${mysql_location}/stop.sh <<EOF
#!/usr/bin/env bash
__file__=\$(readlink -f "\$0")
mysql_location=\$(dirname "\$__file__")
echo "mysql_location = \$mysql_location"
ps -ef | grep mysqld | grep \$mysql_location | grep -v grep | egrep $egrep
ps -ef | grep mysqld | grep \$mysql_location | grep -v grep | egrep $egrep | awk '{print \$2}'
echo kill -9 \`ps -ef | grep mysqld | grep \$mysql_location | grep -v grep | egrep $egrep | awk '{print \$2}'\`
kill -9 \`ps -ef | grep mysqld | grep \$mysql_location | grep -v grep | egrep $egrep | awk '{print \$2}'\`
EOF

    fi
}

#Configuration mysql
config_mysql(){
    local version=${1}

    if [[ $(is_root) ]]; then
        my_cnf_location=/etc/my.cnf
    else
        my_cnf_location=$mysql_location/my.cnf
    fi

    if [ -f $my_cnf_location ];then
        mv $my_cnf_location $my_cnf_location.bak
    fi
    
    if [[ $(is_root) ]]; then
        #mv /etc/mysql{,_bk} => mv /etc/mysql /etc/mysql_bk
        [ -d '/etc/mysql' ] && mv /etc/mysql{,_bk}

        chown -R mysql:mysql ${mysql_location} ${mysql_data_location}
    else
        chmod -R 777 ${mysql_location}
        mkdir -p $(get_base)/tmp
        chmod -R 777 $(get_base)/tmp
    fi

    #create my.cnf
    create_mysql_my_cnf "${mysql_data_location}" "false" "false" "${my_cnf_location}"

    echo ${mysql_location}/bin/mysqld --defaults-file=$my_cnf_location --initialize-insecure
    ${mysql_location}/bin/mysqld --defaults-file=$my_cnf_location --initialize-insecure

    common_setup

}

#Install mariadb server
install_mariadb(){

    common_install

    if version_lt $(get_libc_version) 2.14; then
        glibc_flag=linux
    else
        glibc_flag=linux-glibc_214
        if [[ "${mysql}" == "${mariadb10_5_filename}" || \
              "${mysql}" == "${mariadb10_6_filename}" || \
              "${mysql}" == "${mariadb10_11_filename}" ]]; then
            glibc_flag=linux-systemd
        fi
    fi

    is_64bit && sys_bit_a=x86_64 || sys_bit_a=x86
    is_64bit && sys_bit_b=x86_64 || sys_bit_b=i686

    mariadb_filename="${mysql}-${glibc_flag}-${sys_bit_b}"
    if [ "$(get_ip_country)" == "CN" ]; then
        mariadb_filename_url="https://mirrors.ustc.edu.cn/mariadb/${mysql}/bintar-${glibc_flag}-${sys_bit_a}/${mariadb_filename}.tar.gz"
    else
        mariadb_filename_url="http://sfo1.mirrors.digitalocean.com/mariadb/${mysql}/bintar-${glibc_flag}-${sys_bit_a}/${mariadb_filename}.tar.gz"
    fi

    cd ${cur_dir}/software/
    download_file "${mariadb_filename}.tar.gz" "${mariadb_filename_url}"

    _info "Extracting MariaDB files..."
    tar zxf ${mariadb_filename}.tar.gz
    _info "Moving MariaDB files..."
    mv ${mariadb_filename}/* ${mariadb_location}

    config_mariadb

    add_to_env "${mariadb_location}"
}

#Configuration mariadb
config_mariadb(){

    if [ -f /etc/my.cnf ];then
        mv /etc/my.cnf /etc/my.cnf.bak
    fi
    [ -d '/etc/mysql' ] && mv /etc/mysql{,_bk}

    chown -R mysql:mysql ${mariadb_location} ${mariadb_data_location}

    #create my.cnf
    create_mysql_my_cnf "${mariadb_data_location}" "false" "false" "/etc/my.cnf"

    ${mariadb_location}/scripts/mysql_install_db --basedir=${mariadb_location} --datadir=${mariadb_data_location} --user=mysql

    common_setup

}
