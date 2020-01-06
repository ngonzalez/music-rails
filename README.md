
#### Requirements
 * PostgreSQL
 * redis
 * solr

#### Start the Application
```
bundle exec sunspot-solr start -p 8982
bundle exec sidekiq -C config/sidekiq.yml -e production
rm -rf public/assets/ ; bundle exec rake assets:precompile RAILS_ENV=production
. ./environment.sh ; bundle exec puma -C config/puma.rb -e production -b unix:///tmp/puma.sock
```

#### Update data
```
. ./environment.sh ; bundle exec rake data:clear RAILS_ENV=production
. ./environment.sh ; bundle exec rake data:update RAILS_ENV=production
. ./environment.sh ; bundle exec rake sunspot:solr:reindex RAILS_ENV=production
```

#### Update crontab
```
whenever --update-crontab
```
