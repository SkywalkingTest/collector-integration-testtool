# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/env sh

PRG="$0"
PRGDIR=`dirname "$PRG"`
[ -z "$WEBAPP_HOME" ] && WEBAPP_HOME=`cd "$PRGDIR/.." >/dev/null; pwd`

WEBAPP_LOG_DIR="${WEBAPP_HOME}/logs"
JAVA_OPTS=" -Xms256M -Xmx512M"
JAR_PATH="${WEBAPP_HOME}/webapp"

if [ ! -d "${WEBAPP_HOME}/logs" ]; then
    mkdir -p "${WEBAPP_LOG_DIR}"
fi

_RUNJAVA=${JAVA_HOME}/bin/java
[ -z "$JAVA_HOME" ] && _RUNJAVA=java

if [ "${TEST_DATABASE}" == "es" ]; then
    while :
    do
        status_code=$(curl -m 5 -s -o /dev/null -w %{http_code} http://localhost:9200/_cat/health)
        if [ ${status_code} -ne 200 ];then
            echo -e "\033[33mWaiting elasticsearch...\033[0m"
            sleep 1
        else
            echo -e "\033[32mElasticsearch connect is ok!\033[0m"
            break
        fi
    done
fi

"$_RUNJAVA" ${JAVA_OPTS} -jar ${JAR_PATH}/skywalking-webapp.jar --server.port=8080 --collector.ribbon.listOfServers=127.0.0.1:10800
