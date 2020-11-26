#### Install Java JDK8
```
# Install Java Runtime by downloading the JDK:
# https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html
```

#### Install ffmpeg for macOS
```
brew install ffmpeg
```

#### Install ffmpeg for debian
```
apt-get install ffmpeg
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
