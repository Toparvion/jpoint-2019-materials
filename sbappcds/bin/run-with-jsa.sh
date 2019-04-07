#!/bin/bash

cd `dirname $0`/..

JVM_OPTS="-Xshare:on"
JVM_OPTS="$JVM_OPTS -Xlog:class+path=debug"
JVM_OPTS="$JVM_OPTS -Xlog:class+load=info:file=log/class-load.log"
JVM_OPTS="$JVM_OPTS -XX:SharedArchiveFile=jsa/classes.jsa"

java $JVM_OPTS -jar jar/sbappcds.jar
