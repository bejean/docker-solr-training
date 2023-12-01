#!/bin/bash
usage(){
    echo ""
    echo "Usage : $0 -a action [-p project] [-m mode] [-v version] [-f]"
    echo ""
    echo "    -a action         : action       - build | up | down | logs | logsf | clean | ps (default)"
    echo "    -p project        : project name (default : \"training\")"
    echo "    -m mode           : solr mode    - cloud (default) | cloudext | cloudzk | stda"
    echo "                        cloudext mode means with dedicated overseer and coordinator nodes"
    echo "                        cloudzk mode means only one solr server in cloud mode and zookeeper embedded"
    echo "    -v version        : solr version - 8 | 8.x | 9 | 9.x | latest (default)"
    echo "    -f force (no prompt)"
    echo ""
    echo "  Example : $0 -a up -p demo -m stda -v 9.1"
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

export MODE=cloud
export VERSION=latest
export ACTION=ps
export PROJECT=training
export FORCE=0
if [ $# -gt 1 ]; then
    while getopts ":a:m:v:p:f" opt; do
        case $opt in
            a) export ACTION=$OPTARG ;;
            v) export VERSION=$OPTARG ;;
            m) export MODE=$OPTARG ;;
            p) export PROJECT=$OPTARG ;;
            f) export FORCE=1 ;;
            *) usage "$1: unknown option" ;;
        esac
    done
fi

if [[ ! "$PROJECT" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "ERROR: project name can contain only alphanumeric characters and _ !"
    usage
fi

if [ "$VERSION" == "9" ] ; then 
    VERSION="latest"
fi

if [ "$VERSION" == "latest" ] ; then 
    SOLR_MAJOR_VERSION="9"
else
    SOLR_MAJOR_VERSION="$(cut -d '.' -f 1 <<< "$VERSION")"
fi

if [ "$ACTION" == "ps" ] ; then 
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
    exit 1
fi

if [[ ! "$ACTION" =~ ^(build|up|down|logs|logsf|clean)$ ]]; then
    echo "ERROR: Unknown action!"
    usage
fi

if [[ ! "$SOLR_MAJOR_VERSION" =~ ^(8|9)$ ]]; then
    echo "ERROR: Invalid version!"
    usage
fi

if [[ ! "$MODE" =~ ^(cloud|cloudext|stda|cloudzk)$ ]]; then
    echo "ERROR: Unknown mode!"
    usage
fi

history "$*"

if [ "$SOLR_MAJOR_VERSION" == "9" ] ; then 
    sed -i "/FROM/c\FROM zookeeper:3.9.0" zookeeper/Dockerfile
else
    if [ "$MODE" == "cloudext" ] ; then 
        echo "ERROR: cloudext mode requires version 9!"
        usage
    fi
    sed -i "/FROM/c\FROM zookeeper:3.6.2" zookeeper/Dockerfile
fi
sed -i "/COMPOSE_PROJECT_NAME/c\COMPOSE_PROJECT_NAME=${PROJECT}_${SOLR_MAJOR_VERSION}" .env
sed -i "/SOLR_VERSION/c\SOLR_VERSION=${SOLR_MAJOR_VERSION}" .env
sed -i "/FROM/c\FROM solr:${VERSION}" solr/Dockerfile

COMPOSE_FILE="docker-compose-$MODE.yml"
        
if [ "$ACTION" == "build" ] ; then 
    docker-compose -f $COMPOSE_FILE build 
fi

if [ "$ACTION" == "up" ] ; then 
    docker-compose -f $COMPOSE_FILE up -d --build
fi

if [ "$ACTION" == "down" ] ; then 
    docker-compose -f $COMPOSE_FILE down
fi

if [ "$ACTION" == "logs" ] ; then 
    docker-compose -f $COMPOSE_FILE logs
fi

if [ "$ACTION" == "logsf" ] ; then 
    docker-compose -f $COMPOSE_FILE logs -f
fi

if [ "$ACTION" == "clean" ] ; then 

    if [ "$FORCE" == "0" ] ; then 
        read -p "Are you sure you want delete all data for this project ? (Yy)" -n 1 -r
        echo    # move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    if [ "$MODE" == "stda" ] ; then 
    	if [ $(docker volume ls -q | grep "${PROJECT}_${SOLR_MAJOR_VERSION}" | grep stda | head -c1 | wc -c) -ne 0 ] ; then
    	    docker volume rm $(docker volume ls -q | grep "${PROJECT}_${SOLR_MAJOR_VERSION}" | grep stda)
    	else
    	    echo "No volume to be deleted !"
    	fi
    else
        if [ "$MODE" == "cloudzk" ] ; then 
            if [ $(docker volume ls -q | grep "${PROJECT}_${SOLR_MAJOR_VERSION}" | grep solr_zk | head -c1 | wc -c) -ne 0 ] ; then
    	        docker volume rm $(docker volume ls -q | grep "${PROJECT}_${SOLR_MAJOR_VERSION}" | grep solr_zk)
    	    else
    	        echo "No volume to be deleted !"
    	    fi
    	else
    	    if [ $(docker volume ls -q | grep "${PROJECT}_${SOLR_MAJOR_VERSION}" | grep -v stda | grep -v solr_zk | head -c1 | wc -c) -ne 0 ] ; then
    	        docker volume rm $(docker volume ls -q | grep "${PROJECT}_${SOLR_MAJOR_VERSION}" | grep -v stda | grep -v solr_zk)
    	    else
    	        echo "No volume to be deleted !"
    	    fi
    	fi
    fi
    #docker-compose -f $COMPOSE_FILE rm -v
fi

