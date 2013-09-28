$:.unshift File.expand_path("../lib", __FILE__)
require "ci-cache/version"

Gem::Specification.new do |s|
  s.name                  = "ci-cache"
  s.version               = CiCache::VERSION
  s.author                = "Johannes Würbach"
  s.email                 = "johannes.wuerbach@googlemail.com"
  s.homepage              = "https://github.com/johanneswuerbach/ci-cache"
  s.summary               = %q{ci cache tool}
  s.description           = %q{cache files in an ephemeral continuous integration environment}
  s.license               = 'MIT'
  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_path          = 'lib'
  s.required_ruby_version = '>= 1.8.7'

  s.add_runtime_dependency 'aws-sdk'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
end
