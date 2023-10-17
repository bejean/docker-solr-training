Standalone
==========

---- Démarrer / arrêter / reseter

./dc.sh -m stda -a up
./dc.sh -m stda -a down
./dc.sh -m stda -a clean


---- Envoyer les données

docker cp data/conf-solr9 training_solr_stda_1:/share
docker cp data/boamp_qualif-1.json training_solr_stda_1:/share
./de.sh -c training_solr_stda_1 -e 'chown -R solr: /share/*'


---- Créer collection et indexer

./de.sh -c training_solr_stda_1 -u solr -e 'bin/solr delete -c boamp -p 8983'
./de.sh -c training_solr_stda_1 -u solr -e 'bin/solr create_core -c boamp -d /share/conf-solr9 -p 8983'
./de.sh -c training_solr_stda_1 -u solr -e 'bin/post -c boamp /share/boamp_qualif-1.json'


Solrcloud
==========

---- Démarrer / arrêter / reseter

./dc.sh -m cloud -a up
./dc.sh -m cloud -a down
./dc.sh -m cloud -a clean


--- Securiser Solr (optionnel)

./de.sh -c training_solr1 -e 'bin/solr auth enable -type basicAuth -prompt true -z zk1:2181,zk2:2181,zk3:2181'


---- Envoyer les données

docker cp data/conf-solr9 training_solr1:/share
docker cp data/boamp_qualif-1.json training_solr1:/share
./de.sh -c training_solr1 -e 'chown -R solr: /share/*'


---- Créer collection et indexer

./de.sh -c training_solr1 -u solr -e 'bin/solr delete -c boamp -p 8983'
./de.sh -c training_solr1 -u solr -e 'bin/solr create_collection -c boamp -d /share/conf-solr9 -shards 2 -p 8983'
./de.sh -c training_solr1 -u solr -e 'bin/post [-u user:passwd] -c boamp /share/boamp_qualif-1.json'

