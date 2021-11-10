#!/bin/bash

mkdir /data

# ENV:
# SRV1C_VERSION=8.3.18.1661 
# POSTGRES_VERSION=12.7.5.1C 
# DISTR_DIR=/tmp/distr/

# Install PostgreSQL
# Константы
VER_MAJOR_PSQL=`echo $POSTGRES_VERSION | awk -F. '{print $1}'`
VER_MINOR_PSQL=`echo $POSTGRES_VERSION | awk -F. '{print $2}'`
VER_BUILD_PSQL=`echo $POSTGRES_VERSION | awk -F. '{print $3}'`
DEB_POSTGRES_DISTR_NAME="postgresql_${VER_MAJOR_PSQL}.${VER_MINOR_PSQL}_${VER_BUILD_PSQL}.1C_amd64_deb.tar.bz2"
DISTR_DIR_POSTGRES=$DISTR_DIR/distr_postgres

# Распаковка архивов дистрибутива Postgres
mkdir $DISTR_DIR_POSTGRES
tar -xjf $DISTR_DIR/$DEB_POSTGRES_DISTR_NAME -C $DISTR_DIR_POSTGRES
rm -f $DISTR_DIR/$DEB_POSTGRES_DISTR_NAME
INNER_DIR=`ls $DISTR_DIR_POSTGRES -1 | head -n1`
DISTR_DIR_POSTGRES=$DISTR_DIR_POSTGRES/$INNER_DIR

# Установка зависимостей и дистрибутивов Postgres 
# libicu55 будет скачена из "http://security.ubuntu.com/ubuntu xenial-security main"
echo "deb http://security.ubuntu.com/ubuntu xenial-security main" >> /etc/apt/sources.list
apt-get update 
# для установки Postgres нужно указывать часовой пояс
DEBIAN_FRONTEND="noninteractive" apt-get -y install libicu55 tzdata
TZ=Europe/Moscow
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Установка самих дистрибутивов Postgres от 1С
apt-get -y install $DISTR_DIR_POSTGRES/libpq*
apt-get -y install $DISTR_DIR_POSTGRES/postgresql-client-${VER_MAJOR_PSQL}*
apt-get -y install $DISTR_DIR_POSTGRES/postgresql-${VER_MAJOR_PSQL}*
rm -rf $DISTR_DIR_POSTGRES

# При утснановке был создан кластер по умолчанию. Удалим его.
pg_dropcluster $VER_MAJOR_PSQL main 

# Install 1С
# Константы
VER_MAJOR_1C=`echo $SRV1C_VERSION | awk -F. '{print $1}'`
VER_MINOR_1C=`echo $SRV1C_VERSION | awk -F. '{print $2}'`
VER_BUILD_1C=`echo $SRV1C_VERSION | awk -F. '{print $3}'`
VER_RELEASE_1C=`echo $SRV1C_VERSION | awk -F. '{print $4}'`
DEB_1C_DISTR_NAME="deb64_${VER_MAJOR_1C}_${VER_MINOR_1C}_${VER_BUILD_1C}_${VER_RELEASE_1C}.tar.gz"
DISTR_DIR_1C=$DISTR_DIR/distr_1c

# Распаковываем архив
mkdir $DISTR_DIR_1C
tar -xzf $DISTR_DIR/$DEB_1C_DISTR_NAME -C $DISTR_DIR_1C
rm -f $DEB_1C_DISTR_NAME
# Устанавливаем содержимое архива (отбираем все без суффикса -nls)
find $DISTR_DIR_1C -maxdepth 1 -type f -name '*.deb' | grep -v 'nls' | xargs dpkg -i
rm -rf $DISTR_DIR/$DISTR_DIR_1C
# Зависимости для сервера 1С
apt -y install imagemagick fontconfig libgsf-bin libglib2.0-bin unixodbc

# Используем http-отладку
sed -i 's/\&\& cmdline="\$cmdline -debug"/\&\& cmdline="\$cmdline -debug -http"/' /opt/1cv8/x86_64/${SRV1C_VERSION}/srv1cv83

# Меняем каталог кластера
mkdir /data/cluster1c
chown usr1cv8:grp1cv8 /data/cluster1c
su - usr1cv8 -c 'mkdir -p ~/.1cv8/1C; rm -rf ~/.1cv8/1C/1cv8; ln -s /data/cluster1c/ ~/.1cv8/1C/1cv8'
# Cоздаем каталог для ТЖ
mkdir /data/logs1c
chown usr1cv8:grp1cv8 /data/logs1c
# Указываем каталог для конфигурационных файлов (logcfg.xml)
mkdir /data/config1c
mkdir /opt/1cv8/x86_64/${SRV1C_VERSION}/conf
echo ConfLocation=/data/config1c > /opt/1cv8/x86_64/${SRV1C_VERSION}/conf/conf.cfg

# Чистим кеш пакетов и удаляем каталог с дистрибутивами
apt-get clean
rm -rf $DISTR_DIR