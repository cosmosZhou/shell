
get_base() {
    echo $(cd ~; pwd)
}

load_config(){
    #Install location
    base=$(get_base)
    mysql_location=$base/mysql

    #Install depends location
    depends_prefix=$base

    echo mysql_location = $mysql_location

    ##Software version
    #mysql8.0
    mysql8_0_filename="mysql-8.0.33"
}

is_64bit(){
    if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ]; then
        return 0
    else
        return 1
    fi
}

whoami_grep() {
    short_username=$(echo $(whoami) | awk '{print substr($$0,1,7)}')

    if [ -n "$(echo $(whoami) | awk '{if(length >= 7) {print length;}}')" ]; then
        short_username="$short_username+"
    fi
    echo $short_username
}

mysql_preinstall_settings(){

    mysql=${mysql8_0_filename}
    #mysql data
    echo
    mysql_data_location=${mysql_location}/data
    echo
    echo "mysql data location: ${mysql_data_location}"

    #set mysql server root password
    echo
    mysql_root_pass=123456
    echo "mysql server root password: ${mysql_root_pass}"
}

#Install Database common
common_install(){
    mkdir -p ${mysql_location} ${mysql_data_location}
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

    echo "create my.cnf file..."
    socket=$mysql_location/mysql.sock
    user=$(whoami)
    base=$(get_base)


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

    echo "create my.cnf file at ${my_cnf_location} completed."
    #my_print_defaults: [Warning] World-writable config file '$mysql_location/my.cnf' is ignored.
    chmod 644 $mysql_location/my.cnf
    cat $mysql_location/my.cnf
}


common_setup(){
    local db_name="MySQL"
    local db_pass="${mysql_root_pass}"

    ${mysql_location}/bin/mysqld_safe --defaults-file=$my_cnf_location &
    echo "Starting ${db_name}..."

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
    
    echo "Shutting down ${db_name}..."
    egrep="^$(whoami_grep)"

    ps -ef | grep mysqld | grep ${mysql_location} | grep -v grep | egrep $egrep
    ps -ef | grep mysqld | grep ${mysql_location} | grep -v grep | egrep $egrep | awk '{print $2}'
    echo kill -9 $(ps -ef | grep mysqld | grep ${mysql_location} | grep -v grep | egrep $egrep | awk '{print $2}')
    kill -9 $(ps -ef | grep mysqld | grep ${mysql_location} | grep -v grep | egrep $egrep | awk '{print $2}') || true

}

#Configuration mysql
config_mysql(){
    local version=${1}

    my_cnf_location=$mysql_location/my.cnf

    if [ -f $my_cnf_location ];then
        mv $my_cnf_location $my_cnf_location.bak
    fi
    
    # chown -R mysql:mysql ${mysql_location} ${mysql_data_location}
    chmod -R 777 ${mysql_location}
    mkdir -p $(get_base)/tmp
    chmod -R 777 $(get_base)/tmp

    #create my.cnf
    create_mysql_my_cnf "${mysql_data_location}" "false" "false" "${my_cnf_location}"

    echo ${mysql_location}/bin/mysqld --defaults-file=$my_cnf_location --initialize-insecure
    ${mysql_location}/bin/mysqld --defaults-file=$my_cnf_location --initialize-insecure

    common_setup
}


#Install mysql server
install_mysqld(){

    common_install

    mysql_ver=$(echo ${mysql} | sed 's/[^0-9.]//g' | cut -d. -f1-2)
    cd ${cur_dir}

    config_mysql ${mysql_ver}
	
    base=$(cd $(dirname $0); pwd)
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

}


#Finally to do
install_finally(){
    echo "Cleaning up..."
    cd ${cur_dir}
    #rm -rf ${cur_dir}/software
    echo "Clean up completed..."

    echo
    echo "------------------------ Installed Overview -------------------------"
    echo
    echo "Database: ${mysql}"
    echo "MySQL Location: ${mysql_location}"
    echo "MySQL Data Location: ${mysql_data_location}"
    echo "MySQL Root Password: ${mysql_root_pass}"
    dbrootpwd=${mysql_root_pass}
    echo

    # ldconfig

    echo "Starting Database..."
    echo $mysql_location/bin/mysqld_safe --defaults-file=$my_cnf_location  &
    $mysql_location/bin/mysqld_safe --defaults-file=$my_cnf_location &

    sleep 1
    netstat -tunlp
    exit 0
}

load_config
install_mysqld
install_finally