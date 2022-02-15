#!/bin/bash
#
#productservice1    start/stop product1
#
# chkconfig: 12345 80 90
# description: start/stop product1
#
### BEGIN INIT INFO
# Description: start/stop product1
### END INIT INFO

JAR=xxx-xxx-core.jar
PROFILE_ENV=$2


function start_product()
{
  nohup java -jar /home/deployer/abcdir/${JAR} ${PROFILE_ENV} > /dev/null 2>&1 &
}

function stop_product()
{
       PID=$(ps -ef | grep ${JAR} | grep -v grep | awk '{print $2}')
       echo ${PID} | xargs kill -9
       echo "kill ${PID} success!!!"
       sleep 10
}

case "$1" in
    start)
    start_product
    ;;

    stop)
    stop_product
    ;;

    restart)
    stop_product
    start_product
    ;;
    *)
    echo "Usage : start | stop | restart"
    ;;
esac
