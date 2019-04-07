@echo off
rem Переходим в папку, где расположен данный скрипт
cd  %~dp0
rem Отступаем от нее на один уровень вверх
cd ..

set JAVA=E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\bin\java.exe

%JAVA% -Xshare:dump -XX:SharedClassListFile=log/classes.list -XX:SharedArchiveFile=jsa/classes.jsa -jar jar/sbappcds.jar
