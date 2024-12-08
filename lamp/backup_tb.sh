# name_db = "corpus"
# name_table = "reward"
# /home/lizhi/mysql8/bin/mysql -uroot -hlocalhost -e "create user root@'127.0.0.1' identified by \"${db_pass}\";"
# /usr/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'127.0.0.1' with grant option;"
# /usr/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'localhost' with grant option;"
# /usr/bin/mysql -uroot -hlocalhost -e "alter user root@'localhost' identified by \"${db_pass}\";"

# /usr/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${db_pass}\" with grant option;"
# /usr/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${db_pass}\" with grant option;"
# /usr/bin/mysql -uroot -p${db_pass} 2>/dev/null <<EOF
# drop database if exists test;
# delete from mysql.db where user='';
# delete from mysql.user where user='';
# delete from mysql.user where user='mysql';
# flush privileges;
# exit
# EOF


#!/bin/bash

OPTIONS=$(getopt -o basedir:,database:,table:,hostport:,password: --long basedir:,database:,table:,hostport:,password: -- "$@")
if [ $? -ne 0 ]; then
  echo "Error in passing parameters while executing the script"
  exit 1
fi
eval set -- "$OPTIONS"

# echo "Options: $@"
# echo "Options: $*"

while true; do
  case "$1" in
    --basedir)
      shift
      basedir="$1"
      ;;
    --database)
      shift
      database="$1"
      ;;
    --table)
      shift
      table="$1"
      ;;
    --hostport)
      shift
      IFS=',' read -ra hostport <<< "$1"
      hostport1=${hostport[0]}
      hostport2=${hostport[1]}
      ;;
    --password)
      shift
      IFS=',' read -ra password <<< "$1"
      user_pass1=${password[0]}
      user_pass2=${password[1]}
      ;;
    --)
      break
      ;;
    *)
      break
      ;;
  esac
  shift
done

#step1 分析输入参数
echo "basedir: $basedir"
echo "database: $database"
echo "table: $table"
echo "from $hostport1 to $hostport2"
echo "user_pass1:$user_pass1"
echo "user_pass2:$user_pass2"

if [ -z "$database" ]; then
  echo "database is defaulted to 'corpus' if not provided."
  database="corpus"
  if [ -z "$table" ]; then
    echo "database get, table not provided, backup database: $database"
  else
    echo "database get, table get, backup database: $database, table: $table"
  fi
else 
  if [ -z "$table" ]; then
    echo "database get,table not provided, backup database: $database"
  else
    echo "database get, table get, backup database: $database, table: $table"
  fi
fi

host1="${hostport1%:*}"
port1="${hostport1#*:}"
host2="${hostport2%:*}"
port2="${hostport2#*:}"

echo "port1: $port1"
echo "port2: $port2"
echo "database: $database"
# step2 backup database structure show create table
show_create_database=$($basedir/bin/mysql -uroot -h$host1 -P$port1 -p"$user_pass1" -e "show create database $database;" )
database_sql=$(echo "show create database: $show_create_database" | sed -e '1d' -e "2s/^${database}\s\+//")
echo "$database_sql"
echo ".........................................................."
show_create_table=$($basedir/bin/mysql -uroot -h$host1 -P$port1 -p"$user_pass1" -e "show create table $database.$table;")
table_sql=$(echo "$show_create_table" | sed -e '1d' -e "2s/^${table}\s\+//")
echo "$table_sql"

#如果那个备份的hostport已经有了database和table，则删除原有的数据，删除database和table,然后再创建新的database和table,然后再执行备份

# 检查数据库是否存在
db_exist=$($basedir/bin/mysql -uroot -h$host2 -P$port2 -p"$user_pass2" -e "SHOW DATABASES LIKE '$database';")
if [ "$db_exist" ]; then
    echo "Database $database exists on $host2:$port2. Keeping it."
else
    echo "Database $database does not exist on $host2:$port2. Creating it."
    # 创建数据库
    echo "Creating new database $database on $host2:$port2."
    $basedir/bin/mysql -uroot -h$host2 -P$port2 -p"$user_pass2" -e "$database_sql;"
fi



# 检查表是否存在，存在则删除重建
table_exist=$($basedir/bin/mysql -uroot -h$host2 -P$port2 -p"$user_pass2" -e "SHOW TABLES IN $database LIKE '$table';")
if [ "$table_exist" ]; then
    echo "Table $table exists in database $database on $host2:$port2. Removing it."
    $basedir/bin/mysql -uroot -h$host2 -P$port2 -p"$user_pass2" -e "DROP TABLE IF EXISTS $database.$table;"
fi

# 创建表（这里 show_create_table 命令已经提前生成，包含创建表的 SQL 命令）
echo "Creating new table $table in database $database on $host2:$port2."
$basedir/bin/mysql -uroot -h$host2 -P$port2 -p"$user_pass2" -e "USE $database; $table_sql;"

# 使用 mysql的.ibd文件操作备份
# 先把新建的表ALTER TABLE recovered_table DISCARD TABLESPACE;丢弃表空间

# 丢弃新建表的表空间
echo "正在丢弃 $host2:$port2 上 $database 数据库中 $table 表的表空间。"
$basedir/bin/mysql -uroot -h$host2 -P$port2 -p"$user_pass2" -e "ALTER TABLE $database.$table DISCARD TABLESPACE;"


# 执行MySQL命令，并将结果赋值给data_dir变量
data_dir_1=$($basedir/bin/mysql -uroot -h$host1 -P$port1 -p"$user_pass1" -e "SHOW VARIABLES LIKE 'datadir';" -s -N | awk '{print $2}')
data_dir_2=$($basedir/bin/mysql -uroot -h$host2 -P$port2 -p"$user_pass2" -e "SHOW VARIABLES LIKE 'datadir';" -s -N | awk '{print $2}')
# 打印获取的数据目录路径
echo "MySQL data directory on $host1:$port1 is: $data_dir_1"
echo "MySQL data directory on $host2:$port2 is: $data_dir_2"


# 此时，您需要手动将.ibd文件从源服务器复制到目标服务器
# 假设.ibd文件位于源服务器的 /var/lib/mysql/$database/ 目录并命名为 $table.ibd
# 您应该将这个文件复制到 $host2 上相同的目录

# 注意：这一步是很危险的，并涉及系统级文件操作
# 作为示例，您可能会在源机器上使用以下命令（根据需要调整路径和详细信息）:
# mv /$data_dir_1/$database/$table.ibd /$data_dir_2/$database/
cp /$data_dir_1/$database/$table#p#*.ibd /$data_dir_2/$database/

# 复制完成后，您需要在目标服务器上导入表空间
# scp /var/lib/mysql/$database/$table.ibd 用户名@$host2:/var/lib/mysql/$database/

# 将.ibd文件放到$host2上正确的目录之后，继续导入表空间
echo "正在导入 $host2:$port2 上 $database 数据库 $table 表的表空间。"
$basedir/bin/mysql -uroot -h$host2 -P$port2 -p"$user_pass2" -e "ALTER TABLE $database.$table IMPORT TABLESPACE;"

# 校验
# 为了验证表是否成功导入，您可以检查表中的行数或尝试访问数据。
echo "正在校验 $table 表中的数据。"

row_count_1=$($basedir/bin/mysql -uroot -h$host1 -P$port1 -p"$user_pass1" -e "SELECT COUNT(*) AS count FROM $database.$table;")
row_count_2=$($basedir/bin/mysql -uroot -h$host2 -P$port2 -p"$user_pass2" -e "SELECT COUNT(*) AS count FROM $database.$table;")

echo "原$table 表的行数: $row_count_1"
echo "新的$table 表的行数: $row_count_2"

assert "$row_count_1" -eq "$row_count_2" "行数校验失败。"

echo "数据校验成功。"
# 脚本到此结束，但在真实场景中，可能需要添加更多的错误检查、日志记录或恢复程序。
echo "数据库及表迁移完成。"