#### Installation instructions for debian
```
sudo su - postgres -c "createuser music"
sudo su - postgres -c "createdb music"
```

```
mkdir -p /var/www/music-app
chown $APP_USER: /var/www/music-app
sudo su - $APP_USER -c "git clone https://github.com/ngonzalez/music-rails.git /var/www/music-app"
```

```
apt-get install -yq build-essential patch zlib1g-dev liblzma-dev libpq-dev libtag1-dev
```

```
sudo su - $APP_USER -c "cd /var/www/music-app && /usr/bin/bundle2.7"
```

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

#### Update crontab
```
whenever --update-crontab
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
