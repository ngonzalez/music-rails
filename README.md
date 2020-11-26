#### macOS
```
# Install Java Runtime by downloading the JDK for macOS x64
# https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html
brew install openjdk@8
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
