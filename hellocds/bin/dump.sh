#!/bin/bash

cd `dirname $0`/..

java -Xshare:dump -XX:SharedClassListFile=log/classes.list -XX:SharedArchiveFile=jsa/classes.jsa -jar jar/hellocds.jar