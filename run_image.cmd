@echo off
rem первый параметр - номер версии 1С: 8.3.19.1399
rem второй параметр - номер версии PostgreSQL: 12.7-5.1C
rem третий параметр - имя docker образа
IF "%~1" == "" (set VERSION_1C=8.3.19.1399) ELSE (set VERSION_1C=%~1)
IF "%~2" == "" (set VERSION_POSTGRES=12.7-5.1C) ELSE (set VERSION_POSTGRES=%~2)
IF "%~3" == "" (set IMAGE_NAME=kron1sant/docker1c) ELSE (set IMAGE_NAME=%~3)
set DIR_LOGS=/D/docker1c/logs1c
set DIR_CONFIG=/D/docker1c/config1c

set COMMAND=docker run -d -h docker1c -m 6g -p 1540:1540 -p 1541:1541 -p 1550:1550 -p 1560-1591:1560-1591 -p 5432:5432 -v %DIR_LOGS%:/data/logs1c -v %DIR_CONFIG%:/data/config1c --name docker1c-run %IMAGE_NAME%:%VERSION_1C%-%VERSION_POSTGRES%
echo %COMMAND%
%COMMAND%