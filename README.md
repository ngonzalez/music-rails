#### Installation instructions for debian
```
sudo su - postgres -c "createuser music"
sudo su - postgres -c "createdb music"
```

```
sudo su - $APP_USER -c "git clone https://github.com/ngonzalez/music-rails.git"
```

```
apt-get install -yq build-essential patch zlib1g-dev liblzma-dev libpq-dev libtag1-dev
```

```
sudo su - $APP_USER -c "cd /home/$APP_USER/music-rails && /usr/bin/bundle2.7"
```

#### Load environment settings
```
source environment.sh
```

#### Start solr
```
bundle exec sunspot-solr start -p 8982
```

#### Start puma
```
bundle exec puma -C config/puma.rb -e production -b unix:///tmp/puma.sock
```

#### Start sidekiq
```
bundle exec sidekiq -C config/sidekiq.yml -e production
```

#### Precompile assets
```
rm -rf public/assets ; bundle exec rake assets:precompile
```

#### Update crontab
```
whenever --update-crontab
```

#### Import data
```
bundle exec rake data:clear
bundle exec rake data:update
```

```
bundle exec rake sunspot:solr:reindex
```
