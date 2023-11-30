#!/bin/bash

usage(){
    echo ""

    echo "Usage : $0 -c container_name [-u user] [-e command]"
    echo ""
    echo "    -c container_name : container name (or container id)"
    echo "    -u user           : user to log in (default: root)"
    echo "    -e command        : command to execute in container (default: bash)"
    echo ""
    echo "  Examples : "
    echo "      $0 -c solr01 -u solr"
    echo "      $0 -c solr01 -u solr -e 'cp ...'"
    echo ""
    exit 1
}
history(){
    DATE="`date +%Y/%m/%d-%H:%M:%S`"
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    echo "$DATE - $0 $1" >> $DIR/history.txt
}

if [ "$1" == "-h" ] ; then 
    usage
fi

export CONTAINER=
export USER=root
export COMMAND=bash
export TRACE=

if [ $# -gt 1 ]; then
    while getopts ":c:u:e:t" opt; do
        case $opt in
            c) export CONTAINER=$OPTARG ;;
            u) export USER=$OPTARG ;;
            e) export COMMAND=$OPTARG ;;
            t) export TRACE=1 ;;
            *) usage "$1: unknown option" ;;
        esac
    done
fi

if [ -z "$CONTAINER" ] ; then
    echo "ERROR : Missing parameter : -c container_name"
    usage
fi

history "$*"

if [[ x$TRACE == "x1" ]] 
then
    echo "docker exec -i -u $USER -t $CONTAINER /bin/bash -c \"exec $COMMAND\""
    exit 1
fi

docker exec -i -u $USER -t $CONTAINER /bin/bash -c "export COLUMNS=10000; export LINES=10000; exec $COMMAND"
