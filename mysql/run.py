def sleep(seconds):
	import time
	seconds = int(seconds)	
	print('sleep for %d seconds' % seconds)
	time.sleep(seconds)
    
def mysql_connector():
	import mysql.connector
	mydb = mysql.connector.connect(host='localhost', user='root', password='$(mysql_password)', port=$(mysql_port))
	return mydb, mydb.cursor()

def test():
	mydb, mycursor = mysql_connector()
	mycursor.execute('show databases') 
	for x in mycursor:
		print(x)
	
def discard_tablespace(table):
	sql = 'alter table %s discard tablespace' % table
	print('executing:', sql)
	mydb, mycursor = mysql_connector()
	mycursor.execute('delete from ' + table)
	mycursor.execute(sql)
	sleep(5)
	
def import_tablespace(table):
	sql = 'alter table %s import tablespace' % table
	print('executing:', sql)
	mydb, mycursor = mysql_connector()
	mycursor.execute(sql)
	
if __name__ == '__main__':
	import sys
	cmd, *args = sys.argv[1:]
	eval(cmd)(*args)
