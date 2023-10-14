Démarrage de 3 serveurs ZK et 4 serveurs Solr

    ./dc.sh test centos up --build -d
    ./dc.sh test centos down


    $ docker ps --format '{{.Names}}' | sort
    $ ./de.sh test_zk1 zookeeper
    $ ./de.sh test_solr1 solr    


Démarage d'un serveur unique Solr
    ./dc.sh test centos standalone up --build -d
    ./dc.sh test centos standalone down

    ./de.sh test_solr solr







---
./de.sh test_zk1

cd /opt/zk/
rm -f /opt/zk/log/*
rm -f /opt/zk/data/zookeeper_server.pid 
./init.d/zookeeper start


---
./de.sh test_solr1

cd /opt/solr/
./init.d/solr start

























===   ===

cd /tmp/
cp /opt/install/packages/solr-7.5.0.tgz .
tar xzf solr-7.5.0.tgz 
cd solr-7.5.0/bin/
mkdir -p /opt/solr/solr
mkdir -p /opt/solr/data
rm -rf /opt/solr/solr/*
rm -rf /opt/solr/data/*
./install_solr_service.sh /tmp/solr-7.5.0.tgz -d /opt/solr/data -i /opt/solr/solr/



cp /opt/install/packages/solr-7.6.0.tgz .
tar xzf solr-7.6.0.tgz 
cd solr-7.6.0/bin/
./install_solr_service.sh /tmp/solr-7.6.0.tgz -d /opt/solr/data -i /opt/solr/solr/ -f




==== ====

sudo -i
cd /tmp/
cp /opt/install/packages/solr-7.5.0.tgz .
tar xzf solr-7.5.0.tgz 
cd solr-7.5.0/bin/
./install_solr_service.sh /tmp/solr-7.5.0.tgz -i /opt/solr -d /opt/solr/cores -u solr -s solr -n


cd /opt/solr/
mv cores/logs .
mv cores/data/* cores/.
rmdir cores/data/


SOLR_PID_DIR="/opt/solr/cores"
SOLR_HOME="/opt/solr/cores"
LOG4J_PROPS="/opt/solr/cores/log4j2.xml"
SOLR_LOGS_DIR="/opt/solr/logs"
SOLR_PORT="8983"

/etc/init.d/solr start


exit
cd /opt/solr/solr
bin/solr create_core -c test




sudo -i
cd /tmp/
cp /opt/install/packages/solr-7.6.0.tgz .
tar xzf solr-7.6.0.tgz 
cd solr-7.6.0/bin/
./install_solr_service.sh /tmp/solr-7.6.0.tgz -i /opt/solr -u solr -s solr -n -f
/etc/init.d/solr start



