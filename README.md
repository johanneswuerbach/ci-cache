# ci-cache [![Gem Version](https://badge.fury.io/rb/ci-cache.svg)](http://badge.fury.io/rb/ci-cache) [![Build Status](https://travis-ci.org/johanneswuerbach/ci-cache.svg?branch=master)](https://travis-ci.org/johanneswuerbach/ci-cache) [![Code Climate](https://codeclimate.com/github/johanneswuerbach/ci-cache.svg)](https://codeclimate.com/github/johanneswuerbach/ci-cache) [![Dependency Status](https://gemnasium.com/johanneswuerbach/ci-cache.svg)](https://gemnasium.com/johanneswuerbach/ci-cache)
Cache files and folders between continues integration builds for faster build execution. Usable with Travis CI and others.

### Usage

#### Configuration
The ci-cache uses environment variables to receive the AWS config.
```bash
CI_CACHE_S3_BUCKET="cache-bucket"
CI_CACHE_S3_PREFIX="prefix-for-files/"
CI_CACHE_S3_KEY="aws-key"
CI_CACHE_S3_SECRET="aws-secret"
```

#### Download cached file / folder
```bash
ci-cache get --name cache-key --output-path .
```

#### Upload cached file / folder
```
ci-cache set --name cache-key --content cache-folder --hash-file version.lock
```
The cached is only re-uploaded, if the `hash-file` has changed.

### Examples (Travis CI)

You should encrypt your AWS credentials 
```
travis encrypt CI_CACHE_S3_KEY=AWS_KEY CI_CACHE_S3_SECRET=AWS_SECRET --add
```


#### Bundler

```yaml
---
bundler_args: --without development --path=~/.bundle
language: ruby
rvm:
- 2.0.0
env:
  global:
  - CI_CACHE_S3_BUCKET="cache-bucket"
  - CI_CACHE_S3_PREFIX="$TRAVIS_REPO_SLUG/"
  - CI_CACHE_S3_KEY="cache-aws-key"
  - CI_CACHE_S3_SECRET="cache-aws-secret"
before_install:
- travis_retry gem install ci-cache --no-ri --no-rdoc
- ci-cache get --name bundler-cache --output-path ~
after_script:
- bundle clean
- ci-cache set --name bundler-cache --content ~/.bundle --hash-file Gemfile.lock
```

#### Node.js - NPM

```yaml
language: node_js
node_js:
- '0.10'
env:
  global:
  - CI_CACHE_S3_BUCKET="cache-bucket"
  - CI_CACHE_S3_PREFIX="$TRAVIS_REPO_SLUG/"
  - CI_CACHE_S3_KEY="cache-aws-key"
  - CI_CACHE_S3_SECRET="cache-aws-secret"
before_install:
- travis_retry gem install ci-cache --no-ri --no-rdoc
- ci-cache get --name node_modules --output-path .
- npm prune
after_script:
- ci-cache set --name node_modules --content node_modules --hash-file package.json
```

#### Bower (path app/bower_components)

```yaml
language: node_js
node_js:
- '0.10'
env:
  global:
  - CI_CACHE_S3_BUCKET="cache-bucket"
  - CI_CACHE_S3_PREFIX="$TRAVIS_REPO_SLUG/"
  - CI_CACHE_S3_KEY="cache-aws-key"
  - CI_CACHE_S3_SECRET="cache-aws-secret"
before_install:
- travis_retry gem install ci-cache --no-ri --no-rdoc
- ci-cache get --name bower_components --output-path app
- travis_retry npm install -g bower
- bower prune
- travis_retry bower install
after_script:
- ci-cache set --name bower_components --content app/bower_components --hash-file bower.json
```
