password =\`cat error.log | grep 'A temporary password is generated for' | awk '{print \$$\$$NF}'\`
	
all:
	make try || make
	
try:
	python run.py sleep 1
	cat error.log | grep 'A temporary password is generated for' | awk '{print \$$\$$NF}'
	@echo password = \$$(password)
	bin/mysql --connect-expired-password -uroot -Dmysql -p\$$(password) < $(pwd)/mysql/init.sql
	python run.py test	

clean: stop
	rm -rf $(pwd)/mysql
	
load_data:
	python run.py discard_tablespace \$$(table)	
	make database=\`echo \$$(table) | awk -F'.' '{print \$$\$$1}'` table=`echo \$$(table) | awk -F'.' '{print \$$\$$2}'\` copy
	python run.py import_tablespace \$$(table)
		
copy:
	for file in \`ls ../bypy/\$$(database)/\$$(table)*.ibd\`; do \\
		filename=\`echo \$$(basename \$$file)\`;\\	
		filename=\`echo \$${filename/\\#p\\#/\\#P\\#}\`;\\
		cp \$$file data/\$$database/\$$filename;\\
	done
		
stop:
	ps -ef | grep mysql | grep -v grep | egrep -v make.+clean | grep $(whoami)		
	ps -ef | grep mysql | grep -v grep | egrep -v make.+clean | grep $(whoami) | awk '{print \$$\$$2}'	
	-kill -9 \`ps -ef | grep mysql | grep -v grep | egrep -v make.+clean | grep $(whoami) | awk '{print \$$\$$2}'\`

restart: stop
	bin/mysqld_safe --defaults-file=$(pwd)/mysql/my.cnf --user=$(whoami) &		

start:
	bin/mysqld_safe --defaults-file=$(pwd)/mysql/my.cnf --user=$(whoami) &		
	