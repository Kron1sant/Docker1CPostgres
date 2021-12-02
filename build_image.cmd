@echo off
rem первый параметр - номер версии 1С: 8.3.19.1399
rem второй параметр - номер версии PostgreSQL: 12.7-5.1C
rem третий параметр - имя docker образа
rem четвертый параметр - путь к файлу с именами пользователя и паролями
IF "%~1" == "" (set VERSION_1C=8.3.19.1399) ELSE (set VERSION_1C=%~1)
IF "%~2" == "" (set VERSION_POSTGRES=12.7-5.1C) ELSE (set VERSION_POSTGRES=%~2)
IF "%~3" == "" (set IMAGE_NAME=kron1sant/docker1c) ELSE (set IMAGE_NAME=%~3)
IF "%~4" == "" (set CREDENTIALS=./distr/credentials) ELSE (set CREDENTIALS=%~4)

set COMMAND=docker build -t %IMAGE_NAME%:%VERSION_1C%-%VERSION_POSTGRES% --build-arg SRV1C_VERSION=%VERSION_1C% --build-arg POSTGRES_VERSION=%VERSION_POSTGRES% --build-arg AUTO_DOWNLOAD_DISTR=1 --build-arg CRED=%CREDENTIALS% .
echo %COMMAND%
%COMMAND%