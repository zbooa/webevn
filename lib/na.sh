# nginx+apache combination install function
function na_ins {
    [ -f $na_inf ] && return
    echo
    nginx_ins
    apache_ins
    sed -i 's/Listen 80/Listen 88/g' /www/wdlinux/apache/conf/httpd.conf
    sed -i 's/NameVirtualHost \*:80/NameVirtualHost \*:88/g' /www/wdlinux/apache/conf/httpd.conf
    sed -i 's/VirtualHost \*:80/VirtualHost \*:88/g' /www/wdlinux/apache/conf/vhost/00000.default.conf
    if [ $APA_ID == 1 ];then
    cd $IN_SRC
    fileurl=$RPAF_URL && filechk
    tar xf mod_rpaf-0.6.tar.gz
    cd mod_rpaf-0.6/
    /www/wdlinux/apache/bin/apxs -i -c -a mod_rpaf-2.0.c >/dev/null 2>&1
    file_cp rpaf.conf /www/wdlinux/apache/conf/rpaf.conf
    fi
    [ $APA_ID == 2 ] && file_cp rpaf2.conf /www/wdlinux/apache/conf/rpaf.conf
    file_cp naproxy.conf /www/wdlinux/nginx/conf/naproxy.conf
    file_cp defaultna.conf $IN_DIR/wdcp_bk/conf/defaultna.conf
    file_cpv defaultna.conf /www/wdlinux/nginx/conf/vhost/00000.default.conf
    file_cp wdlinux_na.php /www/web/default/index.php
    echo 'Include conf/rpaf.conf' >> /www/wdlinux/apache/conf/httpd.conf
    touch $na_inf
}

