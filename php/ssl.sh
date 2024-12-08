#!/bin/bash
# usage:
# sh ssl.sh

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

DocumentRoot=/home/github
ServerName=www.axiom.top
ServerAdmin=myName@126.com
SSLCertificateFile=cert/www.axiom.top_public.crt
SSLCertificateKeyFile=cert/www.axiom.top.key
SSLCertificateChainFile=cert/www.axiom.top_chain.crt

cp -r $DocumentRoot/cert /usr/local/httpd/
conf=$pwd/httpd/conf/httpd.conf

echo conf = $conf
echo DocumentRoot = $DocumentRoot
echo ServerName = $ServerName
echo ServerAdmin = $ServerAdmin
echo SSLCertificateFile = $SSLCertificateFile
echo SSLCertificateKeyFile = $SSLCertificateKeyFile
echo SSLCertificateChainFile = $SSLCertificateChainFile

echo sed -i -E 's/#(LoadModule ssl_module modules\/mod_ssl.so)/\1/' $conf
sed -i -E 's/#(LoadModule ssl_module modules\/mod_ssl.so)/\1/' $conf

echo sed -i -E 's/#(Include conf\/extra\/httpd-ssl.conf)/\1/' $conf
sed -i -E 's/#(Include conf\/extra\/httpd-ssl.conf)/\1/' $conf

echo sed -i -E 's/#(LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so)/\1/' $conf
sed -i -E 's/#(LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so)/\1/' $conf

echo sed -i -E 's/#(LoadModule rewrite_module modules\/mod_rewrite.so)/\1/' $conf
sed -i -E 's/#(LoadModule rewrite_module modules\/mod_rewrite.so)/\1/' $conf

count=$(grep "<VirtualHost \*:80>" /usr/local/httpd/conf/httpd.conf | wc -l)
echo count = $count

if [ "$count" == "0" ]; then
echo "<VirtualHost *:80>" >> $conf
echo "    RewriteEngine on" >> $conf
echo "    RewriteCond %{SERVER_PORT} !^443\$" >> $conf
echo "    RewriteRule ^(.*)\$ https://%{SERVER_NAME}\$1 [L,R]" >> $conf
echo "</VirtualHost>" >> $conf
fi

conf=$pwd/httpd/conf/extra/httpd-ssl.conf
echo conf = $conf

echo sed -i -E "s#(^DocumentRoot) \".+\"#\1 \"$DocumentRoot\"#" $conf
sed -i -E "s#(^DocumentRoot) \".+\"#\1 \"$DocumentRoot\"#" $conf


echo sed -i -E "s/(^ServerName) .+/\1 $ServerName/" $conf
sed -i -E "s/(^ServerName) .+/\1 $ServerName/" $conf


echo sed -i -E "s/(^ServerAdmin) .+/\1 $ServerAdmin/" $conf
sed -i -E "s/(^ServerAdmin) .+/\1 $ServerAdmin/" $conf



sh ../insert.sh $conf "SSLEngine on" "SSLProtocol all -SSLv2 -SSLv3"
sh ../insert.sh $conf "SSLProtocol all -SSLv2 -SSLv3" "SSLCipherSuite HIGH:!RC4:!MD5:!aNULL:!eNULL:!NULL:!DH:!EDH:!EXP:+MEDIUM"
sh ../insert.sh $conf "SSLCipherSuite HIGH:!RC4:!MD5:!aNULL:!eNULL:!NULL:!DH:!EDH:!EXP:+MEDIUM" "SSLHonorCipherOrder on"


echo sed -i -E "s#(^SSLCertificateFile) \".+\"#\1 \"$SSLCertificateFile\"#" $conf
sed -i -E "s#(^SSLCertificateFile) \".+\"#\1 \"$SSLCertificateFile\"#" $conf


echo  sed -i -E "s#(^SSLCertificateKeyFile) \".+\"#\1 \"$SSLCertificateKeyFile\"#" $conf
sed -i -E "s#(^SSLCertificateKeyFile) \".+\"#\1 \"$SSLCertificateKeyFile\"#" $conf

echo sed -i -E 's/#(SSLCertificateChainFile)/\1/' $conf
sed -i -E 's/#(SSLCertificateChainFile)/\1/' $conf


echo sed -i -E "s#(^SSLCertificateChainFile) \".+\"#\1 \"$SSLCertificateChainFile\"#" $conf
sed -i -E "s#(^SSLCertificateChainFile) \".+\"#\1 \"$SSLCertificateChainFile\"#" $conf

$pwd/httpd/bin/apachectl -k restart