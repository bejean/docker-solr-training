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
./de.sh -c training_8_solr_d1 -e 'tar xzf /share/json.tgz -C /share'

./de.sh -c training_8_solr_d1 -u solr -e 'bin/solr delete -c boamp -p 8983'
./de.sh -c training_8_solr_d1 -u solr -e 'bin/solr create_collection -c boamp -d /share/boamp/conf-solr8 -shards 2 -replicationFactor 2 -p 8983'
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
./de.sh -c training_9_solr_d1 -e 'tar xzf /share/json.tgz -C /share'

./de.sh -c training_9_solr_d1 -u solr -e 'bin/solr delete -c boamp -p 8983'
./de.sh -c training_9_solr_d1 -u solr -e 'bin/solr create_collection -c boamp -d /share/boamp/conf-solr9 -shards 2 -replicationFactor 2 -p 8983'
./de.sh -c training_9_solr_d1 -u solr -e 'bin/post -c boamp /share/json_qualif'
./de.sh -c training_9_solr_d1 -u solr -e 'bin/post -c boamp /share/json'



./de.sh -c training_9_solr_d1 -u solr -e 'bin/solr delete -c nested -p 8983'
./de.sh -c training_9_solr_d1 -u solr -e 'bin/solr create_collection -c nested -d /share/nested/conf-solr9 -shards 2 -replicationFactor 2 -p 8983'

./de.sh -c training_9_solr_d1 -u solr -e 'curl "http://localhost:8983/solr/nested/update?wt=json" --data-binary @/share/nested/json/nested-1.json -H "Content-type:application/json"'

./de.sh -c training_9_solr_d1 -u solr -e 'curl "http://localhost:8983/solr/nested/update?wt=json" --data-binary @/share/nested/json/nested-1-add.json -H "Content-type:application/json"'

OK - http://localhost:8983/solr/nested/select?indent=on&wt=json&q={!parent which="level:company" }+(contact.lastname:Dupuis AND contact.departement:Design)
KO - http://localhost:8983/solr/nested/select?indent=on&wt=json&q=contact_lastname:Dupuis AND contact_departement:Design

https://solr.apache.org/guide/solr/latest/indexing-guide/indexing-nested-documents.html
https://solr.apache.org/guide/solr/latest/indexing-guide/partial-document-updates.html#updating-child-documents
https://solr.apache.org/guide/solr/latest/query-guide/searching-nested-documents.html
https://solr.apache.org/guide/solr/latest/query-guide/block-join-query-parser.html
https://medium.com/@alisazhila/solr-s-nesting-on-solr-s-capabilities-to-handle-deeply-nested-document-structures-50eeaaa4347a


http://localhost:8983/solr/nested/select?indent=on&wt=json&q=_query_:"{!parent which='*:* -_nest_path_:*' }+(contact.lastname:Dupuis)" AND _query_:"{!dismax qf=sector}Transport"&fl=*,[child]