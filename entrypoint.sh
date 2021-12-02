#!/bin/bash

# Запускаем Postgres
if [ ! "x$POSTGRES_OFF" == "x1" ]; then
    # Инициализация кластера
    VER_MAJOR_PSQL=`echo $POSTGRES_VERSION | awk -F. '{print $1}'`
    PG_DATADIR=/data/db
    # Важно указать кирилическую локаль
    locale-gen ru_RU.UTF-8
    pg_createcluster $VER_MAJOR_PSQL main -d $PG_DATADIR --locale=ru_RU.UTF-8
    # Запустим кластер, чтобы создать пользователя для 1С: usr1cv8 / usr1cv8
    pg_ctlcluster $VER_MAJOR_PSQL main start
    su - postgres -c "createuser -s -i -d -r -l -w usr1cv8"
    su - postgres -c "psql -c \"ALTER ROLE usr1cv8 WITH PASSWORD 'usr1cv8';\""
fi

# Запускаем Apache2, если он входит в сборку
if [ "x$INSTALL_APACHE" == "x1" ]; then
    apachectl start
fi

# Запускаем 1С
[ -z "$SRV1CV8_DEBUG_ADDR" ] && export SRV1CV8_DEBUG_ADDR=`hostname`
[ -z "$SRV1CV8_DEBUG_PORT" ] && export SRV1CV8_DEBUG_PORT=1550
/opt/1cv8/x86_64/${SRV1C_VERSION}/srv1cv83 start
# Ждем 10 секунд, чтобы дать время на запуск и получем PID ragent'a
sleep 10
SRV1C_VERSION_DASHED=`echo $SRV1C_VERSION | sed 's/\./-/g'`
SRV1C_PID=`cat /var/run/srv1cv${SRV1C_VERSION_DASHED}.pid`
echo "Запущен 1С Агент с PID $SRV1C_PID"

# Скрипт не должен завершаться, чтобы докер-контейнер продолжал работать как демон.
# Так как агент 1С стартанул как служба, то он не привязан к данному терминалу.
# Подключимся к стандартному выводу процесса агента 1С
su - usr1cv8 -c "tail -f /proc/${SRV1C_PID}/fd/1"
# альтернативное решение - запускать агент 1С не через srv1cv83 start, а непосредственно вызывая ragent без --daemon