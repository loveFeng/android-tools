#! /bin/bash

apt-source="deb http://mirrors.163.com/ubuntu/ precise main universe restricted multiverse
deb-src http://mirrors.163.com/ubuntu/ precise main universe restricted multiverse
deb http://mirrors.163.com/ubuntu/ precise-security universe main multiverse restricted
deb-src http://mirrors.163.com/ubuntu/ precise-security universe main multiverse restricted
deb http://mirrors.163.com/ubuntu/ precise-updates universe main multiverse restricted
deb-src http://mirrors.163.com/ubuntu/ precise-updates universe main multiverse restricted

deb http://mirrors.sohu.com/ubuntu/ precise main restricted
deb-src http://mirrors.sohu.com/ubuntu/ precise main restricted
deb http://mirrors.sohu.com/ubuntu/ precise-updates main restricted
deb-src http://mirrors.sohu.com/ubuntu/ precise-updates main restricted
deb http://mirrors.sohu.com/ubuntu/ precise universe
deb-src http://mirrors.sohu.com/ubuntu/ precise universe
deb http://mirrors.sohu.com/ubuntu/ precise-updates universe
deb-src http://mirrors.sohu.com/ubuntu/ precise-updates universe
deb http://mirrors.sohu.com/ubuntu/ precise multiverse
deb-src http://mirrors.sohu.com/ubuntu/ precise multiverse
deb http://mirrors.sohu.com/ubuntu/ precise-updates multiverse
deb-src http://mirrors.sohu.com/ubuntu/ precise-updates multiverse
deb http://mirrors.sohu.com/ubuntu/ precise-security main restricted
deb-src http://mirrors.sohu.com/ubuntu/ precise-security main restricted
deb http://mirrors.sohu.com/ubuntu/ precise-security universe
deb-src http://mirrors.sohu.com/ubuntu/ precise-security universe
deb http://mirrors.sohu.com/ubuntu/ precise-security multiverse
deb-src http://mirrors.sohu.com/ubuntu/ precise-security multiverse
deb http://ppa.launchpad.net/dominik-stadler/subversion-1.7/ubuntu precise main
deb-src http://ppa.launchpad.net/dominik-stadler/subversion-1.7/ubuntu precise main"

fileName="/etc/environment"
env_source='PATH＝"$PASH:/usr/lib/java/jdk1.6.0_34/bin"
CLASSPATH="/usr/lib/java/jdk1.6.0_34/lib"
JAVA_HOME="/usr/lib/java/jdk1.6.0_34"'

software="gnupg flex bison gperf build-essential \
zip curl zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs  \
x11proto-core-dev libx11-dev lib32readline-gplv2-dev lib32z1-dev \
libgl1-mesa-dev gcc-multilib g++-multilib mingw32 tofrodos python-markdown  \
libxml2-utils  xsltproc gcc-4.4 g++-4.4 g++-4.4-multilib gcc-4.4-multilib"

extsoft="wine samba subversion ccache kdesvn vim git"

sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
sudo echo ${apt-source} >> /etc/apt/sources.list
sudo apt-get update
sudo apt-get install $software $extsoft

cd /usr/bin
sudo mv gcc gcc.bak
sudo ln -s gcc-4.4 gcc
sudo mv g++ g++.bak
sudo ln -s g++-4.4 g++
