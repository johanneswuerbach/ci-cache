# ci-cache [![Build Status](https://travis-ci.org/johanneswuerbach/ci-cache.png?branch=master)](https://travis-ci.org/johanneswuerbach/ci-cache)

Cache files and folders between continues integration builds for faster build execution.

### Examples (Travis CI)

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
- gem install ci-cache --no-ri --no-rdoc
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
- gem install ci-cache --no-ri --no-rdoc
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
- gem install ci-cache --no-ri --no-rdoc
- ci-cache get --name bower_components --output-path app
- npm install -g bower
- bower prune
after_script:
- ci-cache set --name bower_components --content app/bower_components --hash-file bower.json
```
