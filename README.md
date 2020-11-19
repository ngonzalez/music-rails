#### Installation instructions for debian

### Create user and database
```
su - postgres -c "createuser music"
su - postgres -c "createdb music"
```

### Clone repository
```
mkdir -p /var/www/music-app
chown $APP_USER: /var/www/music-app
su - $APP_USER -c "git clone https://github.com/ngonzalez/music-rails.git /var/www/music-app"
```

### Install dependencies
```
apt-get install -yq build-essential patch zlib1g-dev liblzma-dev libpq-dev libtag1-dev
```

### Run bundle
```
su - $APP_USER -c "cd /var/www/music-app && /usr/bin/bundle2.7"
```

### Add sunspot solr systemd files
```
cp /var/www/music-app/config/systemd/sunspot-solr.service /etc/systemd/system/sunspot-solr.service
cp /var/www/music-app/config/systemd/sunspot-solr.target /etc/systemd/system/sunspot-solr.target
```

#### Start Sunspot solr
```
systemctl start sunspot-solr
```

#### Add Music App systemd files
```
cp /var/www/music-app/config/systemd/music-app.conf /etc/music-app.conf
cp /var/www/music-app/config/systemd/music-app.service /etc/systemd/system/music-app.service
cp /var/www/music-app/config/systemd/music-app.target /etc/systemd/system/music-app.target
```

#### Start the application
```
systemctl start music-app
```

#### Stop the application
```
systemctl stop music-app
```

#### Clear data
```
bundle exec rake data:clear
```

#### Import data
```
bundle exec rake data:update
```

#### Reindex
```
bundle exec rake sunspot:solr:reindex
```

#### Update crontab
```
whenever --update-crontab
```
