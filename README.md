# Start the Application
```
pg_ctl -D /usr/local/var/postgres -l /tmp/postgresql.log start

redis-server /usr/local/etc/redis.conf

bundle exec sunspot-solr start -p 8982

bundle exec rake data:update RAILS_ENV=production

bundle exec rake sunspot:solr:reindex RAILS_ENV=production

bundle exec sidekiq -C config/sidekiq.yml -e production

rm -rf public/assets/ ; bundle exec rake assets:precompile RAILS_ENV=production

bundle exec puma -C config/puma.rb -e production -b unix:///tmp/puma.sock

sudo nginx -s stop ; sudo nginx
```
