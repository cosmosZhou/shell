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
ServerAdmin=chenlizhibeing@126.com
SSLCertificateFile=cert/www.axiom.top.key_public.crt
SSLCertificateKeyFile=cert/www.axiom.top.key  
SSLCertificateChainFile=cert/www.axiom.top_chain.crt  
 
cp -r $DocumentRoot/cert /usr/local/httpd/
conf=$pwd/httpd/conf/httpd.conf

echo sed -i -E 's/#(LoadModule ssl_module modules\/mod_ssl.so)/\1/' $conf
sed -i -E 's/#(LoadModule ssl_module modules\/mod_ssl.so)/\1/' $conf

echo sed -i -E 's/#(Include conf\/extra\/httpd-ssl.conf)/\1/' $conf
sed -i -E 's/#(Include conf\/extra\/httpd-ssl.conf)/\1/' $conf

echo sed -i -E 's/#(LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so)/\1/' $conf
sed -i -E 's/#(LoadModule socache_shmcb_module modules\/mod_socache_shmcb.so)/\1/' $conf

echo sed -i -E 's/#(LoadModule rewrite_module modules\/mod_rewrite.so)/\1/' $conf
sed -i -E 's/#(LoadModule rewrite_module modules\/mod_rewrite.so)/\1/' $conf


echo "<VirtualHost *:80>" >> $conf<
echo "    RewriteEngine on" >> $conf      
echo "    RewriteCond %{SERVER_PORT} !^443$$" >> $conf  
echo "    RewriteRule ^(.*)$$ https://%{SERVER_NAME}$$1 [L,R]" >> $conf
echo "    </VirtualHost>" >> $conf

conf=$pwd/httpd/conf/extra/httpd-ssl.conf

echo sed -i -E "s#(DocumentRoot) \"/usr/local/httpd/htdocs\"#\1 \"$DocumentRoot\"#" $conf
sed -i -E "s#(DocumentRoot) \".+"#\1 \"$DocumentRoot\"#" $conf

echo sed -i -E "s/(ServerName) .+/\1 $ServerName/" $conf
sed -i -E "s/(ServerName) .+/\1 $ServerName/" $conf

echo sed -i -E "s/(ServerAdmin) .+/\1 $ServerAdmin/" $conf
sed -i -E "s/(ServerAdmin) .+/\1 $ServerAdmin/" $conf

sh ../insert.sh $conf "^SSLEngine on" "SSLHonorCipherOrder on"
sh ../insert.sh $conf "^SSLEngine on" "SSLCipherSuite HIGH:!RC4:!MD5:!aNULL:!eNULL:!NULL:!DH:!EDH:!EXP:+MEDIUM"
sh ../insert.sh $conf "^SSLEngine on" "SSLProtocol all -SSLv2 -SSLv3" 


echo sed -i -E "s#(^SSLCertificateFile) \".+\"#\1 \"$SSLCertificateFile\"#" $conf
sed -i -E "s#(^SSLCertificateFile) \".+\"#\1 \"$SSLCertificateFile\"#" $conf

echo  sed -i -E "s#(^SSLCertificateKeyFile) \".+\"#\1 \"$SSLCertificateKeyFile\"#" $conf
sed -i -E "s#(^SSLCertificateKeyFile) \".+\"#\1 \"$SSLCertificateKeyFile\"#" $conf

echo sed -i -E 's/\#(SSLCertificateChainFile)/\1/' $conf
sed -i -E 's/\#(SSLCertificateChainFile)/\1/' $conf

echo sed -i -E "s#(^SSLCertificateChainFile) \".+\"#\1 \"$SSLCertificateChainFile\"#" $conf
sed -i -E "s#(^SSLCertificateChainFile) \".+\"#\1 \"$SSLCertificateChainFile\"#" $conf


$pwd/httpd/bin/apachectl -k restart
