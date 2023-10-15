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


