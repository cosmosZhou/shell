alter user 'root'@'localhost' identified by '$(mysql_password)';
update user set host = '%' where user = 'root';
flush privileges;