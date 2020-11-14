#### Installation instructions for debian
```
sudo su - postgres -c "createuser music"
sudo su - postgres -c "createdb music"
```

```
sudo su - $APP_USER -c "git clone https://github.com/ngonzalez/music-rails.git music-app"
```

```
apt-get install -yq build-essential patch zlib1g-dev liblzma-dev libpq-dev libtag1-dev
```

```
sudo su - $APP_USER -c "cd /home/$APP_USER/music-app && /usr/bin/bundle2.7"
```

```
mkdir /var/lib/music-app ; chown $APP_USER: /var/lib/music-app
mkdir /var/log/music-app ; chown $APP_USER: /var/log/music-app
mkdir /var/run/music-app ; chown $APP_USER: /var/run/music-app
```

```
cp /home/$APP_USER/music-app/config/music-app.service /etc/systemd/system/music-app.service
cp /home/$APP_USER/music-app/config/music-app.target /etc/systemd/system/music-app.target
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
