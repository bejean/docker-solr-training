Solrcloud 9
===========

./de.sh -c training_9_solr_d1 -u solr -e 'bin/solr delete -c contacts -p 8983'
./de.sh -c training_9_solr_d1 -u solr -e 'bin/solr create_collection -c contacts -d /share/nested_contacts_societes_users/conf-solr9 -shards 2 -replicationFactor 2 -p 8983'

./de.sh -c training_9_solr_d1 -u solr -e 'curl "http://localhost:8983/solr/contacts/update?wt=json" --data-binary @/share/nested_contacts_societes_users/json/contact-1.json -H "Content-type:application/json"'
