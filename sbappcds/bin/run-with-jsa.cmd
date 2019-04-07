@echo on
rem Переходим в папку, где расположен данный скрипт
cd  %~dp0
rem Отступаем от нее на один уровень вверх
cd ..

set JVM_OPTS=-Xshare:on
set JVM_OPTS=%JVM_OPTS% -Xlog:class+path=debug
set JVM_OPTS=%JVM_OPTS% -Xlog:class+load=info:file=log/class-load.log
set JVM_OPTS=%JVM_OPTS% -XX:SharedArchiveFile=jsa/classes.jsa

set JAVA=E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\bin\java.exe

%JAVA% %JVM_OPTS% -jar jar/sbappcds.jar
