@echo off
rem Переходим в папку, где расположен данный скрипт
cd  %~dp0
rem Отступаем от нее на один уровень вверх
cd ..
rem Определяем имя микросервиса как имя текущей директории
for %%* in (.) do set APP_NAME=%%~nx*
echo Microservice name detected: '%APP_NAME%'
rem Собираем JAR-ку (в первый раз это будет долго, но в последующие должно проходить мгновенно)
set JAVA_HOME=E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\bin
rem call gradle assemble
rem Формируем параметры и аргументы запуска
set APP_OPTS=--spring.profiles.active=dev --spring.config.name=%APP_NAME% --logging.config=config/logback-console.xml
set JVM_OPTS=-Xmx128m -XX:MaxMetaspaceSize=128m -Xlog:class+load=debug:file=classes.jar.log
rem set JVM_OPTS=-Xmx128m -XX:MaxMetaspaceSize=128m -XX:DumpLoadedClassList=classes.jar.list
set JAR_PATH=build\libs\%APP_NAME%.jar
set JAVA_EXE=E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\bin\java.exe

rem Запускаем микросервис
%JAVA_EXE% %JVM_OPTS% -jar %JAR_PATH% %APP_OPTS%