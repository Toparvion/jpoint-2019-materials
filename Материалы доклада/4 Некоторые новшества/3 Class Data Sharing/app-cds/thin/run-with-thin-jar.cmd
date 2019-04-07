rem @echo off
cd  %~dp0
cd ..
for %%* in (.) do set APP_NAME=%%~nx*
echo Microservice name detected: '%APP_NAME%'
set JVM_OPTS=-Xmx128m -XX:MaxMetaspaceSize=128m -Xshare:off
set APP_OPTS=--spring.profiles.active=dev --spring.config.name=%APP_NAME% --logging.config=config/logback-console.xml
rem set JVM_OPTS=-Xmx128m -XX:MaxMetaspaceSize=128m -XX:DumpLoadedClassList=classes.jar.list
set JAVA_EXE=E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\bin\java.exe

%JAVA_EXE% %JVM_OPTS% @thin\thin.reduced.classpath ftc.pc.soa.proxy.restorun.Restorun %APP_OPTS%