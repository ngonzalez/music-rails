
#### Requirements
 * PostgreSQL
 * redis
 * solr

#### Load environment
```
source environment.sh
```

#### Start Solr
```
bundle exec sunspot-solr start -p 8982
```

#### Start the Application
```
bundle exec puma -C config/puma.rb -e production -b unix:///tmp/puma.sock
bundle exec sidekiq -C config/sidekiq.yml -e production
```

#### Update data
```
bundle exec rake data:clear
bundle exec rake data:update
bundle exec rake sunspot:solr:reindex
```

#### Precompile Assets
```
rm -rf public/assets/ ; bundle exec rake assets:precompile
```

#### Update crontab
```
whenever --update-crontab
```
