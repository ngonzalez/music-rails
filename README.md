
#### Requirements
 * PostgreSQL
 * redis
 * solr

#### Start Solr
```
bundle exec sunspot-solr start -p 8982
```

#### Start the Application
```
. ./environment.sh ; bundle exec puma -C config/puma.rb -e production -b unix:///tmp/puma.sock
. ./environment.sh ; bundle exec sidekiq -C config/sidekiq.yml -e production
```

#### Update data
```
. ./environment.sh ; bundle exec rake data:clear
. ./environment.sh ; bundle exec rake data:update
. ./environment.sh ; bundle exec rake sunspot:solr:reindex
```

#### Precompile Assets
```
rm -rf public/assets/ ; bundle exec rake assets:precompile
```

#### Update crontab
```
whenever --update-crontab
```
