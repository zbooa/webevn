# nginx install function
function nginx_ins {
	patch /root/nginx_mod_ext/nginx-upload-module-2.2.0/ngx_http_upload_module.c /root/nginx_mod_ext/nginx-upload-module-2.2.0/davromaniak.txt
    local IN_LOG=$LOGPATH/${logpre}_nginx_install.log
    [ -f $nginx_inf ] && return
    pcre_ins
    echo
    echo "installing nginx..."
    cd $IN_SRC
    fileurl=$NGI_URL && filechk
    tar xvf nginx-$NGI_VER.tar.gz
    cd nginx-$NGI_VER
    #make_clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc
    ./configure --user=www --group=www \
        --prefix=$IN_DIR/nginx-$NGI_VER \
	--with-http_stub_status_module \
	--with-ipv6 \
	--with-http_gzip_static_module \
	--with-http_realip_module \
	--with-http_v2_module \
    --with-http_mp4_module \
    --with-http_flv_module \
    --with-http_ssl_module \
    --add-module=/root/nginx_mod_ext/nginx_mod_h264_streaming-2.2.7 \
    --add-module=/root/nginx_mod_ext/nginx-upload-module-2.2.0 \
    --add-module=/root/nginx_mod_ext/nginx-upload-progress-module-0.9.2
    [ $? != 0 ] && err_exit "nginx configure err"
    make -j $CPUS
    [ $? != 0 ] && err_exit "nginx make err"
    make install
    [ $? != 0 ] && err_exit "nginx install err"
    ln -sf $IN_DIR/nginx-$NGI_VER $IN_DIR/nginx
    mkdir -p $IN_DIR/nginx/conf/{vhost,rewrite,cert}
    mkdir -p /www/{web/default,web_logs}
    file_cp phpinfo.php /www/web/default/phpinfo.php
    file_cp iProber2.php /www/web/default/iProber2.php
    file_cp wdlinux_n.php /www/web/default/index.php
    chown -R www.www /www/web
    file_cp fcgi.conf $IN_DIR/nginx/conf/fcgi.conf
    file_cp nginx.conf $IN_DIR/nginx/conf/nginx.conf
    #file_cp wdcp_n.conf $IN_DIR/nginx/conf/wdcp.conf
    file_cp defaultn.conf $IN_DIR/wdcp_bk/conf/defaultn.conf
    file_cpv defaultn.conf $IN_DIR/nginx/conf/vhost/00000.default.conf
    file_cp dz7_nginx.conf $IN_DIR/nginx/conf/rewrite/dz7_nginx.conf
    file_cp dzx15_nginx.conf $IN_DIR/nginx/conf/rewrite/dzx15_nginx.conf
    mkdir -p $IN_DIR/nginx/conf/vhost
    if [ ! -z $NPD ] && [ $NPD != "55" ];then
    sed -i 's/-56-/-'$NPD'-/g' $IN_DIR/nginx/conf/vhost/00000.default.conf
    fi
    if [ $OS_RL == 2 ]; then
        file_cp init.nginxd-ubuntu $IN_DIR/init.d/nginxd
    else
        file_cp init.nginxd $IN_DIR/init.d/nginxd
    fi
    chmod 755 $IN_DIR/init.d/nginxd
    #ln -sf $IN_DIR/php/sbin/php-fpm $IN_DIR/init.d/php-fpm
    #chmod 755 $IN_DIR/init.d/php-fpm
    #ln -sf $IN_DIR/php/sbin/php-fpm /etc/rc.d/init.d/php-fpm
    file_rm /etc/init.d/nginxd
    Checkinitd nginxd
    if [ $OS_RL == 2 ]; then
        update-rc.d -f nginxd defaults
    else
        chkconfig --add nginxd
        chkconfig --level 35 nginxd on
    fi
    if [ $IN_DIR_ME == 1 ]; then
        sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/nginxd
        sed -i "s#/www/wdlinux#$IN_DIR#g" /etc/init.d/php-fpm
        sed -i "s#/www/wdlinux#$IN_DIR#g" $IN_DIR/nginx/conf/nginx.conf
    fi
    touch $nginx_inf
    cd $IN_SRC
    rm -fr nginx-$NGI_VER
}

