Standalone
==========

---- Démarrer / arrêter / reseter

./dc.sh -m stda -a up
./dc.sh -m stda -a down
./dc.sh -m stda -a clean


---- Envoyer les données

docker cp data/conf-solr9 training_8_solr_stda_1:/share
docker cp data/boamp_qualif-1.json training_8_solr_stda_1:/share
./de.sh -c training_8_solr_stda_1 -e 'chown -R solr: /share/*'


---- Créer collection et indexer

./de.sh -c training_8_solr_stda_1 -e 'chmod -R go+r /share'
./de.sh -c training_8_solr_stda_1 -e 'find /share -type d -exec chmod +x {} \;'


./de.sh -c training_8_solr_stda_1 -u solr -e 'bin/solr delete -c boamp -p 8983'
./de.sh -c training_8_solr_stda_1 -u solr -e 'bin/solr create_core -c boamp -d /share/conf-solr8 -p 8983'
./de.sh -c training_8_solr_stda_1 -u solr -e 'bin/post -c boamp /share/json_qualif'
./de.sh -c training_8_solr_stda_1 -u solr -e 'bin/post -c boamp /share/json'


Solrcloud 8
===========

---- Démarrer / arrêter / reseter

./dc.sh -m cloud -a up
./dc.sh -m cloud -a down
./dc.sh -m cloud -a clean

---- Créer collection et indexer

./de.sh -c training_8_solr_d1 -e 'chmod -R go+r /share'
./de.sh -c training_8_solr_d1 -e 'find /share -type d -exec chmod +x {} \;'

./de.sh -c training_8_solr_d1 -u solr -e 'bin/solr delete -c boamp -p 8983'
./de.sh -c training_8_solr_d1 -u solr -e 'bin/solr create_collection -c boamp -d /share/conf-solr8 -shards 2 -replicationFactor 2 -p 8983'
./de.sh -c training_8_solr_d1 -u solr -e 'bin/post -c boamp /share/json_qualif'
./de.sh -c training_8_solr_d1 -u solr -e 'bin/post -c boamp /share/json'


Solrcloud 9
===========

---- Démarrer / arrêter / reseter

./dc.sh -m cloud9 -a up
./dc.sh -m cloud9 -a down
./dc.sh -m cloud9 -a clean

--- Securiser Solr (optionnel)

./de.sh -c training_9_solr_d1 -e 'bin/solr auth enable -type basicAuth -prompt true -z zk1:2181,zk2:2181,zk3:2181'

---- Créer collection et indexer

./de.sh -c training_9_solr_d1 -e 'chmod -R go+r /share'
./de.sh -c training_9_solr_d1 -e 'find /share -type d -exec chmod +x {} \;'

./de.sh -c training_9_solr_d1 -u solr -e 'bin/solr delete -c boamp -p 8983'
./de.sh -c training_9_solr_d1 -u solr -e 'bin/solr create_collection -c boamp -d /share/conf-solr8 -shards 2 -replicationFactor 2 -p 8983'
./de.sh -c training_9_solr_d1 -u solr -e 'bin/post -c boamp /share/json_qualif'
./de.sh -c training_9_solr_d1 -u solr -e 'bin/post -c boamp /share/json'
