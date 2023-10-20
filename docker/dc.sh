#!/bin/bash
usage(){
    echo ""
    echo "Usage : $0 -m mode -a action";
    echo ""
    echo "    -m mode           : solr mode (cloud | stda)";
    echo "    -a action         : build | up | down | logs | clean";
    echo ""
    echo "  Example : $0 -m stda -a up"
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

export MODE=
export ACTION=

if [ $# -gt 1 ]; then
    while getopts ":a:m:" opt; do
        case $opt in
            a) export ACTION=$OPTARG ;;
            m) export MODE=$OPTARG ;;
            *) usage "$1: unknown option" ;;
        esac
    done
fi

if [ -z "$ACTION" ] ; then
    echo "ERROR : Missing parameter : -a action"
    usage
fi

if [[ ! "$ACTION" =~ ^(build|up|down|logs|clean)$ ]]; then
    echo "ERROR: Unknown action!"
    usage
fi

if [[ ! "$MODE" =~ ^(cloud|stda)$ ]]; then
    echo "ERROR: Unknown mode!"
    usage
fi

history "$*"

if [ "$MODE" == "stda" ] ; then 
    COMPOSE_FILE="docker-compose-standalone.yml"
else
    COMPOSE_FILE="docker-compose-cloud.yml"
fi
        
if [ "$ACTION" == "build" ] ; then 
    docker-compose -f $COMPOSE_FILE build 
fi

if [ "$ACTION" == "up" ] ; then 
    docker-compose -f $COMPOSE_FILE up -d 
fi

if [ "$ACTION" == "down" ] ; then 
    docker-compose -f $COMPOSE_FILE down
fi

if [ "$ACTION" == "logs" ] ; then 
    docker-compose -f $COMPOSE_FILE logs
fi

if [ "$ACTION" == "clean" ] ; then 
    if [ "$MODE" == "stda" ] ; then 
    	docker volume rm $(docker volume ls -q | grep training | grep stda)
    else
    	docker volume rm $(docker volume ls -q | grep training | grep -v stda)
    fi
    docker-compose -f $COMPOSE_FILE rm -v
fi

