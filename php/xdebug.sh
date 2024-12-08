pwd=$HOME
php_ini_path="$pwd/php/etc/php.ini"

case "$1" in
    disable)
    echo "Disabling xdebug"
    sed -i -E 's/^(zend_extension=xdebug.so)/;\1/' $php_ini_path
    echo "xdebug disabled successfully"
    ;;

    *)
    if grep -q "\[xdebug\]" "$php_ini_path"; then
        echo "XDebug configuration already exists in php.ini. Skipping writing new configuration."
        exit 0
    fi

    cat >> $php_ini_path <<EOF
[xdebug]
zend_extension=xdebug.so
xdebug.mode=debug
xdebug.start_with_request=yes
xdebug.client_port=9003
xdebug.client_host=127.0.0.1
EOF

    echo "xdebug installed successfully"

    echo "generating launch.json file"

    cat > launch.json <<EOF
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9003
        }
    ]
}
EOF

    echo "launch.json file generated successfully at $(pwd)/launch.json, please copy this file to .vscode folder of your project"
    ;;
esac

$pwd/httpd/bin/apachectl -k restart
