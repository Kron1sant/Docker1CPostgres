#!/bin/bash

# ENV:
# SRV1C_VERSION=8.3.18.1661 
# POSTGRES_VERSION=12.7.5.1C 
# DISTR_DIR=/tmp/distr/

# Install 1C
VER_MAJOR_1C=`echo $SRV1C_VERSION | awk -F. '{print $1}'`
VER_MINOR_1C=`echo $SRV1C_VERSION | awk -F. '{print $2}'`
VER_BUILD_1C=`echo $SRV1C_VERSION | awk -F. '{print $3}'`
VER_RELEASE_1C=`echo $SRV1C_VERSION | awk -F. '{print $4}'`
DEB_1C_DISTR_NAME="deb64_${VER_MAJOR_1C}_${VER_MINOR_1C}_${VER_BUILD_1C}_${VER_RELEASE_1C}.tar.gz"
DISTR_DIR_1C=$DISTR_DIR/distr_1c

mkdir $DISTR_DIR_1C
tar -xzf $DISTR_DIR/$DEB_1C_DISTR_NAME -C $DISTR_DIR_1C
rm -f $DEB_1C_DISTR_NAME
find $DISTR_DIR_1C -maxdepth 1 -type f -name '*.deb' | grep -v 'nls' | grep -v 'nls' | xargs  dpkg -i
rm -rf $DISTR_DIR/$DISTR_DIR_1C

# Используем http-отладку
sed -i 's/\&\& cmdline="\$cmdline -debug"/\&\& cmdline="\$cmdline -debug -http"/' /opt/1cv8/x86_64/${SRV1C_VERSION}/srv1cv83

# Install PostgreSQL
VER_MAJOR_PSQL=`echo $POSTGRES_VERSION | awk -F. '{print $1}'`
VER_MINOR_PSQL=`echo $POSTGRES_VERSION | awk -F. '{print $2}'`
VER_BUILD_PSQL=`echo $POSTGRES_VERSION | awk -F. '{print $3}'`
DEB_POSTGRES_DISTR_NAME="postgresql_${VER_MAJOR_PSQL}.${VER_MINOR_PSQL}_${VER_BUILD_PSQL}.1C_amd64_deb.tar.bz2"
DISTR_DIR_POSTGRES=$DISTR_DIR/distr_postgres

mkdir $DISTR_DIR_POSTGRES
tar -xjf $DISTR_DIR/$DEB_POSTGRES_DISTR_NAME -C $DISTR_DIR_POSTGRES
rm -f $DISTR_DIR/$DEB_POSTGRES_DISTR_NAME
INNER_DIR=`ls $DISTR_DIR_POSTGRES -1 | head -n1`
DISTR_DIR_POSTGRES=$DISTR_DIR_POSTGRES/$INNER_DIR
echo $DISTR_DIR_POSTGRES

echo "deb http://security.ubuntu.com/ubuntu xenial-security main" >> /etc/apt/sources.list
apt-get update
DEBIAN_FRONTEND="noninteractive" apt-get -y install libicu55 tzdata
TZ=Europe/Moscow
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
apt-get -y install $DISTR_DIR_POSTGRES/libpq*
apt-get -y install $DISTR_DIR_POSTGRES/postgresql-client-${VER_MAJOR_PSQL}*
apt-get -y install $DISTR_DIR_POSTGRES/postgresql-${VER_MAJOR_PSQL}*
apt-get clean
rm -rf $DISTR_DIR_POSTGRES

mkdir /db_data
pg_dropcluster 12 main
locale-gen ru_RU.UTF-8
pg_createcluster 12 main -d /db_data --locale=ru_RU.UTF-8
pg_ctlcluster 12 main start
su - postgres -c "createuser -s -i -d -r -l -w usr1cv8"
su - postgres -c "psql -c \"ALTER ROLE usr1cv8 WITH PASSWORD 'usr1cv8';\""
pg_ctlcluster 12 main stop

rm -rf $DISTR_DIR