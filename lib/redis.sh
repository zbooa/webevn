# redis install function
function redis_ins {
    local IN_LOG=$LOGPATH/${logpre}_apache_install.log
    echo
    if [ ! -f $redis_inf ];then
    echo "installing redis..."
    cd $IN_SRC
    fileurl=$REDIS_URL && filechk
    tar -zxvf redis-stable.tar.gz
    cd redis-stable
    make 
    [ $? != 0 ] && err_exit "redis make err"
    make install 
    [ $? != 0 ] && err_exit "redis install err"

    cd utils/
    echo "\n" | ./install_server.sh
    chmod 755 /etc/init.d/redis_6379
    chkconfig --add redis_6379
    chkconfig --level 345 redis_6379 on

    cd $IN_SRC
    rm -fr redis-stable
    touch $redis_inf
    fi
    if [ ! -f $redisp_inf ];then
    cd $IN_SRC
    fileurl=$REDISP_URL && filechk
    unzip develop.zip
    cd phpredis-develop
    /www/wdlinux/php/bin/phpize
    ./configure --with-php-config=/www/wdlinux/php/bin/php-config
    make
    [ $? != 0 ] && err_exit "redis make err"
    make install
    [ $? != 0 ] && err_exit "redis install err"
    grep -q 'redis.so' /www/wdlinux/etc/php.ini
    if [ $? != 0 ]; then
    local ext_dir=`/www/wdlinux/php/bin/php-config --extension-dir`
    echo "
[redis]
extension_dir ="$ext_dir"
extension=redis.so" >> /www/wdlinux/etc/php.ini
    fi
    cd $IN_SRC
    rm -fr phpredis*
    touch $redisp_inf
    fi
}
