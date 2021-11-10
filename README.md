Сборка докер образа 1С + PostgreSQL
===================================

## Инструкция
В папку **distr** разместить файлы дистрибутивов (DEB) для 1С и СУБД. Например:
* deb64_8_3_18_1661.tar.gz
* postgresql_12.7_5.1C_amd64_deb.tar.bz2

Выполнить команду `docker build` указав необходимые аргументы:
* SRV1C_VERSION - версия 1С
* POSTGRES_VERSION - версия СУБД PostgreSQL

Например:
```shell 
docker build -t kron1sant/docker1c:8.3.19.1399-12.7.5 --build-arg SRV1C_VERSION=8.3.19.1399 --build-arg POSTGRES_VERSION=12.7.5.1C .
```

Полученный образ можно запустить командой (например для Windows с wsl2):
```shell
docker run -d -h docker1c -p 1540:1540 -p 1541:1541 -p 1550:1550 -p 1560-1591:1560-1591 -p 5432:5432 -v /D/Logs/docker1c/logs1c:/data/logs1c -v /D/Logs/docker1c/config1c:/data/config1c -v /D/Logs/docker1c/db:/data/db -v /D/Logs/docker1c/cluster1c:/data/cluster1c --name docker1c-run kron1sant/docker1c:8.3.19.1399-12.7.5

docker run -d -h docker1c -p 1540:1540 -p 1541:1541 -p 1550:1550 -p 1560-1591:1560-1591 -p 5432:5432 -v /D/docker1c/logs1c:/data/logs1c -v /D/docker1c/config1c:/data/config1c --name docker1c-run kron1sant/docker1c:8.3.19.1399-12.7.5
```

Для СУБД заводится супер пользователь **usr1cv8** с паролем **usr1cv8**.

### Запуст Docker на Windows с WSL2
Для доступа с локальной (host) машины к docker-контейнеру нужно использовать ip вдрес вирутальной машины WSL (*docker-desktop*).
Причем 1С требует, чтобы ip ардрес резолвился по имени указанному при запуске агента. Для этого:
1. Стартуем docker-контейнер с указанием ключа **-h** и указываем люое имя сервера 1С, по котормоу будем работать с базами 1С (`docker run -h docker1c...`)
2. Получаем ip-адрес вирутальной машины с docker'ом. Например, `wsl -d docker-descktop` и в терминале `ip -4 addr | grep eth0`
3. Добавляем в файл hosts полученный ip адрес и имя сервера указанное в ключе **-h**

Вместо пунктов 2 и 3 можно воспользоваться скриптом `add_1C_docker_host.ps1`.

## Описание сборки
Сборка строится на базе образа Ubuntu:18.04.
Дистрибутивы из каталога **distr** копируются в каталог *$DISTR_DIR*. Скрипты **entrypoint.sh** и **deployer.sh** размещаются в */usr/src/deploy1c/*:
* **deployer.sh** - служит для распаковки архивов и устанвки 1С и postgres в момент пострения образа. Все дистрибутивы удаляются из образа после установки.
* **entrypoint.sh** - запускается postgres и 1С в момент запуска контейнера.

