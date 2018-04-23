#!/bin/bash
# wdcp&wdlinux
IN_PWD=$(pwd)
IN_SRC=${IN_PWD}/src
IN_DIR="/www/wdlinux"
IN_LOG=${IN_PWD}/logs
INF=${IN_PWD}/inf
DL_URL="http://dl.wdlinux.cn/files/php"
WD_URL="http://www.wdlinux.cn"
[ ! -d $IN_SRC ] && mkdir -p $IN_SRC
[ ! -d $IN_DIR ] && mkdir -p $IN_DIR/phps
[ ! -d $IN_LOG ] && mkdir -p $IN_LOG
[ ! -d $INF ] && mkdir -p $INF

###
[ $UID != 0 ] && echo -e "\n ERR: You must be root to run the install script.\n\n" && exit

#
yum install -y gcc gcc-c++ make sudo autoconf libtool-ltdl-devel gd-devel \
        freetype-devel libxml2-devel libjpeg-devel libpng-devel openssl-devel \
        curl-devel patch libmcrypt-devel libmhash-devel ncurses-devel bzip2 \
        libcap-devel ntp sysklogd diffutils sendmail iptables unzip cmake wget \
        re2c bison icu libicu libicu-devel net-tools psmisc vim-enhanced

# OS Version detect
# 1:redhat/centos 2:debian/ubuntu
OS_RL=1
grep -qi 'debian\|ubuntu' /etc/issue && OS_RL=2
if [ $OS_RL == 1 ]; then
    R6=0
    R7=0
    grep -q 'release 6' /etc/redhat-release && R6=1
    grep -q 'release 7' /etc/redhat-release && R7=1 && iptables="iptables-services"
fi
X86=0
if uname -m | grep -q 'x86_64'; then
    X86=1
fi
CPUS=`grep processor /proc/cpuinfo | wc -l`
if [ $X86 == 1 ]; then
    ln -sf /usr/lib64/libjpeg.so /usr/lib/
    ln -sf /usr/lib64/libpng.so /usr/lib/
fi


phps="5.2.17 5.3.29 5.4.45 5.5.38 5.6.30 7.0.18 7.1.4"
if [ $R7 == 1 ];then
	phps="5.4.45 5.5.38 5.6.30 7.0.18 7.1.4"
fi

pst=0
if [ -n "$1" ];then
	[[ "${phps[@]/$1/}" == "${phps[@]}" ]] && exit
	phps=$1
	pst=1
fi

if [ -n "$2" ];then
	phpc=$2
else
	phpc=2
fi
grep wdcp /etc/rc.d/rc.local >/dev/null 2>&1
[ $? == 1 ] &&  echo "/www/wdlinux/wdcp/phps/start.sh" >> /etc/rc.d/rc.local

function php_ins {
	local IN_LOG=$LOGPATH/php-$1-install.log
	echo
	phpfile="php-${phpv}.tar.gz"
	cd $IN_SRC
	fileurl=$DL_URL/$phpfile && filechk
	tar zxvf $phpfile
	cd php-${phpv}
	if [ $phpc == 1 ];then
		echo 1
	else
		echo 2
	fi
	$phpcs
	if [ $phpd -eq 52 ];then
		ln -s /www/wdlinux/mysql/lib/libmysql* /usr/lib/
		ldconfig
	fi
	[ $? != 0 ] && err_exit "php configure err"
	make ZEND_EXTRA_LIBS='-liconv' -j $CPUS
    	[ $? != 0 ] && err_exit "php make err"
    	make install
    	[ $? != 0 ] && err_exit "php install err"
	if [ $phpd -eq 52 ];then
		cp php.ini-recommended $IN_DIR/phps/$phpd/etc/php.ini
		ln -sf $IN_DIR/phps/$phpd/sbin/php-fpm $IN_DIR/phps/$phpd/bin/php-fpm
                sed -i '/nobody/s#<!--##g' $IN_DIR/phps/$phpd/etc/php-fpm.conf
                sed -i '/nobody/s#-->##g' $IN_DIR/phps/$phpd/etc/php-fpm.conf
                sed -i 's/>nobody</>www</' $IN_DIR/phps/$phpd/etc/php-fpm.conf
		sed -i 's/>20</>2</g' $IN_DIR/phps/$phpd/etc/php-fpm.conf
		sed -i 's/>5</>2</g' $IN_DIR/phps/$phpd/etc/php-fpm.conf
		sed -i 's#127.0.0.1:9000#/tmp/php-52-cgi.sock#' $IN_DIR/phps/$phpd/etc/php-fpm.conf
	else
		cp php.ini-production $IN_DIR/phps/$phpd/etc/php.ini
		cp -f sapi/fpm/init.d.php-fpm $IN_DIR/phps/$phpd/bin/php-fpm
		wget $WD_URL/conf/php/php-fpm.conf -c -O $IN_DIR/phps/$phpd/etc/php-fpm.conf
        	sed -i 's/{PHPVER}/'$phpd'/g' $IN_DIR/phps/$phpd/etc/php-fpm.conf
	fi
	sed -i 's@^short_open_tag = Off@short_open_tag = On@' $IN_DIR/phps/$phpd/etc/php.ini
	sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' $IN_DIR/phps/$phpd/etc/php.ini
        sed -i 's@^post_max_size = 8M@post_max_size = 30M@g' $IN_DIR/phps/$phpd/etc/php.ini
        sed -i 's@^upload_max_filesize = 2M@upload_max_filesize = 30M@g' $IN_DIR/phps/$phpd/etc/php.ini
	chmod 755 $IN_DIR/phps/$phpd/bin/php-fpm
	if [ $pst == 1 ];then
		$IN_DIR/phps/$phpd/bin/php-fpm start
	fi
	cd $IN_SRC
	rm -fr php-${phpv}
}

function filechk {
    [ -s "${fileurl##*/}" ] || wget -nc $fileurl
    if [ ! -e "${fileurl##*/}" ];then
        echo "${fileurl##*/} download failed"
        kill -9 $$
    fi
}

function err_exit {
    echo
    echo
    uname -m
    [ -f /etc/redhat-release ] && cat /etc/redhat-release
    echo -e "\033[31m----Install Error: $phpv -----------\033[0m"
    echo
    echo -e "\033[0m"
    echo
    exit
}


for phpv in $phps; do
	phpfile="php-${phpv}.tar.gz"
	url="http://dl.wdlinux.cn/files/php/${phpfile}"
	phpd=${phpv:0:1}${phpv:2:1}
	if [ -f $INF/$phpd".txt" ];then
		echo ${phpv}" is Installed"
		continue
	fi
	phpcs="./configure --prefix=/www/wdlinux/phps/"${phpd}" --with-config-file-path=/www/wdlinux/phps/"${phpd}"/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl=/usr --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --disable-fileinfo --enable-intl"
	if [ $phpd -gt 54 ];then
		phpcs=$phpcs" --enable-opcache"
	fi
	if [ $phpd -eq 52 ];then
		phpcs="./configure --prefix=$IN_DIR/phps/"${phpd}" --with-config-file-path=$IN_DIR/phps/"${phpd}"/etc --with-mysql=$IN_DIR/mysql --with-iconv=/usr --with-mysqli=$IN_DIR/mysql/bin/mysql_config --with-pdo-mysql=$IN_DIR/mysql --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt=/usr --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-ftp --enable-bcmath --enable-exif --enable-sockets --enable-zip --enable-fastcgi --enable-fpm --with-fpm-conf=$IN_DIR/phps/"${phpd}"/etc/php-fpm.conf --with-iconv-dir=/usr"
	fi
	php_ins
	touch $INF/$phpd".txt"
	echo
	echo $phpv" install complete"
done

    echo
    echo
    echo -e "      \033[31mconfigurations, phps install is complete"
    echo -e "      visit http://ip:8080"
    echo -e "      more infomation please visit http://www.wdlinux.cn/bbs/\033[0m"
    echo

