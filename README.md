# ci-cache [![Build Status](https://travis-ci.org/johanneswuerbach/ci-cache.png?branch=master)](https://travis-ci.org/johanneswuerbach/ci-cache)

Cache files and folders between continues integration builds.


### Examples

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
  - CI_CACHE_S3_KEY="cache-aws-key"
  - CI_CACHE_S3_SECRET="cache-aws-secret"
before_install:
- gem install ci-cache
- ci-cache get --name bundler-cache --output-path ~
after_script:
- bundle clean
- ci-cache set --name bundler-cache --content ~/.bundle --hash-file Gemfile.lock
```
