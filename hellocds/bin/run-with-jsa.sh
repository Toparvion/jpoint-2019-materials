#!/bin/bash

cd `dirname $0`/..

CP=/mnt/c/lang/mysamples/project-uprise/hellocds/lib/slf4j-api-1.7.25.jar
CP=$CP:/mnt/c/lang/mysamples/project-uprise/hellocds/lib/slf4j-simple-1.7.25.jar
CP=$CP:/mnt/c/lang/mysamples/project-uprise/hellocds/out

JVM_OPTS="-Xshare:on"
JVM_OPTS="$JVM_OPTS -Xlog:class+path=debug"
# JVM_OPTS="$JVM_OPTS -Xlog:class+load=info:file=log/class-load.log"
JVM_OPTS="$JVM_OPTS -XX:SharedArchiveFile=jsa/classes.jsa"

# java $JVM_OPTS -classpath $CP sample.HelloCDS
java $JVM_OPTS -jar jar/hellocds.jar
