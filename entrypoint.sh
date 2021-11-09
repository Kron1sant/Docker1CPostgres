#!/bin/bash

# Запускаем Postgres
VER_MAJOR_PSQL=`echo $POSTGRES_VERSION | awk -F. '{print $1}'`
pg_ctlcluster $VER_MAJOR_PSQL main start

# Запускаем 1С
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