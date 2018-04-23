#!/bin/bash
# wdcp&wdlinux
IN_PWD=$(pwd)
IN_SRC=${IN_PWD}/src
IN_DIR="/www/wdlinux"
IN_LOG=${IN_PWD}/logs
INF=${IN_PWD}/inf
DL_URL="http://dl.wdlinux.cn"
WD_URL="http://www.wdlinux.cn"
[ ! -d $IN_SRC ] && mkdir -p $IN_SRC
[ ! -d $IN_DIR ] && mkdir -p $IN_DIR/phps
[ ! -d $IN_LOG ] && mkdir -p $IN_LOG
[ ! -d $INF ] && mkdir -p $INF

###
[ $UID != 0 ] && echo -e "\n ERR: You must be root to run the install script.\n\n" && exit

#
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

phps="5.2.17 5.3.29 5.4.45 5.5.38 5.6.30 7.0.18 7.1.4"
if [ $R7 == 1 ];then
	phps="5.4.45 5.5.38 5.6.30 7.0.18 7.1.3"
fi
if [ -n "$1" ];then
	[[ "${phps[@]/$1/}" == "${phps[@]}" ]] && exit
	phps=$1
fi

if [ -n "$2" ];then
	phpc=$2
else
	phpc=2
fi

function php52 {
	if [ $X86 == 1 ];then
	fileurl=${DL_URL}/files/zend/zend_64.tar.gz && filechk
	tar zxvf zend_64.tar.gz -C $IN_DIR
	else
	fileurl=${DL_URL}/files/zend/zend_32.tar.gz && filechk
	tar zxvf zend_32.tar.gz -C $IN_DIR
	fi
grep -q 'ZendExtensionManager.so' /www/wdlinux/phps/$phpd/etc/php.ini
if [ $? != 0 ];then
echo '[Zend]
zend_extension_manager.optimizer='$IN_DIR'/Zend/lib/Optimizer-3.3.3
zend_extension_manager.optimizer_ts='$IN_DIR'/Zend/lib/Optimizer_TS-3.3.3
zend_optimizer.version=3.3.3
zend_extension='$IN_DIR'/Zend/lib/ZendExtensionManager.so
zend_extension_ts='$IN_DIR'/Zend/lib/ZendExtensionManager_TS.so' >> $IN_DIR/phps/52/etc/php.ini
fi
}

function php53 {
	if [ $X86 == 1 ];then
        fileurl=${DL_URL}/files/zend/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz && filechk
        tar xzf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so $ext_dir
        rm -rf ZendGuardLoader-php-5.3-linux-glibc23-x86_64
	else
        fileurl=${DL_URL}/files/zend/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz && filechk
        tar xzf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
        cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so $ext_dir
        rm -rf ZendGuardLoader-php-5.3-linux-glibc23-i386
	fi
}
function php54 {
	if [ $X86 == 1 ];then
        fileurl=${DL_URL}/files/zend/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz && filechk
        tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
        cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so $ext_dir
        rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64
	else
        fileurl=${DL_URL}/files/zend/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz && filechk
        tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
        cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so $ext_dir
        rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386	
	fi
}
function php55 {
	if [ $X86 == 1 ];then
	fileurl=${DL_URL}/files/zend/zend-loader-php5.5-linux-x86_64.tar.gz && filechk
        tar xzf zend-loader-php5.5-linux-x86_64.tar.gz
        cp zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so $ext_dir
        rm -rf zend-loader-php5.5-linux-x86_64
	else
        fileurl=${DL_URL}/files/zend/zend-loader-php5.5-linux-i386.tar.gz && filechk
        tar xzf zend-loader-php5.5-linux-i386.tar.gz
        cp zend-loader-php5.5-linux-i386/ZendGuardLoader.so $ext_dir
        rm -rf zend-loader-php5.5-linux-i386	
	fi
}
function php56 {
	if [ $X86 == 1 ];then
        fileurl=${DL_URL}"/files/zend/zend-loader-php5.6-linux-x86_64.tar.gz" && filechk
        tar zxvf zend-loader-php5.6-linux-x86_64.tar.gz
        cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so $ext_dir
        rm -fr zend-loader-php5.6-linux-x86_64
	else
        fileurl=${DL_URL}"/files/zend/zend-loader-php5.6-linux-i386.tar.gz" && filechk
        tar zxvf zend-loader-php5.6-linux-i386.tar.gz
        cp zend-loader-php5.6-linux-i386/ZendGuardLoader.so $ext_dir
        rm -fr zend-loader-php5.6-linux-i386	
	fi
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
	phpd=${phpv:0:1}${phpv:2:1}
        if [ ! -d $IN_DIR/phps/$phpd ];then
		continue
	fi
	if [ ${phpv:0:1} == "7" ];then
		continue
	fi
        ext_dir=`/www/wdlinux/phps/$phpd/bin/php-config --extension-dir`
	[ -d $ext_dir ] || mkdir -p $ext_dir
	cd $IN_SRC
	php$phpd
	if [ $phpd == "52" ];then
		[ -f /www/wdlinux/phps/$phpd/logs/php-fpm.pid ] && /www/wdlinux/phps/$phpd/bin/php-fpm restart
		echo
	else
grep -q 'ZendGuardLoader.so' /www/wdlinux/phps/$phpd/etc/php.ini
if [ $? != 0 ];then
echo '[Zend Guard Loader]
zend_extension="'$ext_dir'/ZendGuardLoader.so"
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3' >> $IN_DIR/phps/$phpd/etc/php.ini
fi
	[ -f /www/wdlinux/phps/$phpd/var/log/php-fpm.pid ] && /www/wdlinux/phps/$phpd/bin/php-fpm restart
	fi
	echo
	echo $phpv" zend install complete"
done

    echo
    echo
    echo -e "      \033[31mconfigurations, phps install is complete"
    echo -e "      visit http://ip:8080"
    echo -e "      more infomation please visit http://www.wdlinux.cn/bbs/\033[0m"
    echo

