@echo off
rem Переходим в папку, где расположен данный скрипт
cd  %~dp0
rem Отступаем от нее на один уровень вверх
cd ..
rem Определяем имя микросервиса как имя текущей директории
for %%* in (.) do set APP_NAME=%%~nx*
echo Microservice name detected: '%APP_NAME%'
rem Формируем параметры и аргументы запуска
set APP_OPTS=--spring.profiles.active=dev --spring.config.name=%APP_NAME% --logging.config=config/logback-console.xml
set JVM_OPTS=-Xmx128m -XX:MaxMetaspaceSize=128m -Djava.net.preferIPv4Stack=true -Xshare:on -XX:SharedArchiveFile=classes.jsa -Xlog:class+load=info:file=log\class-load.log
set CP=e:\Projects\upc2\microservices\restorun\classpath1101185830.jar
set JAVA=E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\bin\java.exe
rem Запускаем микросервис
%JAVA% %JVM_OPTS% -classpath %CP% ftc.pc.soa.proxy.restorun.Restorun %APP_OPTS%