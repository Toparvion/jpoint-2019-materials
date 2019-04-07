set JVM_OPTS=-Xshare:dump -XX:SharedClassListFile=classes.list -XX:SharedArchiveFile=classes.jsa 
set JAVA=E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\bin\java.exe

%JAVA% %JVM_OPTS% @classpath4dump.cp ftc.pc.soa.proxy.restorun.Restorun