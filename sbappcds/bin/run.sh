#!/bin/bash

cd `dirname $0`/..

JVM_OPTS="-Xshare:off"
JVM_OPTS="$JVM_OPTS -Xlog:class+path=debug"
# JVM_OPTS="$JVM_OPTS -XX:DumpLoadedClassList=log/classes.list"

java $JVM_OPTS -jar jar/sbappcds.jar
