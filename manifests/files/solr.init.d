#!/bin/sh

# Prerequisites:
# 1. Check SOLR_DIR value is correct
# 2. daemon needs to be installed
# 3. Script needs to be executed by root

# This script will launch Solr in a mode that will automatically respawn if it
# crashes. Output will be sent to $LOG. A pid file will be
# created in the standard location.

NAME=solr
SOLR_DIR=/opt/local/solr/example
COMMAND="java -jar start.jar"
LOG=/var/log/solr.log

start () {
    echo -n "Starting solr..."

    # start daemon
    daemon --chdir=$SOLR_DIR --command "$COMMAND" --respawn --output=$LOG --name=$NAME --verbose

    RETVAL=$?
    if [ $RETVAL = 0 ]
    then
        echo "done."
    else
        echo "failed. See error code for more information."
    fi
    return $RETVAL
}

stop () {
    # stop daemon
    echo -n "Stopping $NAME..."

    daemon --stop --name=$NAME  --verbose
    RETVAL=$?

    if [ $RETVAL = 0 ]
    then
        echo "done."
    else
        echo "failed. See error code for more information."
    fi
    return $RETVAL
}


restart () {
    daemon --restart --name=$NAME  --verbose
}


status () {
    # report on the status of the daemon
    daemon --running --verbose --name=$NAME
    return $?
}


case "$1" in
    start)
        start
    ;;
    status)
        status
    ;;
    stop)
        stop
    ;;
    restart)
        restart
    ;;
    *)
        echo $"Usage: $NAME {start|status|stop|restart}"
        exit 3
    ;; esac

exit $RETVAL
