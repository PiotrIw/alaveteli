#!/bin/bash
#
# !!(*= $daemon_name *)!! Start the WhatDoTheyKnow web server daemon (mongrel)

NAME=!!(*= $daemon_name *)!!
PIDFILE=/data/vhost/!!(*= $vhost *)!!/mysociety/foi/log/mongrel.pid
DUSER=!!(*= $user *)!!

function stop_mongrel {
    if [ -e $PIDFILE ]
    then
        su -c "/usr/bin/ruby -I/usr/lib/ruby/ /usr/bin/mongrel_rails stop --force --wait 5"
        # if --force kicks in, needs to remove the pidfile
        if [ -e $PIDFILE ]
        then
            rm $PIDFILE
        fi
    else
        echo " pidfile does not exist, start first "
        return 1
    fi
}

function start_mongrel {
    if [ -e $PIDFILE ]
    then
        echo " pidfile already exists, stop first "
        return 1
    else
        su -c "/usr/bin/ruby -I/usr/lib/ruby/ /usr/bin/mongrel_rails start -d"
    fi
}

trap "" 1

case "$1" in
  start)
    echo -n "Starting WhatDoTheyKnow web server daemon (mongrel): $NAME"
    start_mongrel
    ;;

  stop)
    echo -n "Stopping WriteToThem web server daemon (mongrel): $NAME"
    stop_mongrel
    ;;

  restart)
    echo -n "Restarting WriteToThem web server daemon (mongrel): $NAME"
    stop_mongrel
    start_mongrel
    ;;

  *)
    echo "Usage: /etc/init.d/$NAME {start|stop|restart}"
    exit 1
    ;;
esac

if [ $? -eq 0 ]; then
	echo .
	exit 0
else
	echo " failed"
	exit 1
fi

